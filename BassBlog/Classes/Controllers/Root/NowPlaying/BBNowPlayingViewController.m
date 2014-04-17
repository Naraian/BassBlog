//
//  BBNowPlayingViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBNowPlayingViewController.h"

#import "BBRootViewController.h"
#import "BBAppDelegate.h"


@interface BBNowPlayingViewController ()

@end

@implementation BBNowPlayingViewController

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.title = @"NOW PLAYING";
    }
    
    return self;
}

#pragma mark - View

- (void)activate
{
    [self showBackBarButtonItem];
}

- (void)showBackBarButtonItem
{
    NSString *title = NSLocalizedString(@"Back",
                                        @"Back bar button item title.");
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:title
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(backBarButtonItemPressed)];
}

#pragma mark - Actions

- (void)backBarButtonItemPressed
{
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibility];
}

@end
