//
//  BBSettings.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

/*!
 @class
 @abstract      Application settings store.
 @discussion    Class implements methods to get/set user defined and private application's settings.
                This class works with special *.plist file with default settings enumeration for the first application start.
                Class supports iCloud key-value scheme (see "PTTSettings+iCloud.h").
 */
@interface BBSettings : NSObject
{
	NSDictionary *defaultSettingsDictionary;
}

#pragma mark - Singleton

+ (BBSettings *)defaultSettings;

#pragma mark - Default settings

- (void)readDefaultSettingsAtPath:(NSString *)path;

#pragma mark - Getters

+ (id)objectForKey:(NSString *const)key;

+ (id)defaultObjectForKey:(NSString *const)key;

+ (NSString *)stringForKey:(NSString *const)key;

+ (NSArray *)arrayForKey:(NSString *const)key;

+ (NSDictionary *)dictionaryForKey:(NSString *const)key;

+ (NSData *)dataForKey:(NSString *const)key;

+ (NSNumber *)numberForKey:(NSString *const)key;

+ (NSInteger)integerForKey:(NSString *const)key;

+ (float)floatForKey:(NSString *const)key;

+ (double)doubleForKey:(NSString *const)key;

+ (BOOL)boolForKey:(NSString *const)key;

#pragma mark - Setters

+ (void)setObject:(id const)object 
           forKey:(NSString *const)key;

+ (void)setInteger:(const NSInteger)value 
            forKey:(NSString *const)key;

+ (void)setFloat:(const float)value 
          forKey:(NSString *const)key;

+ (void)setDouble:(const double)value 
           forKey:(NSString *const)key;

+ (void)setBool:(const BOOL)value 
         forKey:(NSString *const)key;

+ (void)setDefaultValueForKey:(NSString *const)key;

#pragma mark - Availability

+ (BOOL)hasObjectForKey:(NSString *const)key;

#pragma mark - Synchronization

+ (void)synchronize;

#pragma mark - Reset

+ (void)reset;

@end