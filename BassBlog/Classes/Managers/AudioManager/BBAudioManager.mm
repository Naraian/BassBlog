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
#import "BBCommonUtils.h"

#import "BBNowPlayingInfoCenter.h"

#import <MediaToolbox/MediaToolbox.h>
#import <Accelerate/Accelerate.h>

#import "FFTHelper.h"

#include <vector>


DEFINE_CONST_NSSTRING(BBAudioManagerDidStartPlayNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeProgressNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidStopNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeMixNotification);

DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeSpectrumData);
DEFINE_CONST_NSSTRING(BBAudioManagerSpectrumDataKey);

DEFINE_CONST_NSSTRING(BBAudioManagerStopReasonKey);


static NSString *const AVPlayerStatusKeyPath = @"status";

@interface BBAudioManager ()

@property (nonatomic, strong) BBNowPlayingInfoCenter *nowPlayingInfoCenter;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSObject *playerTimeObserver;
@property (nonatomic, assign) BOOL playerIsReady;

@end

@implementation BBAudioManager

@synthesize paused = _paused;
@dynamic progress;

SINGLETON_IMPLEMENTATION(BBAudioManager, defaultManager)

- (id)init
{
    if (self = [super init])
    {
        // Setup audio session to support background audio playback.
        [self startObserveNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    self.player = nil;
}

- (void)setupAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error)
    {
        BB_ERR(@"error setting audioSession category: %@-%@", [error localizedDescription], [error localizedFailureReason]);
    }
    
    [audioSession setActive:YES error:&error];
    
    if (error)
    {
        BB_ERR(@"error setting audioSession active: %@-%@", [error localizedDescription], [error localizedFailureReason]);
    }
}

#pragma mark - Playback

- (void)setMix:(BBMix *)mix paused:(BOOL)aPaused
{
    self.mix = mix;
    
    self.paused = aPaused;
}

- (void)setMix:(BBMix *)mix
{
    if (_mix == mix)
    {
        return;
    }
    
    if (_mix)
    {
        [self postDidStopNotificationWithReason:BBAudioManagerWillChangeMix];
    }
    
    _mix = mix;
    
    [self postNotificationWithName:BBAudioManagerDidChangeMixNotification];
    
    [self preloadMix];
}

- (void)preloadMix
{
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
    
    [self setupAudioSession];
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
    
    OSStatus err = MTAudioProcessingTapCreate(kCFAllocatorDefault,
                                              &callbacks,
                                              kMTAudioProcessingTapCreationFlag_PostEffects,
                                              &tap);
    
    if(err)
    {
        BB_ERR(@"Unable to create the Audio Processing Tap %d", (int)err);
        return;
    }
    
    // Create an AudioMix and assign it to our currently playing "item", which
    // is just the stream itself.
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *inputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    inputParams.audioTapProcessor = tap;
    audioMix.inputParameters = @[inputParams];
    self.player.currentItem.audioMix = audioMix;
}

- (void)setPlayer:(AVPlayer *)player
{
    if (_player == player)
    {
        return;
    }
    
    if (_player)
    {
        [_player pause];
        [_player removeObserver:self forKeyPath:AVPlayerStatusKeyPath];
        [_player removeTimeObserver:self.playerTimeObserver];
    }
    
    _player = player;
    
    self.playerIsReady = NO;
    
    if (self.player == nil)
    {
        return;
    }
    
    __weak BBAudioManager *weakSelf = self;
    
    self.playerTimeObserver =
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) // 0.5 seconds
                                              queue:NULL
                                         usingBlock:^(CMTime time)
    {
        [weakSelf updateProgress];
        [weakSelf postNotificationWithName:BBAudioManagerDidChangeProgressNotification];
    }];
    
    [self.player addObserver:self
                  forKeyPath:AVPlayerStatusKeyPath
                     options:kNilOptions
                     context:NULL];
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
}

- (void)togglePlayPause
{
    self.paused = (self.paused == NO);
}

- (void)playNext
{
    [self setMix:[self.delegate nextMix] paused:NO];
}

- (void)playPrev
{
    [self setMix:[self.delegate prevMix] paused:NO];
}

- (BOOL)paused
{
    return (self.player.rate == 0.f);
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    
    if (self.playerIsReady == NO)
    {
        return;
    }
    
    if (_paused)
    {
        [self.player pause];
        
        [self postDidStopNotificationWithReason:BBAudioManagerPaused];
    }
    else
    {
        [self.player play];
        
        [self postNotificationWithName:BBAudioManagerDidStartPlayNotification];
    }
}

- (void)updateProgress
{
    self.nowPlayingInfoCenter.elapsedTime = self.currentTime;
}

- (void)setProgress:(float)progress
{
    if (self.playerIsReady)
    {
        CMTime timeToSeek = [self timeForProgress:progress];
        
        if (!CMTIME_IS_INDEFINITE(timeToSeek))
        {
            [self.player seekToTime:timeToSeek];
        }
    }
}

- (void)updateSpectrumDataWithData:(NSArray *)data
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSDictionary *userInfo = nil;
        if (data)
        {
            userInfo = @{BBAudioManagerSpectrumDataKey : data};
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationWithName:BBAudioManagerDidChangeSpectrumData userInfo:userInfo];
    });
}

- (float)progress
{
    if (self.playerIsReady == NO)
    {
        return 0.f;
    }
    
    NSTimeInterval duration = self.duration;
    
    if (duration > 0.0)
    {
        NSTimeInterval currentTime = self.currentTime;
        
        if (currentTime > 0.0)
        {
            return [self.class adjustedProgress:currentTime/duration];
        }
    }
    
    return 0.f;
}

- (BBNowPlayingInfoCenter *)nowPlayingInfoCenter
{
    if (_nowPlayingInfoCenter == nil)
    {
        _nowPlayingInfoCenter = [BBNowPlayingInfoCenter new];
    }
    
    return _nowPlayingInfoCenter;
}

#pragma mark - Time

- (NSTimeInterval)duration
{
    return [BBCommonUtils secondsFromCMTime:self.player.currentItem.duration];
}

- (NSTimeInterval)currentTime
{
    return [BBCommonUtils secondsFromCMTime:self.player.currentItem.currentTime];
}

- (NSTimeInterval)currentTimeLeft
{
    return MAX(0.0, self.duration - self.currentTime);
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [self addSelector:@selector(playerItemDidPlayToEndTimeNotification:) forNotificationWithName:AVPlayerItemDidPlayToEndTimeNotification];
    [self addSelector:@selector(playerItemFailedToPlayToEndTimeNotification:) forNotificationWithName:AVPlayerItemFailedToPlayToEndTimeNotification];
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification
{
    [self postDidStopNotificationWithReason:BBAudioManagerDidPlayToEnd];
    
    [self playNext];
}

- (void)playerItemFailedToPlayToEndTimeNotification:(NSNotification *)notification
{
    BB_ERR(@"%@", notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]);
    
    [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];
}

- (void)postDidStopNotificationWithReason:(BBAudioManagerStopReason)reason
{
    _paused = YES;
    
    [self postNotificationWithName:BBAudioManagerDidStopNotification
                          userInfo:@{BBAudioManagerStopReasonKey: @(reason)}];
}

#pragma mark - Utils

- (CMTime)timeForProgress:(float)progress
{
    if (self.player.currentItem)
    {
        CMTime time = self.player.currentItem.duration;
        
        if (CMTIME_IS_NUMERIC(time))
        {
            return CMTimeMultiplyByFloat64(time, [self.class adjustedProgress:progress]);
        }
    }
    
    return kCMTimeIndefinite;
}


+ (float)adjustedProgress:(float)progress
{
    return MIN(MAX(0.f, progress), 1.f);
}

+ (NSDate *)dateFromTime:(CMTime)time
{
    if (CMTIME_IS_NUMERIC(time))
    {
        return [NSDate dateWithTimeIntervalSince1970:CMTimeGetSeconds(time)];
    }
    
    return nil;
}

+ (NSURL *)URLForMix:(BBMix *)mix
{
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
            break;
        }
            
        case AVPlayerStatusReadyToPlay:
        {
            self.playerIsReady = YES;
            
            AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
            
            if (asset.tracks.count > 0)
            {
                AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
                [self beginRecordingAudioFromTrack:audioTrack];
            }
            
            self.nowPlayingInfoCenter.playbackDuration = self.duration;
            
            if (_paused == NO)
            {
                [self.player play];
                
                [self postNotificationWithName:BBAudioManagerDidStartPlayNotification];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#define LAKE_LEFT_CHANNEL (0)
#define LAKE_RIGHT_CHANNEL (1)

void init(MTAudioProcessingTapRef tap, void *clientInfo, void **tapStorageOut)
{
    BB_INF(@"Initialising the Audio Tap Processor");
    *tapStorageOut = clientInfo;
}

void finalize(MTAudioProcessingTapRef tap)
{
    BB_INF(@"Finalizing the Audio Tap Processor");
}

void prepare(MTAudioProcessingTapRef tap, CMItemCount maxFrames, const AudioStreamBasicDescription *processingFormat)
{
    BB_INF(@"Preparing the Audio Tap Processor");
}

void unprepare(MTAudioProcessingTapRef tap)
{
    BB_INF(@"Unpreparing the Audio Tap Processor");
}

static FFTHelper *fftHelper = nil;

void process(MTAudioProcessingTapRef tap, CMItemCount numberFrames,
             MTAudioProcessingTapFlags flags, AudioBufferList *bufferListInOut,
             CMItemCount *numberFramesOut, MTAudioProcessingTapFlags *flagsOut)
{
    OSStatus err = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut,
                                                      flagsOut, NULL, numberFramesOut);
    if (err)
    {
        BB_ERR(@"Error from GetSourceAudio: %i", (int)err);
    }
    
    if (!fftHelper)
    {
        fftHelper = [FFTHelper new];
    }
    
    [fftHelper performComputation:bufferListInOut completionHandler:^(NSArray *fftData)
    {
        [[BBAudioManager defaultManager] updateSpectrumDataWithData:fftData];
    }];
}

@end
