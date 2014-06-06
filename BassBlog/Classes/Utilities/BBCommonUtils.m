//
//  BBCommonUtils.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/4/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBCommonUtils.h"

@implementation BBCommonUtils

+ (BOOL)isCMTimeNumberic:(CMTime)time
{
    return CMTIME_IS_NUMERIC(time);
}

@end
