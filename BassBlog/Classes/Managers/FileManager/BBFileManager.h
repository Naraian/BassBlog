//
//  BBFileManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 09.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface BBFileManager : NSObject

#pragma mark - System directories

+ (NSString *)directoryForSearchPath:(NSSearchPathDirectory)directory;

+ (NSString *)documentDirectory;
+ (NSURL *)documentDirectoryURL;

+ (NSString *)cachesDirectory;

+ (NSString *)temporaryDirectory;

#pragma mark - Files management

+ (BOOL)removeItemAtPath:(NSString *)path;
+ (BOOL)removeItemAtURL:(NSURL *)url;

@end
