//
//  BBLog.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBLog.h"

#import "BBFileManager.h"

#import <stdio.h>


@implementation BBLog

#pragma mark Singleton

+ (BBLog *)defaultLog
{
    static BBLog *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BBLog alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Setters

+ (void)setLogFilesNumber:(NSUInteger)logFilesNumber withSuffix:(NSString *)logSuffix
{
    if (logFilesNumber < 1)
    {
        BB_ERR(@"\"logFilesNumber\" < 1");
        
        return;
    }
    
    if ([logSuffix length] == 0)
    {
        BB_ERR(@"Empty \"logSuffix\" (%@)", logSuffix);
        
        return;
    }
    
    // Create a list of log files.
	NSMutableArray *logNamesArray = [NSMutableArray array];
	NSString *logDirectory = [self logDirectory];
	NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:logDirectory];
	NSString *logName = [directoryEnumerator nextObject];

    while (logName != nil)
	{
		if ([logName hasSuffix:logSuffix])
        {
			[logNamesArray addObject:logName];
        }
        
        logName = [directoryEnumerator nextObject];
    }
		
	// Create current log file and update log files number accordingly.
    NSMutableArray *logPaths = [NSMutableArray arrayWithCapacity:logFilesNumber];    
    [logPaths addObject:[self generateCurrentLogPathWithSuffix:logSuffix]];
    logFilesNumber--;
    
	// After sorting the most recent log will be the last.
	[logNamesArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Delete all logs except log trace count.
    for (NSInteger index = logNamesArray.count - 1; index >= 0; --index)
	{
        logName = [logNamesArray objectAtIndex:index];
        NSString *logPath =  [logDirectory stringByAppendingPathComponent:logName];
		
        if (logFilesNumber > 0)
        {
            [logPaths addObject:logPath];
            
            logFilesNumber--;
        }
        else
        {
            [BBFileManager removeItemAtPath:logPath];
        }
	}
    
	// Update log paths.
    [[self defaultLog] setLogPaths:logPaths];
        
    // Redirect stderr to current log file.
    freopen([[self currentLogPath] UTF8String], "w", stderr);
}

#pragma mark - Getters

+ (NSString *)currentLogPath
{
    return [self logPathAtIndex:0];
}

+ (NSString *)logPathAtIndex:(NSUInteger)index
{
    return [[self defaultLog] logPathAtIndex:index];
}

#pragma mark - Private

- (void)setLogPaths:(NSArray *)array
{
    if (logPathsArray != array)
    {
        logPathsArray = [[NSArray alloc] initWithArray:array];
    }
}

- (NSString *)logPathAtIndex:(NSUInteger)index
{
    if (index >= logPathsArray.count)
    {
        BB_ERR(@"\"index\" is out of bounds [0, %lu)", logPathsArray.count);
        
        return nil;
    }
    
    return [logPathsArray objectAtIndex:index];
}

+ (NSString *)generateCurrentLogPathWithSuffix:(NSString *)suffix
{
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSUInteger calendarComponents = NSYearCalendarUnit 
                                    | NSMonthCalendarUnit 
                                    | NSDayCalendarUnit
                                    | NSHourCalendarUnit 
                                    | NSMinuteCalendarUnit 
                                    | NSSecondCalendarUnit;
    NSDateComponents *currentDateComponents = [gregorianCalendar components:calendarComponents
                                                                   fromDate:[NSDate date]];
    NSString *logName = [NSString stringWithFormat:@"%04ld.%02ld.%02ld-%02ld.%02ld.%02ld-%@",
                         (long)[currentDateComponents year], 
                         (long)[currentDateComponents month],
                         (long)[currentDateComponents day],
                         (long)[currentDateComponents hour],
                         (long)[currentDateComponents minute],
                         (long)[currentDateComponents second],
                         suffix];
    
    NSString *logPath = [[self logDirectory] stringByAppendingPathComponent:logName];    
    
    return logPath;
}

+ (NSString *)logDirectory
{
    return [BBFileManager documentDirectory];
}

@end
