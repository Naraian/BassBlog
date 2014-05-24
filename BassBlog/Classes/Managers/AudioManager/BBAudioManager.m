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

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAudioSession.h>


DEFINE_CONST_NSSTRING(BBAudioManagerDidStartPlayNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidChangeProgressNotification);
DEFINE_CONST_NSSTRING(BBAudioManagerDidStopNotification);

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
        
        ERR(@"URL == nil");
        
        [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];

        return;
    }
    
    self.mix.playbackDate = [NSDate date];
    
    self.nowPlayingInfoCenter.mix = self.mix;
    
//    self.player = [AVPlayer playerWithURL:URL];
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
 
    ERR(@"%@", notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]);
    
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
    
    if (urlString.length == 0) {
        
        NSAssert(NO, @"%s empty URL!", __FUNCTION__);
        return nil;
    }
    
#warning TODO: remove when fix will be on server
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@"\" target=\"_blank"
                                                     withString:@""];
    
    return [NSURL URLWithString:[urlString urlEncodedString]];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSAssert(object == self.player, @"%s object != self.player", __FUNCTION__);
    
    if ([keyPath isEqualToString:AVPlayerStatusKeyPath] == NO) {
        return;
    }
    
    switch (self.player.status) {
            
        case AVPlayerStatusUnknown:
        case AVPlayerStatusFailed:
        {
            ERR(@"%@", self.player.error);
            
            [self postDidStopNotificationWithReason:BBAudioManagerFailedToPlayToEnd];
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            self.playerIsReady = YES;
            
#warning TODO: start play on correct manualy estimated buffering stage...
            
            if (self.paused == NO) {
                
                [self.player play];
                
                [self postNotificationWithName:BBAudioManagerDidStartPlayNotification];
            }
        }
            break;
    }
}

@end
