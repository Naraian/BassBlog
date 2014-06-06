//
//  BBTabBarController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTabBarController.h"

#import "BBAllMixesViewController.h"
#import "BBFavoritesViewController.h"
#import "BBHistoryViewController.h"
#import "BBAboutViewController.h"

#import "BBThemeManager.h"

#import "NSObject+Notification.h"


@implementation BBTabBarController

- (void)dealloc {
    
    [self removeNotificationSelectors];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self updateTheme];
    
    [self addSelector:@selector(themeManagerDidToggleThemeNotification:)
    forNotificationWithName:BBThemeManagerDidToggleThemeNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    BB_WRN(@"");
}

#pragma mark - View

- (void)updateTheme {
    
    BBThemeManager *tm = [BBThemeManager defaultManager];

#warning REMOVE
//    [self.tabBar setSelectionIndicatorImage:[tm imageNamed:@"tab_bar/item/selection_indicator"]];
//    [self.tabBar setBackgroundImage:[tm imageNamed:@"tab_bar/background"]];
    
    self.tabBar.barStyle = UIBarStyleDefault;
    self.tabBar.translucent = YES;
    self.tabBar.tintColor = [UIColor redColor];
    self.tabBar.selectedImageTintColor = [UIColor redColor];
}

- (void)setUserInteractionEnabled:(BOOL)enabled
{
    UIViewController *controller = self.selectedViewController;
    
    if ([controller isKindOfClass:[UINavigationController class]])
    {
        controller = [(UINavigationController *)controller visibleViewController];
    }
    
    controller.view.userInteractionEnabled = enabled;
    self.tabBar.userInteractionEnabled = enabled;
}

#pragma mark - Notifications

- (void)themeManagerDidToggleThemeNotification:(NSNotification *)notification {
    
    [self updateTheme];
}

@end
