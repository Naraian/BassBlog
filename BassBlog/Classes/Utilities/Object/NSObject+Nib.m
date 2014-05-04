//
//  NSObject+Nib.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01/12/2012.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

#import "NSObject+Nib.h"

#import "BBThemeManager.h"


@implementation NSObject (Nib)

+ (id)instanceFromNib:(UINib *)nibOrNil
{
    __block id instance = nil;
    Class expectedClass = [self class];
    UINib *nib = nibOrNil ? nibOrNil : [self nib];
    
    [[nib instantiateWithOwner:nil options:nil] enumerateObjectsUsingBlock:
     ^(NSObject *object, NSUInteger objectIdx, BOOL *objectStop)
    {
        if ([object isKindOfClass:expectedClass])
        {
            instance = object;
            *objectStop = YES;
        }
    }];
    
    if (!instance)
    {
        ERR(@"Couldn't find instance of class (%@)", expectedClass);
    }
    
    return instance;
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self nibName]
                          bundle:nil];
}

+ (NSString *)nibName
{
    NSLog(@"%@", self);
    return NSStringFromClass([self class]);
}

@end
