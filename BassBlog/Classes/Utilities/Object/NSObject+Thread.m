//
//  NSObject+Thread.m
//  BassBlog
//
//  Created by Evgeny Sivko on 02.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "NSObject+Thread.h"


@implementation NSObject (Thread)

+ (void)mainThreadBlock:(void(^)(void))block
{
    if ([NSThread isMainThread])
        block();
    else
        dispatch_sync(dispatch_get_main_queue(), block);
}

+ (void)mainThreadAsyncBlock:(void(^)(void))block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
