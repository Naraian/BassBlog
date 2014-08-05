//
//  ProgressPieView.h
//  iO
//
//  Created by Nikita Ivaniushchenko on 9/25/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressPieView : UIView

@property (assign, nonatomic) float lineWidth;

/*
 The color shown for the portion of the progress bar that is filled.
 */
@property (strong, nonatomic) UIColor *progressTintColor;

/*
 The color shown for the portion of the progress bar that is not filled.
 */
@property (strong, nonatomic) UIColor *trackTintColor;

- (void)startAnimating;
- (void)stopAnimating;

@end
