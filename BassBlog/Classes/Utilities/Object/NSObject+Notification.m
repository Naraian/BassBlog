//
//  NSObject+Notification.m
//  BassBlog
//
//  Created by Evgeny Sivko on 02/12/2012.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

#import "NSObject+Notification.h"
#import "NSObject+Thread.h"


@implementation NSObject (Notification)

#pragma mark - Listening

- (void)addSelector:(SEL)selector forNotificationWithName:(NSString *)name
{
    [self.class mainThreadBlock:^
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:selector
                                                     name:name
                                                   object:nil];
    }];
}

- (void)removeSelectorForNotificationWithName:(NSString *)name
{
    [self.class mainThreadBlock:^
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:self];
    }];
}

- (void)removeNotificationSelectors
{
    [self.class mainThreadBlock:^
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

#pragma mark - Posting

#pragma mark * Sync

- (void)postNotification:(NSNotification *)notification
{
    [self.class mainThreadBlock:^
    {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
}

- (void)postNotificationWithName:(NSString *)name
{
    [self postNotification:[NSNotification notificationWithName:name
                                                         object:self]];
}

- (void)postNotificationWithName:(NSString *)name
                        userInfo:(NSDictionary *)userInfo
{
    [self postNotification:[NSNotification notificationWithName:name
                                                         object:self
                                                       userInfo:userInfo]];
}

#pragma mark * Async

- (void)postAsyncNotification:(NSNotification *)notification
{
    [self.class mainThreadAsyncBlock:^
    {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
}

- (void)postAsyncNotificationWithName:(NSString *)name
{
    [self postAsyncNotification:[NSNotification notificationWithName:name
                                                              object:self]];
}

- (void)postAsyncNotificationWithName:(NSString *)name
                             userInfo:(NSDictionary *)userInfo
{
    [self postAsyncNotification:[NSNotification notificationWithName:name
                                                              object:self
                                                            userInfo:userInfo]];
}

@end
