//
//  BBFont.m
//  BassBlog
//
//  Created by Evgeny Sivko on 04.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBFont.h"


@implementation BBFont

+ (UIFont *)fontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
}

+ (UIFont *)fontLikeFont:(UIFont *)font
{
    return [self fontOfSize:font.pointSize];
}

+ (UIFont *)boldFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
}

+ (UIFont *)boldFontLikeFont:(UIFont *)font
{    
    return [self boldFontOfSize:font.pointSize];
}

@end
