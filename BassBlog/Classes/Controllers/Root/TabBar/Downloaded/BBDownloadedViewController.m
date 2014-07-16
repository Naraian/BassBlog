//
//  BBDownloadedViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBDownloadedViewController.h"


@implementation BBDownloadedViewController

- (void)commonInit
{
    [super commonInit];
    
    NSString *title = NSLocalizedString(@"Downloaded", nil);
    self.title = title.uppercaseString;
    [self setTabBarItemTitle:title imageNamed:@"downloads_icon" tag:eDownloadedMixesCategory];

    mixesSelectionOptions.category = eDownloadedMixesCategory;
}

@end
