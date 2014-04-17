//
//  NSObject+Thread.h
//  BassBlog
//
//  Created by Evgeny Sivko on 02.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface NSObject (Thread)

+ (void)mainThreadBlock:(void(^)(void))block;

+ (void)mainThreadAsyncBlock:(void (^)(void))block;

@end
