//
//  BBActivityView.m
//  BassBlog
//
//  Created by Evgeny Sivko on 21.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBActivityView.h"

#import "NSObject+Nib.h"


@implementation BBActivityView

+ (id)new {
    
    return [self instanceFromNib:nil];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect activityIndicatorFrame = self.activityIndicator.frame;
    activityIndicatorFrame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(activityIndicatorFrame)) / 2.f;
    activityIndicatorFrame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(activityIndicatorFrame)) / 2.f;
    self.activityIndicator.frame = activityIndicatorFrame;
}

@end
