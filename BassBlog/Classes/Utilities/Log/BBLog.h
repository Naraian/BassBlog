//
//  BBLog.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#pragma mark Log channels

#define BB_INF(fmt, ...) NSLog((@"%s (INFO) " fmt), __func__, ##__VA_ARGS__)
#define BB_ERR(fmt, ...) NSLog((@"%s (ERROR) " fmt), __func__, ##__VA_ARGS__)
#define BB_WRN(fmt, ...) NSLog((@"%s (WARNING) " fmt), __func__, ##__VA_ARGS__)

#ifdef BB_EXT_LOG
#define BB_DBG(fmt, ...) NSLog((@"%s (DEBUG) " fmt), __func__, ##__VA_ARGS__)
#else
#define BB_DBG(...)
#endif

#pragma mark -

@class NSArray;
@class NSString;

@interface BBLog : NSObject
{
    NSArray *logPathsArray;
}

#pragma mark - Setters

+ (void)setLogFilesNumber:(NSUInteger)logFilesNumber withSuffix:(NSString *)logSuffix;

#pragma mark - Getters

+ (NSString *)currentLogPath;

+ (NSString *)logPathAtIndex:(NSUInteger)index;

@end
