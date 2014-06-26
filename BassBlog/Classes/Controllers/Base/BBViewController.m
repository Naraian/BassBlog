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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    BB_WRN(@"");
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

- (void)commonInit
{
    
}

- (void)updateTheme {
    
    BBThemeManager *themeManager = [BBThemeManager defaultManager];
    
    UIColor *color = nil;
    switch (themeManager.theme) {
            
        default:
            color = [UIColor lightGrayColor];
            break;
    }
    
    self.view.backgroundColor = color;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    
    UIColor *barColor = [UIColor colorWithHEX:0x2B2B2BFF];
    
    if (RUNNING_ON_IOS7)
    {
        self.navigationController.navigationBar.barTintColor = barColor;
        self.navigationController.navigationBar.tintColor = [UIColor colorWithHEX:0xECECECFF];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = barColor;
    }

    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:[BBFont boldFontOfSize:18]};
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
}

- (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                       selector:(SEL)selector
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    imageName = [@"navigation_bar/item" stringByAppendingPathComponent:imageName];
    
    UIImage *image = [tm imageNamed:imageName];

    return [[UIBarButtonItem alloc] initWithImage:image
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:selector];
}

- (void)setTabBarItemTitle:(NSString *)title
                imageNamed:(NSString *)imageName
                       tag:(NSInteger)tag
{
    BBThemeManager *themeManager = [BBThemeManager defaultManager];
    
    imageName = [@"tab_bar/item" stringByAppendingPathComponent:imageName];
    UIImage *image = [themeManager imageNamed:imageName];
    
    imageName = [imageName stringByAppendingString:@"_selected"];
    UIImage *selectedImage = [themeManager imageNamed:imageName];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                    image:image
                                            selectedImage:selectedImage];
    self.tabBarItem.tag = tag;
    
    NSDictionary *attributes = @{NSFontAttributeName : [BBFont boldFontOfSize:9.f]};

    [self.tabBarItem setTitleTextAttributes:attributes
                                   forState:UIControlStateNormal];
}

- (void)startObserveNotifications {
    
    [self addSelector:@selector(themeManagerDidToggleThemeNotification:)
    forNotificationWithName:BBThemeManagerDidToggleThemeNotification];
}

@end
