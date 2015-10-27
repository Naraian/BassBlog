//
//  BBSettings.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

#import "BBSettings.h"
#import "BBSettings+iCloud.h"



@interface BBSettings ()

- (id)objectForKey:(NSString *const)key;

+ (id)objectForKey:(NSString *const)key withClass:(Class)theClass;

@end

#pragma mark -

@implementation BBSettings

#pragma mark Singleton

+ (BBSettings *)defaultSettings
{
    static BBSettings *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BBSettings alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Memory management

- (void)readDefaultSettingsAtPath:(NSString *)path
{
    NSError __autoreleasing *error = nil;
    NSData *plistXML = [NSData dataWithContentsOfFile:path 
                                              options:NSDataReadingUncached 
                                                error:&error];
    if (plistXML == nil)
    {
        BB_ERR(@"%@", error);
        
        return;
    }
    
	NSPropertyListFormat format;
    defaultSettingsDictionary = [NSPropertyListSerialization propertyListWithData:plistXML 
                                                                          options:NSPropertyListMutableContainers 
                                                                           format:&format 
                                                                            error:&error];
	if (defaultSettingsDictionary == nil)
	{        
		BB_ERR(@"%@, format: %lu", error, (unsigned long)format);
	}
}

#pragma mark - Getters

+ (id)objectForKey:(NSString *const)key
{    
    return [[self defaultSettings] objectForKey:key];
}

+ (id)defaultObjectForKey:(NSString *const)key
{
    return [[self defaultSettings] defaultObjectForKey:key];
}

+ (NSString *)stringForKey:(NSString *const)key
{
    return [self objectForKey:key withClass:[NSString class]];
}

+ (NSArray *)arrayForKey:(NSString *const)key
{
    return [self objectForKey:key withClass:[NSArray class]];
}

+ (NSDictionary *)dictionaryForKey:(NSString *const)key
{
    return [self objectForKey:key withClass:[NSDictionary class]];
}

+ (NSData *)dataForKey:(NSString *const)key
{
    return [self objectForKey:key withClass:[NSData class]];
}

+ (NSNumber *)numberForKey:(NSString *const)key
{
    return [self objectForKey:key withClass:[NSNumber class]];
}

+ (NSInteger) integerForKey:(NSString* const)key
{
    return [[self numberForKey:key] integerValue];
}

+ (float) floatForKey:(NSString* const)key
{
    return [[self numberForKey:key] floatValue];
}

+ (double) doubleForKey:(NSString* const)key
{
    return [[self numberForKey:key] doubleValue];
}

+ (BOOL) boolForKey:(NSString* const)key
{
    return [[self numberForKey:key] boolValue];
}

#pragma mark - Setters

+ (void)setObject:(id const)value 
           forKey:(NSString *const)key
{
    [self setObject:value forKey:key ubiquitous:NO];
}

+ (void)setInteger:(const NSInteger)value 
            forKey:(NSString *const)key
{
    [self setInteger:value forKey:key ubiquitous:NO];
}

+ (void)setFloat:(const float)value 
          forKey:(NSString *const)key
{
    [self setFloat:value forKey:key ubiquitous:NO];
}

+ (void)setDouble:(const double)value 
           forKey:(NSString *const)key
{
    [self setDouble:value forKey:key ubiquitous:NO];
}

+ (void)setBool:(const BOOL)value 
         forKey:(NSString *const)key
{
    [self setBool:value forKey:key ubiquitous:NO];
}

+ (void)setDefaultValueForKey:(NSString *const)key
{
    [self setDefaultValueForKey:key ubiquitous:NO];
}

#pragma mark - Reset

+ (void) reset
{
    [self resetUbiquitous:NO];
}

#pragma mark - Availability

+ (BOOL) hasObjectForKey:(NSString* const)key
{
    return [self objectForKey:key] != nil;
}

#pragma mark - Synchronization

+ (void) synchronize
{
    [self synchronizeUbiquitous:NO];
}

#pragma mark - Private

- (id)objectForKey:(NSString *const)key
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (setting == nil)
    {
        setting = [self defaultObjectForKey:key];
    }
    
    return setting;
}

- (id)defaultObjectForKey:(NSString *const)key
{
    if (key.length)
    {
        return [defaultSettingsDictionary objectForKey:key];
    }
    
    BB_ERR(@"Empty \"key\" (%@)", key);
    
    return nil;
}

+ (id)objectForKey:(NSString *const)key withClass:(Class)theClass
{
    id object = [[self defaultSettings] objectForKey:key];

    if (object && ![object isKindOfClass:theClass])
    {
        BB_ERR(@"%@ is %@, expected %@", key, [object class], theClass);
        
        object = nil;
    }
    
    return object;
}

@end