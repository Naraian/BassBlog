//
//  NSLayoutConstraint+Extensions.m
//
//  Created by Nikita Ivaniushchenko on 11/4/13.
//

#import "NSLayoutConstraint+Extensions.h"

@implementation NSLayoutConstraint (Extensions)

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary *)views
{
    return [self constraintsWithVisualFormat:format
                                     options:0
                                     metrics:nil
                                       views:views];
}

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    return [self constraintsWithVisualFormat:format
                                     options:0
                                     metrics:metrics
                                       views:views];
}

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 priority:(UILayoutPriority)priority
{
    NSLayoutConstraint *theConstraint = [self constraintWithItem:view1 attribute:attribute toItem:view2];
    theConstraint.priority = priority;
    return theConstraint;
}

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2
{
    return [self constraintWithItem:view1
                          attribute:attribute
                             toItem:view2
                           constant:0.f];
}

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 constant:(CGFloat)c
{
    return [self constraintWithItem:view1
                          attribute:attribute
                          relatedBy:NSLayoutRelationEqual
                             toItem:view2
                          attribute:attribute
                         multiplier:1.f
                           constant:c];
}

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute constant:(CGFloat)c
{
    return [self constraintWithItem:view1
                          attribute:attribute
                          relatedBy:NSLayoutRelationEqual
                             toItem:nil
                          attribute:attribute
                         multiplier:1.f
                           constant:c];
}


@end
