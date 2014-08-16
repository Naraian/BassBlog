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

+ (instancetype)new
{    
    BBActivityView *activityView = [self instanceFromNib:nil];
    activityView.activityIndicator.lineWidth = 3.f;
    activityView.activityIndicator.trackTintColor = [UIColor colorWithHEX:0xEEEEEEFF];
    activityView.activityIndicator.progressTintColor = [UIColor colorWithHEX:0xF24F4FFF];
    
    return activityView;
}

@end
