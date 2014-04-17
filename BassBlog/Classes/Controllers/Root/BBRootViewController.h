//
//  BBRootViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 04.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "SWRevealViewController.h"

@class BBTagsViewController;
@class BBNowPlayingViewController;

@interface BBRootViewController : SWRevealViewController

- (void)toggleTagsVisibility;

- (void)toggleNowPlayingVisibilityFromNavigationController:(UINavigationController *)navigationController;

- (BBTagsViewController *)tagsViewController;
- (BBNowPlayingViewController *)nowPlayingViewController;

@end
