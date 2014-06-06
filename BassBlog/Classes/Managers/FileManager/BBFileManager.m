//
//  BBFileManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBFileManager.h"


@implementation BBFileManager

#pragma mark - System directories

#pragma mark * NSString

+ (NSString *)directoryForSearchPath:(NSSearchPathDirectory)directory
{
    return [NSSearchPathForDirectoriesInDomains(directory,
                                                NSUserDomainMask,
                                                YES) lastObject];
}

+ (NSString *)documentDirectory
{
    return [self directoryForSearchPath:NSDocumentDirectory];
}

+ (NSString *)cachesDirectory
{
    return [self directoryForSearchPath:NSCachesDirectory];
}

+ (NSString *)temporaryDirectory
{
    return NSTemporaryDirectory();
}

#pragma mark * NSURL

+ (NSURL *)documentDirectoryURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    return [[fm URLsForDirectory:NSDocumentDirectory
                       inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Files management

+ (BOOL)removeItemAt:(id)at
{
    NSError __autoreleasing *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL removed = [at isKindOfClass:[NSURL class]]
                 ? [fm removeItemAtURL:at error:&error]
                 : [fm removeItemAtPath:at error:&error];
    if (!removed)
    {
        BB_ERR(@"Couldn't remove item due (%@)", error);
    }
    
    return removed;
}

#pragma mark * NSString

+ (BOOL)removeItemAtPath:(NSString *)path
{
    return [self removeItemAt:path];
}

#pragma mark * NSURL

+ (BOOL)removeItemAtURL:(NSURL *)url
{
    return [self removeItemAt:url];
}

@end
