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

@implementation BBRange

+ (instancetype)rangeWithLocation:(float)location length:(float)length
{
    BBRange *range = [self new];
    range.location = location;
    range.length = length;
    
    return range;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ {loc: %8.4f, length: %8.4f}", [super description], self.location, self.length];
}

@end


