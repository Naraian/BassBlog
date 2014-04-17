//
//  NSObject+Notification.h
//  BassBlog
//
//  Created by Evgeny Sivko on 02/12/2012.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//


// Implementation performs NSNotification management on main thread always!

@interface NSObject (Notification)

#pragma mark - Listening

- (void)addSelector:(SEL)selector forNotificationWithName:(NSString *)name;

- (void)removeSelectorForNotificationWithName:(NSString *)name;

- (void)removeNotificationSelectors;

#pragma mark - Posting

#pragma mark * Sync

- (void)postNotification:(NSNotification *)notification;

- (void)postNotificationWithName:(NSString *)name;

- (void)postNotificationWithName:(NSString *)name
                        userInfo:(NSDictionary *)userInfo;
#pragma mark * Async

- (void)postAsyncNotification:(NSNotification *)notification;

- (void)postAsyncNotificationWithName:(NSString *)name;

- (void)postAsyncNotificationWithName:(NSString *)name
                             userInfo:(NSDictionary *)userInfo;
@end
