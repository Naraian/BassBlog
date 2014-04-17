//
//  BBViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 06.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBViewController.h"
#import "BBRootViewController.h"

#import "BBThemeManager.h"

#import "BBAudioManager.h"

#import "BBAppDelegate.h"

#import "BBFont.h"

#import "NSObject+Notification.h"
#import "NSObject+Nib.h"


@implementation BBViewController

- (id)init
{
    return [self initWithNibName:[self.class nibName]
                          bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    WRN(@"");
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTheme];
    
    [self startObserveNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startReceivingRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self endReceivingRemoteControlEvents];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Handling Remote Events

- (BOOL)canBecomeFirstResponder {
    
    return YES;
}

- (void)startReceivingRemoteControlEvents {
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
}

- (void)endReceivingRemoteControlEvents {
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [audioManager togglePlayPause];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [audioManager playNext];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [audioManager playPrev];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Notifications

- (void)themeManagerDidToggleThemeNotification:(NSNotification *)notification
{
    [self updateTheme];
}

@end

#pragma mark -

@implementation BBViewController (Protected)

- (void)updateTheme {
    
    BBThemeManager *themeManager = [BBThemeManager defaultManager];
    
    UIColor *color = nil;
    switch (themeManager.theme) {
            
        default:
            color = [UIColor blackColor];
            break;
    }
    
    self.view.backgroundColor = color;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;

#warning REMOVE
//    UIImage *image = [themeManager imageNamed:@"navigation_bar/background"];
//    [navigationBar setBackgroundImage:image
//                        forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *attributes = @{UITextAttributeTextColor:[UIColor whiteColor],
                                 UITextAttributeFont:[BBFont boldFontOfSize:18]};
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:4.f forBarMetrics:UIBarMetricsDefault];
}

- (void)setTabBarItemTitle:(NSString *)title
                imageNamed:(NSString *)imageName
                       tag:(NSInteger)tag
{
    imageName = [@"tab_bar/item" stringByAppendingPathComponent:imageName];
    UIImage *image = [[BBThemeManager defaultManager] imageNamed:imageName];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                    image:image
                                                      tag:tag];
    
    NSDictionary *attributes = @{UITextAttributeFont:[BBFont boldFontOfSize:9.f]};
    
    [self.tabBarItem setTitleTextAttributes:attributes
                                   forState:UIControlStateNormal];

#warning TODO remove
//    [self.tabBarItem setFinishedSelectedImage:image
//                  withFinishedUnselectedImage:image];
}

- (void)startObserveNotifications {
    
    [self addSelector:@selector(themeManagerDidToggleThemeNotification:)
    forNotificationWithName:BBThemeManagerDidToggleThemeNotification];
}

@end
