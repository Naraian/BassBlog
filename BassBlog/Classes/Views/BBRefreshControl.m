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
#import <objc/runtime.h>
#import <JRSwizzle/JRSwizzle.h>

@interface UIScrollView (BBRefreshControl)

@property (nonatomic, strong) BBRefreshControl *refreshControl;

@end


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

@property (nonatomic, assign) UIEdgeInsets addedContentInset;

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
    
    _scrollView.refreshControl = self;
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

- (void)resetContentInset
{
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top -= _addedContentInset.top;
    contentInset.left -= _addedContentInset.left;
    contentInset.right -= _addedContentInset.right;
    contentInset.bottom -= _addedContentInset.bottom;
    self.scrollView.contentInset = contentInset;
    
    _addedContentInset = UIEdgeInsetsZero;
}

- (void)setAddedContentInset:(UIEdgeInsets)addedInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_addedContentInset, addedInsets))
    {
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        CGPoint contentOffset = self.scrollView.contentOffset;
        
        contentInset.top -= _addedContentInset.top;
        contentInset.left -= _addedContentInset.left;
        contentInset.right -= _addedContentInset.right;
        contentInset.bottom -= _addedContentInset.bottom;
        
        contentInset.top += addedInsets.top;
        contentInset.left += addedInsets.left;
        contentInset.right += addedInsets.right;
        contentInset.bottom += addedInsets.bottom;
        
        
        _addedContentInset = addedInsets;
        
//        _ignoreOffsetChanged = YES;
        self.scrollView.contentInset = contentInset;
//        _ignoreOffsetChanged = NO;
        self.scrollView.contentOffset = contentOffset;
    }
}


- (void)adjustContainerInsetsWithCompletion:(dispatch_block_t)completion
{
    [UIView animateWithDuration:0.5 animations:^
    {
        if (self.refreshing)
        {
            self.addedContentInset = UIEdgeInsetsMake(kBBRefreshControlHeight, 0.f, 0.f, 0.f);
        }
        else
        {
            [self resetContentInset];
        }
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
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        });
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

@implementation UIScrollView (BBRefreshControl)

- (void)setRefreshControl:(BBRefreshControl *)refreshControl
{
    [self.refreshControl removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(refreshControl), refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self insertSubview:refreshControl atIndex:0];
}

- (BBRefreshControl *)refreshControl
{
    return objc_getAssociatedObject(self, @selector(refreshControl));
}

@end

@implementation UITableView (BBRefreshControl)

- (void)setRefreshControl:(BBRefreshControl *)refreshControl
{
    if (self.refreshControl != refreshControl)
    {
        [super setRefreshControl:refreshControl];
        
        [self addSubview:refreshControl];
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSError *error;
        BOOL result = [[self class] jr_swizzleMethod:@selector(layoutSubviews) withMethod:@selector(TNK_layoutSubviews) error:&error];
        if (!result || error)
        {
            NSLog(@"Can't swizzle methods - %@", [error description]);
        }
    });
}

- (void)TNK_layoutSubviews
{
    [self TNK_layoutSubviews]; // this will call viewWillAppear implementation, because we have exchanged them.
    
    // UITableView has a nasty habbit of placing it's section headers below contentInset
    // We aren't changing that behavior, just adjusting for the inset that we added
    
    if (self.refreshControl.addedContentInset.top != 0.0)
    {
        //http://b2cloud.com.au/tutorial/uitableview-section-header-positions/
        const NSUInteger numberOfSections = self.numberOfSections;
        const UIEdgeInsets contentInset = self.contentInset;
        const CGPoint contentOffset = self.contentOffset;
        
        const CGFloat sectionViewMinimumOriginY = contentOffset.y + contentInset.top - self.refreshControl.addedContentInset.top;
        
        //	Layout each header view
        for(NSUInteger section = 0; section < numberOfSections; section++)
        {
            UIView* sectionView = [self headerViewForSection:section];
            
            if(sectionView == nil)
                continue;
            
            const CGRect sectionFrame = [self rectForSection:section];
            
            CGRect sectionViewFrame = sectionView.frame;
            
            sectionViewFrame.origin.y = ((sectionFrame.origin.y < sectionViewMinimumOriginY) ? sectionViewMinimumOriginY : sectionFrame.origin.y);
            
            //	If it's not last section, manually 'stick' it to the below section if needed
            if(section < numberOfSections - 1)
            {
                const CGRect nextSectionFrame = [self rectForSection:section + 1];
                
                if(CGRectGetMaxY(sectionViewFrame) > CGRectGetMinY(nextSectionFrame))
                    sectionViewFrame.origin.y = nextSectionFrame.origin.y - sectionViewFrame.size.height;
            }
            
            [sectionView setFrame:sectionViewFrame];
        }
    }
}

@end
