//
//  UIView+ConstraintsExtensions.h
//
//  Created by Nikita Ivaniushchenko on 11/28/13.
//

#import <UIKit/UIKit.h>

@interface UIView (ConstraintsExtensions)

- (void)removeAllConstraints;
- (void)safeRemoveFromSuperview;

@end
