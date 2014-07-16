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
#import "BBSpectrumAnalyzerView.h"

#import "NSObject+Notification.h"
#import "NSObject+Nib.h"

static const CGFloat kBBViewControllerNowPlayingItemWidth = 34.f;
static const CGFloat kBBViewControllerNowPlayingItemHeight = 24.f;

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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

- (void)updateTheme
{
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
                                 NSFontAttributeName:[BBFont boldFontOfSize:21]};
    
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

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title
                                   selector:(SEL)selector
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(title, nil)
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                            action:selector];
    
    return item;
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
//    self.tabBarItem.imageInsets = UIEdgeInsetsMake(6.f, 0.f, -6.f, 0.f);
}

- (void)startObserveNotifications
{
    [self addSelector:@selector(themeManagerDidToggleThemeNotification:) forNotificationWithName:BBThemeManagerDidToggleThemeNotification];
}

- (void)showNowPlayingBarButtonItem
{
    BBSpectrumAnalyzerView *spectrumAnalyzerView = [[BBSpectrumAnalyzerView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                                                            kBBViewControllerNowPlayingItemWidth, kBBViewControllerNowPlayingItemHeight)];
    spectrumAnalyzerView.backgroundColor = [UIColor clearColor];
    spectrumAnalyzerView.barBackgroundColor = [UIColor colorWithHEX:0xFFFFFF11];
    spectrumAnalyzerView.barFillColor = BBThemeManagerWinterOrangeColor;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nowPlayingBarButtonItemPressed)];
    [spectrumAnalyzerView addGestureRecognizer:tapGestureRecognizer];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:spectrumAnalyzerView];
    item.width = kBBViewControllerNowPlayingItemWidth;
    self.navigationItem.rightBarButtonItem = item;
    
    //    [self barButtonItemWithImageName:@"now_playing" selector:@selector(nowPlayingBarButtonItemPressed)];
}

- (void)nowPlayingBarButtonItemPressed
{
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibilityFromNavigationController:self.navigationController];
}

@end
