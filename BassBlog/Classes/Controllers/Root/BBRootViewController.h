//
//  BBRootViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 04.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "SWRevealViewController.h"

@class BBTagsViewController;
@class BBNowPlayingViewControllerSwift;

@interface BBRootViewController : SWRevealViewController

- (void)toggleTagsVisibility;

- (void)toggleNowPlayingVisibilityFromNavigationController:(UINavigationController *)navigationController;

- (BBTagsViewController *)tagsViewController;
- (BBNowPlayingViewControllerSwift *)nowPlayingViewController;

@end
