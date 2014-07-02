//
//  BBProgressView.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 7/2/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBCommonUtils.h"
#import "BBProgressView.h"

@implementation BBProgressView

- (void)setProgressRanges:(NSArray *)progressRanges
{
    _progressRanges = [progressRanges copy];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (BBRange *range in self.progressRanges)
    {
        CGFloat x = range.location * self.bounds.size.width;
        CGFloat width = range.length * self.bounds.size.width;
        CGRect pieceRect = CGRectMake(x, 0.f, width, self.bounds.size.height);
        
        [path appendPath:[UIBezierPath bezierPathWithRect:pieceRect]];
    }

    [[UIColor blackColor] setFill];
    [path fill];
}

@end
