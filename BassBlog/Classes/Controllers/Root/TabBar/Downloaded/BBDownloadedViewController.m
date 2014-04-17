//
//  BBDownloadedViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBDownloadedViewController.h"


@implementation BBDownloadedViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setTabBarItemTitle:NSLocalizedString(@"DOWNLOADED", @"")
                           image:[UIImage imageNamed:@"downloads_icon"]
                             tag:eDownloadedMixesCategory];
        
        mixesSelectionOptions.category = eDownloadedMixesCategory;
    }
    
    return self;
}

@end
