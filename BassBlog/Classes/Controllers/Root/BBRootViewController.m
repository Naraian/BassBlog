//
//  BBRootViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 04.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBRootViewController.h"
#import "BassBlog-Swift.h"

#import "BBTagsViewController.h"
#import "BBTabBarController.h"

#import "BBActivityView.h"

#import "BBModelManager.h"

#import "NSObject+Notification.h"
#import "BBFont.h"

@class BBNowPlayingViewControllerSwift;

static const NSTimeInterval kBBSlideAnimationInterval = 0.35;

@interface BBRootViewController () <UIGestureRecognizerDelegate, SWRevealViewControllerDelegate>
{
    BBTabBarController *_tabBarController;
    BBTagsViewController *_tagsViewController;
    BBNowPlayingViewControllerSwift *_nowPlayingViewController;
    
    BOOL _nowPlayingViewIsVisible;
    BOOL _tagsViewIsVisible;
}

@property (nonatomic, strong) BBActivityView *modelRefreshActivityView;
@property (nonatomic, strong) UIView *dismissOverlayView;

@end

@implementation BBRootViewController

- (void)dealloc
{
    [self removeNotificationSelectors];
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rearViewRevealWidth = 200.f;
    self.delegate = self;
    
    _tagsViewController = (BBTagsViewController *)self.rearViewController;
    _tabBarController = (BBTabBarController *)self.frontViewController;
    
    if ([[BBModelManager defaultManager] fetchDatabaseIfNecessary])
    {
        [self startObserveModelRefreshNotifications];
        [self showModelRefreshActivityView];
    }
}

- (void)showModelRefreshActivityView
{
    if (self.modelRefreshActivityView.superview)
    {
        return;
    }
    
    self.modelRefreshActivityView.frame = self.view.bounds;
    self.modelRefreshActivityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.modelRefreshActivityView];
}

- (void)hideModelRefreshActivityView
{
    [self.modelRefreshActivityView removeFromSuperview];
    self.modelRefreshActivityView = nil;
}

- (BBActivityView *)modelRefreshActivityView
{
    if (_modelRefreshActivityView == nil)
    {
        _modelRefreshActivityView = [BBActivityView new];
        _modelRefreshActivityView.descriptionLabel.text = NSLocalizedString(@"Loading Database", nil);
        _modelRefreshActivityView.subDescriptionLabel.text = NSLocalizedString(@"this can take some time", nil);
        
        _modelRefreshActivityView.descriptionLabel.font = [BBFont boldFontOfSize:16.f];
        _modelRefreshActivityView.subDescriptionLabel.font = [BBFont boldFontOfSize:14.f];
    }
    
    return _modelRefreshActivityView;
}

- (void)activate
{
    [self drawShadow];
}

- (void)drawShadow {
    
    CALayer *layer = _tabBarController.view.layer;
    CGRect shadowPathRect = self.view.bounds;
    shadowPathRect.size.width = 10.f;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPathRect].CGPath;
    layer.shadowOpacity = 0.75f;
    layer.shadowRadius = 10.f;
    layer.shadowColor = [[UIColor blackColor] CGColor];    
}

#pragma mark - Animation

- (void)toggleTagsVisibility
{
    [self revealToggleAnimated:YES];
}

- (void)toggleNowPlayingVisibilityFromNavigationController:(UINavigationController *)navigationController
{
    if (!_nowPlayingViewController)
    {
        _nowPlayingViewController = (BBNowPlayingViewControllerSwift*)[self.storyboard instantiateViewControllerWithIdentifier:@"nowPlaying"];
    }
    
    if (![navigationController.viewControllers containsObject:_nowPlayingViewController])
    {
        [navigationController pushViewController:_nowPlayingViewController animated:YES];
    }
}

- (void)toggleVisibility:(BOOL *)visibility
        ofSideController:(UIViewController *)sideController
           withAnimation:(void (^)(BOOL visible))animation
              completion:(void (^)(BOOL visible))completion
{
    BOOL animated = YES;
    
    *visibility = *visibility == NO;
    
    [UIView animateWithDuration:kBBSlideAnimationInterval
                     animations:^
    {
        if (*visibility) {
            
            [sideController viewWillAppear:animated];
            [_tabBarController viewWillDisappear:animated];
        }
        else {
            
            [sideController viewWillDisappear:animated];
            [_tabBarController viewWillAppear:animated];
        }
        
        animation(*visibility);
    }
                     completion:^(BOOL finished)
    {
        NSAssert(finished, @"Couldn't finish %@ visibility toggle animation!", sideController);
        
        if (*visibility) {
            
            [sideController viewWillAppear:animated];
            [_tabBarController viewDidDisappear:animated];
        }
        else {
            
            [sideController viewDidDisappear:animated];
            [_tabBarController viewDidAppear:animated];
        }
        
        if (completion) {
            completion(*visibility);
        }
    }];
}

#pragma mark - Controllers

- (BBTagsViewController *)tagsViewController
{
    return _tagsViewController;
}

- (BBNowPlayingViewControllerSwift *)nowPlayingViewController
{
    return _nowPlayingViewController;
}

#pragma mark - Notifications

- (void)startObserveModelRefreshNotifications
{
    [self addSelector:@selector(modelManagerDidFinishRefreshNotification) forNotificationWithName:BBModelManagerDidFinishRefreshNotification];
    [self addSelector:@selector(modelManagerRefreshErrorNotification) forNotificationWithName:BBModelManagerRefreshErrorNotification];
}

- (void)modelManagerRefreshErrorNotification
{
    [self modelManagerDidFinishRefreshNotification];
}

- (void)modelManagerDidFinishRefreshNotification
{
    [self removeNotificationSelectors];
    
    [self hideModelRefreshActivityView];
    
    [self activate];
}

#pragma mark - 
#pragma mark SWRevealViewControllerDelegate

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionRight)
    {
        if (!self.dismissOverlayView)
        {
            self.dismissOverlayView = [UIView new];
            self.dismissOverlayView.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(revealToggle:)];
            [self.dismissOverlayView addGestureRecognizer:tapGestureRecognizer];
        }
        
        self.dismissOverlayView.frame = self.frontViewController.view.bounds;
        [self.frontViewController.view addSubview:self.dismissOverlayView];
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (position == FrontViewPositionLeft)
    {
        [self.dismissOverlayView removeFromSuperview];
    }
}

@end
