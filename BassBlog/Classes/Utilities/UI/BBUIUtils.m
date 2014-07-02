//
//  BBUIUtils.m
//  BassBlog
//
//  Created by Evgeny Sivko on 26.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBUIUtils.h"

#import "BBTag.h"
#import "BBMix.h"

@implementation BBUIUtils

+ (NSString *)tagsStringForMix:(BBMix *)mix {
    
    return [[[BBTag formalNamesOfTags:mix.tags] allObjects] componentsJoinedByString:@", "];
}

+ (UIImage *)scaledImage:(UIImage *)image toSize:(CGSize)size {
    
#warning TODO: implement...
    
    return nil;
}

+ (UIImage *)defaultImageWithSize:(CGSize)size {
    
    return [self scaledImage:[self defaultImage] toSize:size];
}

+ (UIImage *)defaultImage {
    
    return [UIImage imageNamed:@"default_image"];
}

+ (NSString *)timeStringFromCMTime:(CMTime)time
{
    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);
    
    if (!CMTIME_IS_VALID(time))
    {
        return nil;
    }
    
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    return [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
}

+ (NSString *)timeStringFromTime:(NSTimeInterval)time
{
    NSUInteger dTotalSeconds = time;    
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    return [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
}


@end
