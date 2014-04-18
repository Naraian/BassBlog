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
    [theStrongSelf safeRemoveFromSuperview];
    [theSuperview addSubview:theStrongSelf];
    
    theStrongSelf = nil;
}

- (void)safeRemoveFromSuperview
{
    if (!RUNNING_ON_IOS7)
    {
        // Another "dirty" fix for removing constraints in cases when there is no window for this view
        NSMutableArray *constraintsToRemove = [NSMutableArray new];
        // remove all constraints of superview...
        for (NSLayoutConstraint *constraint in self.superview.constraints)
        {
            // ...that refer to our view...
            if (constraint.firstItem == self || constraint.secondItem == self)
            {
                [constraintsToRemove addObject:constraint];
            }
            // ...so that constraints, specific to our view only (like fixed width or height) remain unchanged
        }
        
        [self.superview removeConstraints:constraintsToRemove];
    }

    [self removeFromSuperview];
}

@end