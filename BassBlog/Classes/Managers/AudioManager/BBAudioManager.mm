//
//  BBAudioManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAudioManager.h"

#import "NSObject+Notification.h"
#import "NSString+URLEncode.h"
#import "NSObject+Thread.h"

#import "BBMix.h"

#import "BBMacros.h"

#import "BBNowPlayingInfoCenter.h"

#import <MediaToolbox/MediaToolbox.h>
#import <Accelerate/Accelerate.h>

#import "FFTHelper.h"


DEFINE_CONST_NSSTRING(BBAudioManagerDidStartPlayNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeProgressNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidStopNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeSpectrumData);

DEFINE_CONST_NSSTRING(BBAudioManagerStopReasonKey);


static NSString *const AVPlayerStatusKeyPath = @"status";

@interface BBAudioManager ()

@property (nonatomic, strong) BBNowPlayingInfoCenter *nowPlayingInfoCenter;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSObject *playerTimeObserver;
@property (nonatomic, assign) BOOL playerIsReady;

@end

@implementation BBAudioManager

SINGLETON_IMPLEMENTATION(BBAudioManager, defaultManager)

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        // Setup audio session to support background audio playback.
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
                
        [self startObserveNotifications];
    }
    
    return self;
}

- (void)dealloc {
    
    self.player = nil;
}

#pragma mark - Playback

- (void)setMix:(BBMix *)mix paused:(BOOL)paused {
    
    self.mix = mix;
    
    self.paused = paused;
}

- (void)setMix:(BBMix *)mix {
    
    if (_mix == mix) {
        return;
    }
    
    if (_mix) {
        
        [self postDidStopNotificationWithReason:BBAudioManagerWillChangeMix];
    }
    
    _mix = mix;
    
    [self preloadMix];
}

- (void)preloadMix {
    
    self.player = nil;
    
    NSURL *URL = [self.class URLForMix:self.mix];
    if (URL == nil) {
        
        BB_ERR(@"URL == nil");
        
        [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];

        return;
    }
    
    self.mix.playbackDate = [NSDate date];
    
    self.nowPlayingInfoCenter.mix = self.mix;
    
    self.playerItem = [AVPlayerItem playerItemWithURL:URL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
}

- (void)beginRecordingAudioFromTrack:(AVAssetTrack *)audioTrack
{
    // Configure an MTAudioProcessingTap to handle things.
    MTAudioProcessingTapRef tap;
    MTAudioProcessingTapCallbacks callbacks;
    callbacks.version = kMTAudioProcessingTapCallbacksVersion_0;
    callbacks.clientInfo = (__bridge void *)(self);
    callbacks.init = init;
    callbacks.prepare = prepare;
    callbacks.process = process;
    callbacks.unprepare = unprepare;
    callbacks.finalize = finalize;
    
    OSStatus err = MTAudioProcessingTapCreate(
                                              kCFAllocatorDefault,
                                              &callbacks,
                                              kMTAudioProcessingTapCreationFlag_PostEffects,
                                              &tap
                                              );
    
    if(err) {
        NSLog(@"Unable to create the Audio Processing Tap %ld", err);
//        _onError([NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
        return;
    }
    
    // Create an AudioMix and assign it to our currently playing "item", which
    // is just the stream itself.
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters
                                                     audioMixInputParametersWithTrack:audioTrack];
    
    inputParams.audioTapProcessor = tap;
    audioMix.inputParameters = @[inputParams];
    self.player.currentItem.audioMix = audioMix;
}

- (void)setPlayer:(AVPlayer *)player {
    
    if (_player == player) {
        return;
    }
    
    if (_player) {
        
        [_player pause];
        [_player removeObserver:self forKeyPath:AVPlayerStatusKeyPath];
        [_player removeTimeObserver:self.playerTimeObserver];
    }
    
    _player = player;
    
    self.playerIsReady = NO;
    
    if (self.player == nil) {
        return;
    }
    
    __weak BBAudioManager *weakSelf = self;
    
    self.playerTimeObserver =
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) // 0.5 seconds
                                              queue:NULL
                                         usingBlock:^(CMTime time)
    {
        [weakSelf postNotificationWithName:BBAudioManagerDidChangeProgressNotification];
    }];
    
    [self.player addObserver:self
                  forKeyPath:AVPlayerStatusKeyPath
                     options:kNilOptions
                     context:NULL];
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
}

- (void)togglePlayPause {
 
    self.paused = (self.paused == NO);
}

- (void)playNext {
    
    [self setMix:[self.delegate nextMix] paused:NO];
}

- (void)playPrev {
    
    [self setMix:[self.delegate prevMix] paused:NO];
}

- (void)setPaused:(BOOL)paused {
    
    _paused = paused;
    
    if (self.playerIsReady == NO) {
        return;
    }
    
    if (_paused) {
        
        [self.player pause];
        
        [self postDidStopNotificationWithReason:BBAudioManagerPaused];
    }
    else {
        
        [self.player play];
        
        [self postNotificationWithName:BBAudioManagerDidStartPlayNotification];
    }
}

- (void)setProgress:(float)progress {
    
    if (self.playerIsReady) {
    
        CMTime timeToSeek = [self timeForProgress:progress];
        
        if (!CMTIME_IS_INDEFINITE(timeToSeek))
        {
            [self.player seekToTime:timeToSeek];
        }
    }
}

- (void)updateSpectrumDataWithData:(NSArray *)data
{
    self.spectrumData = data;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [[NSNotificationCenter defaultCenter] postNotificationWithName:BBAudioManagerDidChangeSpectrumData];
    });
}

- (float)progress {
    
    if (self.playerIsReady == NO) {
        
        return 0.f;
    }
    
    CMTime duration = [self duration];
    
    if (CMTIME_IS_NUMERIC(duration)) {
        
        CMTime currentTime = [self currentTime];
        
        if (!CMTIME_IS_NUMERIC(currentTime)) {
            
            return [self.class adjustedProgress:currentTime.value / duration.value];
        }
    }
    
    return 0.f;
}

- (BBNowPlayingInfoCenter *)nowPlayingInfoCenter {
    
    if (_nowPlayingInfoCenter == nil) {
        _nowPlayingInfoCenter = [BBNowPlayingInfoCenter new];
    }
    
    return _nowPlayingInfoCenter;
}

#pragma mark - Time

- (CMTime)duration {
    
    return self.player.currentItem.duration;
}

- (CMTime)currentTime {
    
    return self.player.currentItem.currentTime;
}

- (CMTime)currentTimeLeft {
    
    return CMTimeSubtract(self.duration, self.currentTime);
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [self addSelector:@selector(playerItemDidPlayToEndTimeNotification:)
    forNotificationWithName:AVPlayerItemDidPlayToEndTimeNotification];
    
    [self addSelector:@selector(playerItemFailedToPlayToEndTimeNotification:)
    forNotificationWithName:AVPlayerItemFailedToPlayToEndTimeNotification];
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    
    [self postDidStopNotificationWithReason:BBAudioManagerDidPlayToEnd];
}

- (void)playerItemFailedToPlayToEndTimeNotification:(NSNotification *)notification {
 
    BB_ERR(@"%@", notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]);
    
    [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];
}

- (void)postDidStopNotificationWithReason:(BBAudioManagerStopReason)reason {
    
    _paused = YES;
    
    [self postNotificationWithName:BBAudioManagerDidStopNotification
                          userInfo:@{BBAudioManagerStopReasonKey: @(reason)}];
}

#pragma mark - Utils

- (CMTime)timeForProgress:(float)progress {
    
    if (self.player.currentItem) {
        
        CMTime time = self.player.currentItem.duration;
        
        if (CMTIME_IS_NUMERIC(time)) {
            
            return CMTimeMultiplyByFloat64(time, [self.class adjustedProgress:progress]);
        }
    }
    
    return kCMTimeIndefinite;
}


+ (float)adjustedProgress:(float)progress {
    
    if (progress < 0.f) {
        
        return 0.f;
    }
    
    if (progress > 1.f) {
        
        return 1.f;
    }
    
    return progress;
}

+ (NSDate *)dateFromTime:(CMTime)time {
    
    if (CMTIME_IS_NUMERIC(time)) {
        
        return [NSDate dateWithTimeIntervalSince1970:CMTimeGetSeconds(time)];
    }
    
    return nil;
}

+ (NSURL *)URLForMix:(BBMix *)mix {
    
    NSString *urlString = mix.localUrl ? mix.localUrl : mix.url;
    
    if (urlString.length == 0)
    {
        return nil;
    }
    
    return [NSURL URLWithString:urlString];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSAssert(object == self.player, @"%s object != self.player", __FUNCTION__);
    
    if (![keyPath isEqualToString:AVPlayerStatusKeyPath])
    {
        return;
    }
    
    
    
    switch (self.player.status)
    {
        case AVPlayerStatusUnknown:
        case AVPlayerStatusFailed:
        {
            BB_ERR(@"%@", self.player.error);
            
            [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            self.playerIsReady = YES;
            
#warning TODO: start play on correct manualy estimated buffering stage...
            
            AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
            AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
            [self beginRecordingAudioFromTrack:audioTrack];
            
            if (self.paused == NO)
            {
                [self.player play];
                
                [self postNotificationWithName:BBAudioManagerDidStartPlayNotification];
            }
            
        }
            break;
    }
}

#define LAKE_LEFT_CHANNEL (0)
#define LAKE_RIGHT_CHANNEL (1)

void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    NSLog(@"Initialising the Audio Tap Processor");
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap)
{
    NSLog(@"Finalizing the Audio Tap Processor");
}

void prepare(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
    NSLog(@"Preparing the Audio Tap Processor");
}

void unprepare(MTAudioProcessingTapRef tap)
{
    NSLog(@"Unpreparing the Audio Tap Processor");
}

static FFTHelperRef *fftConverter = nil;

void process(MTAudioProcessingTapRef tap, CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    OSStatus err = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut,
                                                      flagsOut, NULL, numberFramesOut);
    if (err) NSLog(@"Error from GetSourceAudio: %ld", err);
    
    AudioBuffer audioBuffer = bufferListInOut->mBuffers[0];
    
    if (!fftConverter)
    {
        fftConverter = FFTHelperCreate(4096);
    }
    
    UInt32 numSamples = audioBuffer.mDataByteSize/sizeof(Float32);
    vDSP_Length log2n = log2f(numSamples);
    Float32 mFFTNormFactor = 1.0/(2*numSamples);
    
    Float32 *windowBuffer = (Float32*) malloc(sizeof(Float32)*numSamples);
    Float32 *dataBuffer = (Float32*) malloc(sizeof(Float32)*numSamples);
    vDSP_blkman_window(windowBuffer, numSamples, 0);
    vDSP_vmul((Float32*)audioBuffer.mData, 1, windowBuffer, 1, dataBuffer, 1, numSamples);
    
    Float32 *fftData = computeFFT(fftConverter, dataBuffer, numSamples);
    
    NSMutableString *string = [NSMutableString new];
    
    NSMutableArray *spectrumData = [NSMutableArray new];
    
    for (UInt32 i = 0; i < log2n; i++)
    {
        Float32 f = fftData[i];
        
        [spectrumData addObject:@(f)];
        
        [string appendFormat:@"%8.4f ", f];
    }
    
    [[BBAudioManager defaultManager] updateSpectrumDataWithData:spectrumData];
    
    NSLog(@"%@", string);
}

@end
