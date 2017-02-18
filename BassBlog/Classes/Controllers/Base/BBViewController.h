//
//  BBViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 06.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

// Base abstract class for view controller.

#import <UIKit/UIKit.h>

@interface BBViewController : UIViewController

@end

#pragma mark -

@interface UIViewController (BB)

#pragma mark Common Initialization

- (void)commonInit;

#pragma mark View

- (void)showNowPlayingBarButtonItem;

- (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                       selector:(SEL)selector;

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title
                                   selector:(SEL)selector;

- (void)updateTheme;

- (void)setTabBarItemTitle:(NSString *)title
                imageNamed:(NSString *)imageName
                       tag:(NSInteger)tag;

#pragma mark - Model

- (void)startObserveNotifications;

@end
