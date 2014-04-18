//
//  NSLayoutConstraint+Extensions.h
//
//  Created by Nikita Ivaniushchenko on 11/4/13.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Extensions)

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary *)views;
+ (NSArray *)constraintsWithVisualFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 priority:(UILayoutPriority)priority;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 constant:(CGFloat)c;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute constant:(CGFloat)c;

@end
