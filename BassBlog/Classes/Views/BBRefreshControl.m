//
//  BBRefreshControl.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 7/14/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBRefreshControl.h"
#import "ProgressPieView.h"
#import "NSLayoutConstraint+Extensions.h"
#import "BBFont.h"
#import "BBThemeManager.h"

const CGFloat kBBRefreshControlHeight = 40.f;
const CGFloat kBBRefreshControlBottomContentMargin = -10.f;

typedef NS_ENUM(NSInteger, BBRefreshControlState)
{
    BBRefreshControlStateDefault = 0,
    BBRefreshControlStateReadyToRefresh,
    BBRefreshControlStateRefreshing,
    BBRefreshControlStateResetting,
};

@interface BBRefreshControl()

@property (nonatomic, assign) BBRefreshControlState refreshState;
@property (nonatomic, strong) ProgressPieView *progressView;
@property (nonatomic, strong) UILabel *customLabel;
@property (nonatomic, strong) UIImageView *leftIndicatorImageView;

@end

@implementation BBRefreshControl

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super initWithFrame:CGRectMake(0.f, 0.f, scrollView.bounds.size.width, 0.f)])
    {
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *overlayView = [UIView new];
        overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:overlayView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(overlayView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]|" views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|" views:views]];
        
        self.progressView = [ProgressPieView new];
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.progressView.backgroundColor = [UIColor clearColor];
        self.progressView.lineWidth = 2.f;
        self.progressView.trackTintColor = [UIColor colorWithHEX:0xEEEEEEFF];
        self.progressView.progressTintColor = [UIColor colorWithHEX:0xF24F4FFF];
        self.progressView.alpha = 0.f;
        [overlayView addSubview:self.progressView];
        
        self.customLabel = [UILabel new];
        self.customLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.customLabel.textAlignment = NSTextAlignmentCenter;
        self.customLabel.font = [BBFont boldFontOfSize:20.f];
        self.customLabel.text = [NSLocalizedString(@"Pull down to refresh", nil) uppercaseString];
        self.customLabel.textColor = [UIColor colorWithHEX:0xFD5D5DFF];
        self.customLabel.numberOfLines = 1;
        [overlayView addSubview:self.customLabel];
        
        NSString *imageName = [@"table_view/cell" stringByAppendingPathComponent:@"mini_arrow"];
        UIImage *arrowImage = [[BBThemeManager defaultManager] imageNamed:imageName];
        
        self.leftIndicatorImageView = [UIImageView new];
        self.leftIndicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftIndicatorImageView.image = arrowImage;
        self.leftIndicatorImageView.contentMode = UIViewContentModeCenter;
        [overlayView addSubview:self.leftIndicatorImageView];
        
        views = NSDictionaryOfVariableBindings(_customLabel, _leftIndicatorImageView, _progressView);
        
        [overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[_leftIndicatorImageView(20)]" views:views]];
        [overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[_progressView(20)]" views:views]];
    
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftIndicatorImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.progressView attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
        
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.customLabel attribute:NSLayoutAttributeCenterX toItem:overlayView]];
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.customLabel attribute:NSLayoutAttributeBottom toItem:overlayView constant:kBBRefreshControlBottomContentMargin]];
        
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeBottom toItem:overlayView constant:kBBRefreshControlBottomContentMargin]];
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.leftIndicatorImageView attribute:NSLayoutAttributeBottom toItem:overlayView constant:kBBRefreshControlBottomContentMargin]];
        
        self.scrollView = scrollView;
    }
    
    return self;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    [_scrollView addSubview:self];
}

- (void)beginRefreshing
{
    if ((self.refreshState != BBRefreshControlStateDefault) &&
        (self.refreshState != BBRefreshControlStateReadyToRefresh))
    {
        return;
    }
    
    self.refreshState = BBRefreshControlStateRefreshing;
}

- (void)setRefreshState:(BBRefreshControlState)refreshState
{
    dispatch_block_t updateBlock = ^
    {
        switch (refreshState)
        {
            case BBRefreshControlStateDefault:
                self.leftIndicatorImageView.alpha = 1.f;
                self.progressView.alpha = 0.f;
                [self.progressView stopAnimating];
                self.customLabel.text = [NSLocalizedString(@"Pull down to refresh…", nil) uppercaseString];
                break;
            case BBRefreshControlStateReadyToRefresh:
                self.customLabel.text = [NSLocalizedString(@"Release to refresh…", nil) uppercaseString];
                break;
            case BBRefreshControlStateRefreshing:
                self.leftIndicatorImageView.alpha = 0.f;
                self.progressView.alpha = 1.f;
                [self.progressView startAnimating];
                self.customLabel.text = [NSLocalizedString(@"Checking updates…", nil) uppercaseString];
                break;
            case BBRefreshControlStateResetting:
                self.customLabel.text = [NSLocalizedString(@"Updated", nil) uppercaseString];
                break;
            default:
                break;
        }
    };
    
    dispatch_block_t insetAdjustmentCompletion = nil;
    
    BOOL adjustInsets = NO;
    
    if ((refreshState == BBRefreshControlStateRefreshing) &&
        ((_refreshState == BBRefreshControlStateDefault) || (_refreshState == BBRefreshControlStateReadyToRefresh)))
    {
        adjustInsets = YES;
    }
    else if ((refreshState == BBRefreshControlStateResetting) &&
             (_refreshState == BBRefreshControlStateRefreshing))
    {
        adjustInsets = YES;
        
        insetAdjustmentCompletion = ^
        {
            self.refreshState = BBRefreshControlStateDefault;
        };
    }
        
    _refreshState = refreshState;
    
    if (adjustInsets)
    {
        [self adjustContainerInsetsWithCompletion:insetAdjustmentCompletion];
    }
    
    updateBlock();
}

- (BOOL)isRefreshing
{
    return (self.refreshState == BBRefreshControlStateRefreshing);
}

- (void)endRefreshing
{
    if (self.refreshState != BBRefreshControlStateRefreshing)
    {
        return;
    }
    
    self.refreshState = BBRefreshControlStateResetting;
}

- (void)adjustContainerInsetsWithCompletion:(dispatch_block_t)completion
{
    CGFloat difference = self.refreshing ? kBBRefreshControlHeight : -kBBRefreshControlHeight;
    
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    
    UIEdgeInsets contentInsets = scrollView.contentInset;
    contentInsets.top += difference;
    
    [UIView animateWithDuration:0.5 animations:^
    {
        scrollView.contentInset = contentInsets;
    }
    completion:^(BOOL finished)
    {
        if (completion)
        {
            completion();
        }
    }];
}

- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (self.didUserScrollFarEnoughToTriggerRefresh)
    {
        [self beginRefreshing];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = -self.distanceScrolled;
    
    if (offset > kBBRefreshControlHeight && scrollView.isDragging)
    {
        self.refreshState = BBRefreshControlStateReadyToRefresh;
    }
    
    [self setOffset:offset];
}

- (BOOL)didUserScrollFarEnoughToTriggerRefresh
{
    return (-self.distanceScrolled > kBBRefreshControlHeight);
}

- (CGFloat)distanceScrolled
{
    return (self.scrollView.contentOffset.y + self.scrollView.contentInset.top);
}

- (void)setOffset:(CGFloat)offset
{
    CGFloat proportionOfMaxOffset = MIN(offset/(2.f * kBBRefreshControlHeight), 1.f);
    CGFloat angleToRotate = M_PI * proportionOfMaxOffset;
    
    self.leftIndicatorImageView.transform = CGAffineTransformMakeRotation(angleToRotate);
    
    if ((self.refreshState != BBRefreshControlStateDefault) &&
        (self.refreshState != BBRefreshControlStateReadyToRefresh))
    {
        offset += kBBRefreshControlHeight;
    }
    
    CGRect newFrame = self.frame;
    newFrame.size.height = offset;
    newFrame.origin.y = -offset;
    self.frame = newFrame;
    
    [self layoutIfNeeded];
}

@end
