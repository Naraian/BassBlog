//
//  BBViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 06.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

// Base abstract class for view controller.

@interface BBViewController : UIViewController

@end

#pragma mark -

@interface BBViewController (Protected)

#pragma mark Common Initialization

- (void)commonInit;

#pragma mark View

- (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                       selector:(SEL)selector;

- (void)updateTheme;

- (void)setTabBarItemTitle:(NSString *)title
                imageNamed:(NSString *)imageName
                       tag:(NSInteger)tag;

#pragma mark - Model

- (void)startObserveNotifications;

@end
