//
//  UIView+ConstraintsExtensions.m
//
//  Created by Nikita Ivaniushchenko on 11/28/13.
//

#import "UIView+ConstraintsExtensions.h"

@implementation UIView (ConstraintsExtensions)

- (void)removeAllConstraints
{
    UIView *theStrongSelf = self;
    
    UIView *theSuperview = theStrongSelf.superview;
    [theStrongSelf removeFromSuperview];
    [theSuperview addSubview:theStrongSelf];
    
    theStrongSelf = nil;
}

@end