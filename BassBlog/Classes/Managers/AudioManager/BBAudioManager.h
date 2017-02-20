//
//  BBAudioManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const BBAudioManagerDidStartPlayNotification;
extern NSString *const BBAudioManagerDidChangeProgressNotification;
extern NSString *const BBAudioManagerDidStopNotification;
extern NSString *const BBAudioManagerDidChangeMixNotification;

extern NSString *const BBAudioManagerDidChangeSpectrumData;
extern NSString *const BBAudioManagerSpectrumDataKey;

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

@property (nonatomic, strong, nullable) AVPlayerItem *playerItem;

@property (nonatomic, weak, nullable) id<BBAudioManagerDelegate> delegate;
@property (nonatomic, strong, nullable) BBMix *mix;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL paused;

- (void)updateSpectrumDataWithData:(NSArray *)data;

+ (BBAudioManager *)defaultManager;

- (void)setMix:(nullable BBMix *)mix paused:(BOOL)paused;

- (void)togglePlayPause;
- (void)playNext;
- (void)playPrev;

- (NSTimeInterval)duration;
- (NSTimeInterval)currentTime;
- (NSTimeInterval)currentTimeLeft;

- (CMTime)timeForProgress:(float)progress;

@end

@protocol BBAudioManagerDelegate

- (nullable BBMix *)nextMix;
- (nullable BBMix *)prevMix;

@end

NS_ASSUME_NONNULL_END
