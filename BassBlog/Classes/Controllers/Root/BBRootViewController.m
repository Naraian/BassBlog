//
//  BBRootViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 04.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBRootViewController.h"

#import "BBTagsViewController.h"
#import "BBTabBarController.h"

#import "BBActivityView.h"

#import "BBModelManager.h"

#import "NSObject+Notification.h"

@class BBNowPlayingViewControllerSwift;

static const NSTimeInterval kBBSlideAnimationInterval = 0.35;

@interface BBRootViewController () <UIGestureRecognizerDelegate>
{
    BBTabBarController *_tabBarController;
    BBTagsViewController *_tagsViewController;
    BBNowPlayingViewControllerSwift *_nowPlayingViewController;
    
#warning TODO: rename nowPlayingViewController
    
    BOOL _nowPlayingViewIsVisible;
    BOOL _tagsViewIsVisible;
}

@property (nonatomic, strong) BBActivityView *modelRefreshActivityView;

@end

@implementation BBRootViewController

- (void)dealloc {
    
    [self removeNotificationSelectors];
}

#pragma mark - View

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tagsViewController = (BBTagsViewController *)self.rearViewController;
    _tabBarController = (BBTabBarController *)self.frontViewController;
    
//    [self.navigationController.navigationBar addGestureRecognizer: self.panGestureRecognizer];
    
    if ([BBModelManager isModelEmpty]) {
        
        [self startObserveModelRefreshNotifications];
        
        [self showModelRefreshActivityView];
    }
    else {
        
        [self activate];
    }
    
    [[BBModelManager defaultManager] refresh];
}

- (void)showModelRefreshActivityView
{
    if (self.modelRefreshActivityView.superview) {
        return;
    }
    
    self.modelRefreshActivityView.frame = self.view.bounds;
    
    [self.view addSubview:self.modelRefreshActivityView];
}

- (void)hideModelRefreshActivityView
{
    [self.modelRefreshActivityView removeFromSuperview];
    self.modelRefreshActivityView = nil;
}

- (BBActivityView *)modelRefreshActivityView {
    
    if (_modelRefreshActivityView == nil) {
        _modelRefreshActivityView = [BBActivityView new];
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
    
    [navigationController pushViewController:_nowPlayingViewController animated:YES];
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
    [self addSelector:@selector(modelManagerDidChangeRefreshStageNotification:) forNotificationWithName:BBModelManagerDidChangeRefreshStageNotification];
    [self addSelector:@selector(modelManagerRefreshProgressNotification:) forNotificationWithName:BBModelManagerRefreshProgressNotification];
    [self addSelector:@selector(modelManagerDidFinishRefreshNotification:) forNotificationWithName:BBModelManagerDidFinishRefreshNotification];
}

- (void)modelManagerDidChangeRefreshStageNotification:(NSNotification *)notification {
    
    [self updateModelRefreshActivityDescriptionWithProgress:-1.f];    
}

- (void)modelManagerRefreshProgressNotification:(NSNotification *)notification {
    
    float progress = [[notification.userInfo objectForKey:BBModelManagerRefreshProgressNotificationKey] floatValue];

    [self updateModelRefreshActivityDescriptionWithProgress:progress];
}

- (void)updateModelRefreshActivityDescriptionWithProgress:(float)progress {
    
    NSString *description = nil;
    
    switch ([[BBModelManager defaultManager] refreshStage]) {
            
        case BBModelManagerLoadingStage:
            [self showModelRefreshActivityView];
            description = NSLocalizedString(@"Database loading", @"");
            break;
            
        case BBModelManagerParsingStage:
            description = NSLocalizedString(@"Database parsing", @"");
            break;
            
        case BBModelManagerSavingStage:
            description = NSLocalizedString(@"Database saving", @"");
            break;
            
        case BBModelManagerWaitingStage:
            [self hideModelRefreshActivityView];
            break;
    }
    
    if (description) {
        
        if (progress >= 0.f) {
            NSInteger precentage = ceilf(progress * 100);
            description = [description stringByAppendingFormat:@" (%d%%)", precentage];
        }
        else {
            description = [description stringByAppendingString:@"..."];
        }
    }
    
    self.modelRefreshActivityView.descriptionLabel.text = description;
}

- (void)modelManagerDidFinishRefreshNotification:(NSNotification *)notification {
    
    [self removeNotificationSelectors];
    
    [self hideModelRefreshActivityView];
    
    [self activate];
}

@end
