//
//  BBMix.h
//  BassBlog
//
//  Created by Evgeny Sivko on 29.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity.h"


extern NSString *const BBMixDidChangeLocalUrlNotification;
extern NSString *const BBMixDidChangePlaybackDateNotification;
extern NSString *const BBMixDidChangeFavoriteNotification;

@interface BBMix : BBEntity

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *localUrl;
@property (nonatomic, strong) NSString *tracklist;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *playbackDate;
@property (nonatomic, strong) NSSet *tags;
@property (nonatomic) int16_t bitrate;
@property (nonatomic) BOOL favorite;

@end
