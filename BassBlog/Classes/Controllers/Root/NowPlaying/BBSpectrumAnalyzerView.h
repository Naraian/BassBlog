//
//  BBSpectrumAnalyzerView.h
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/28/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSpectrumAnalyzerView : UIView

@property (nonatomic, strong) UIColor *barBackgroundColor;
@property (nonatomic, strong) UIColor *barFillColor;

@property (nonatomic, assign) CGFloat columnMargin;
@property (nonatomic, assign) CGFloat columnWidth;
@property (nonatomic, assign) BOOL showsBlocks;

@end
