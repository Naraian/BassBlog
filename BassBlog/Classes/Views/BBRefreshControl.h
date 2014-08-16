//
//  BBRefreshControl.h
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 7/14/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kBBRefreshControlHeight;

@interface BBRefreshControl : UIControl

- (id)initWithScrollView:(UIScrollView *)scrollView;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (void)beginRefreshing;
- (void)endRefreshing;

- (void)containingScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)containingScrollViewDidScroll:(UIScrollView *)scrollView;

@end
