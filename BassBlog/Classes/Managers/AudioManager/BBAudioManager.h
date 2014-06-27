//
//  BBAudioManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const BBAudioManagerDidStartPlayNotification;
extern NSString *const BBAudioManagerDidChangeProgressNotification;
extern NSString *const BBAudioManagerDidStopNotification;
extern NSString *const BBAudioManagerDidChangeSpectrumData;

extern NSString *const BBAudioManagerStopReasonKey;

typedef NS_ENUM(NSInteger, BBAudioManagerStopReason) {
    
    BBAudioManagerDidPlayToEnd,
    BBAudioManagerFailedToPlayToEnd,
    BBAudioManagerWillChangeMix,
    BBAudioManagerPaused
};

@class BBMix;

@protocol BBAudioManagerDelegate;

@interface BBAudioManager : NSObject

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, weak) id<BBAudioManagerDelegate> delegate;
@property (nonatomic, strong) BBMix *mix;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL paused;

@property (atomic, strong) NSArray *spectrumData;

- (void)updateSpectrumDataWithData:(NSArray *)data;

+ (BBAudioManager *)defaultManager;

- (void)setMix:(BBMix *)mix paused:(BOOL)paused;

- (void)togglePlayPause;
- (void)playNext;
- (void)playPrev;

- (CMTime)duration;
- (CMTime)currentTime;
- (CMTime)currentTimeLeft;

- (CMTime)timeForProgress:(float)progress;

@end

@protocol BBAudioManagerDelegate

- (BBMix *)nextMix;
- (BBMix *)prevMix;

@end