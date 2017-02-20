//
//  NSObject+Notification.h
//  BassBlog
//
//  Created by Evgeny Sivko on 02/12/2012.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

// Implementation performs NSNotification management on main thread always!

@interface NSObject (Notification)

#pragma mark - Listening

- (void)addSelector:(SEL)selector forNotificationWithName:(nullable NSNotificationName)name;

- (void)removeSelectorForNotificationWithName:(nullable NSNotificationName)name;

- (void)removeNotificationSelectors;

#pragma mark - Posting

#pragma mark * Sync

- (void)postNotification:(NSNotification *)notification;

- (void)postNotificationWithName:(nullable NSNotificationName)name;

- (void)postNotificationWithName:(nullable NSNotificationName)name
                        userInfo:(NSDictionary *)userInfo;
#pragma mark * Async

- (void)postAsyncNotification:(NSNotification *)notification;

- (void)postAsyncNotificationWithName:(nullable NSNotificationName)name;

- (void)postAsyncNotificationWithName:(nullable NSNotificationName)name
                             userInfo:(NSDictionary *)userInfo;
@end

NS_ASSUME_NONNULL_END
