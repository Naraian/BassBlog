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
    
    self.title = NSLocalizedString(@"DOWNLOADED", @"");
        
    [self setTabBarItemTitle:self.title
                       image:[UIImage imageNamed:@"downloads_icon"]
                         tag:eDownloadedMixesCategory];
        
    mixesSelectionOptions.category = eDownloadedMixesCategory;
}

@end
