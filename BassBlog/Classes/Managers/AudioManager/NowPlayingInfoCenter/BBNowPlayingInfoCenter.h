//
//  BBNowPlayingInfoCenter.h
//  BassBlog
//
//  Created by Evgeny Sivko on 23.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

@class BBMix;

@interface BBNowPlayingInfoCenter : UIImageView

@property (nonatomic, strong) BBMix *mix;

@property (nonatomic, assign) NSTimeInterval playbackDuration;
@property (nonatomic, assign) NSTimeInterval elapsedTime;

@end
