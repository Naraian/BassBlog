//
//  BBRefreshControl.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 7/14/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBRefreshControl.h"
#import "NSLayoutConstraint+Extensions.h"
#import "BBFont.h"
#import "BBThemeManager.h"

@interface BBRefreshControl()

@property (nonatomic, strong) UILabel *customLabel;
@property (nonatomic, strong) UIImageView *leftIndicatorImageView;
@property (nonatomic, strong) UIImageView *rightIndicatorImageView;

@end

@implementation BBRefreshControl

- (instancetype)init
{
    if (self = [super init])
    {
        [self addTarget:self action:@selector(refreshingStateChaged) forControlEvents:UIControlEventValueChanged];
        
        UIView *overlayView = [UIView new];
        overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        overlayView.backgroundColor = [UIColor colorWithHEX:0xFFFAFAFF];
        [self addSubview:overlayView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(overlayView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]|" views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView]|" views:views]];
        
        self.customLabel = [UILabel new];
        self.customLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.customLabel.textAlignment = NSTextAlignmentCenter;
        self.customLabel.font = [BBFont boldFontOfSize:20.f];
        self.customLabel.text = [NSLocalizedString(@"Pull down to refresh", nil) uppercaseString];
        self.customLabel.textColor = [UIColor colorWithHEX:0xFD5D5DFF];
        self.customLabel.numberOfLines = 1;
        [overlayView addSubview:self.customLabel];
        
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.customLabel attribute:NSLayoutAttributeCenterX toItem:overlayView]];
        [overlayView addConstraint:[NSLayoutConstraint constraintWithItem:self.customLabel attribute:NSLayoutAttributeCenterY toItem:overlayView]];
        
        NSString *imageName = [@"table_view/cell" stringByAppendingPathComponent:@"mini_arrow"];
        UIImage *arrowImage = [[BBThemeManager defaultManager] imageNamed:imageName];
        
        self.leftIndicatorImageView = [UIImageView new];
        self.leftIndicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftIndicatorImageView.image = arrowImage;
        self.leftIndicatorImageView.contentMode = UIViewContentModeCenter;
        [overlayView addSubview:self.leftIndicatorImageView];
        
        self.rightIndicatorImageView = [UIImageView new];
        self.rightIndicatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightIndicatorImageView.image = arrowImage;
        self.rightIndicatorImageView.contentMode = UIViewContentModeCenter;
        [overlayView addSubview:self.rightIndicatorImageView];
        
        views = NSDictionaryOfVariableBindings(_customLabel, _leftIndicatorImageView, _rightIndicatorImageView);
        [overlayView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(30)-[_leftIndicatorImageView(10)]-[_customLabel]-[_rightIndicatorImageView(10)]-(30)-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    }
    return self;
}

- (void)refreshingStateChaged
{
    if (self.isRefreshing)
    {
        CABasicAnimation *leftAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        leftAnimation.duration = 0.5;
        leftAnimation.fromValue = @(0.0);
        leftAnimation.toValue = @(M_PI);
        leftAnimation.autoreverses = NO;
        leftAnimation.removedOnCompletion = NO;
        leftAnimation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *rightAnimation = [leftAnimation copy];
        rightAnimation.toValue = @(-M_PI);
        
        [self.leftIndicatorImageView.layer addAnimation:leftAnimation forKey:nil];
        [self.rightIndicatorImageView.layer addAnimation:rightAnimation forKey:nil];
        
        [UIView transitionWithView:self duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
        {
            self.customLabel.text = [NSLocalizedString(@"Loading", nil) uppercaseString];
        }
        completion:nil];
    }
}

- (void)endRefreshing
{
    [super endRefreshing];
    
    [self.leftIndicatorImageView.layer removeAllAnimations];
    [self.rightIndicatorImageView.layer removeAllAnimations];
    
    CABasicAnimation* leftAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    leftAnimation.duration = 0.5;
    leftAnimation.fromValue = @(M_PI);
    leftAnimation.toValue = @(0.f);
    leftAnimation.autoreverses = NO;
    leftAnimation.removedOnCompletion = YES;
    
    CABasicAnimation *rightAnimation = [leftAnimation copy];
    rightAnimation.fromValue = @(-M_PI);
    rightAnimation.toValue = @(0.f);
    
    [self.leftIndicatorImageView.layer addAnimation:leftAnimation forKey:nil];
    [self.rightIndicatorImageView.layer addAnimation:rightAnimation forKey:nil];
    
    [UIView transitionWithView:self duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
    {
        self.customLabel.text = [NSLocalizedString(@"Pull down to refresh", nil) uppercaseString];
    }
    completion:nil];
    
}

@end
