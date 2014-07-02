//
//  BBCommonUtils.h
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/4/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>

@interface BBCommonUtils : NSObject

+ (BOOL)isCMTimeNumberic:(CMTime)time;

@end

@interface BBRange : NSObject

+ (instancetype)rangeWithLocation:(NSTimeInterval)location length:(NSTimeInterval)length;

@property (nonatomic) NSTimeInterval location;
@property (nonatomic) NSTimeInterval length;

@end