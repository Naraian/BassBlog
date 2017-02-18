//
//  BBProgressView.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 7/2/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBCommonUtils.h"
#import "BBThemeManager.h"
#import "BBProgressView.h"

@implementation BBProgressView

- (void)setProgressRanges:(NSArray *)progressRanges
{
    _progressRanges = [progressRanges copy];
    
    [self setNeedsDisplay];
}

#define kBBProgressViewLineWith 2.f

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kBBProgressViewLineWith);
    CGFloat centerY = self.bounds.size.height/2.f + 0.5f;
    
    [BBThemeManagerSliderLineColor setStroke];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.f, centerY);
    CGContextAddLineToPoint(context, self.bounds.size.width, centerY);
    CGContextStrokePath(context); //Stroking resets CGContextBeginPath
    
    [BBThemeManagerTabBarTintColor setStroke];
    CGContextBeginPath(context);
    for (BBRange *range in self.progressRanges)
    {
        CGFloat x = range.location * self.bounds.size.width;
        CGFloat width = range.length * self.bounds.size.width;
        
        CGContextMoveToPoint(context, x, centerY);
        CGContextAddLineToPoint(context, width, centerY);
    }
    
    CGContextStrokePath(context);  //Stroking resets CGContextBeginPath
}

@end
