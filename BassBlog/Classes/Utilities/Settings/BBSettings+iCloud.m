//
//  BBSettings+iCloud.m
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

#import "BBSettings+iCloud.h"


@implementation BBSettings (iCloud)

#pragma mark - Setters

+ (void)setObject:(id const)value 
           forKey:(NSString *const)key
       ubiquitous:(const BOOL)ubiquitous
{
	if (!key.length)
	{
		BB_ERR(@"Empty \"key\" (%@)", key);
		
        return;
	}
    
	if (value != nil)
    {    
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        
        if (ubiquitous)
        {
            [[NSUbiquitousKeyValueStore defaultStore] setObject:value forKey:key];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        
        if (ubiquitous)
        {
            [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:key];
        }
    }
}

+ (void)setInteger:(const NSInteger)value 
            forKey:(NSString *const)key
        ubiquitous:(const BOOL)ubiquitous
{
    [self setObject:[NSNumber numberWithInteger:value] forKey:key ubiquitous:ubiquitous];
}

+ (void)setFloat:(const float)value 
          forKey:(NSString *const)key
      ubiquitous:(const BOOL)ubiquitous
{
    [self setObject:[NSNumber numberWithFloat:value] forKey:key ubiquitous:ubiquitous];
}

+ (void)setDouble:(const double)value 
           forKey:(NSString *const)key
       ubiquitous:(const BOOL)ubiquitous
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:key ubiquitous:ubiquitous];
}

+ (void)setBool:(const BOOL)value 
         forKey:(NSString *const)key
     ubiquitous:(const BOOL)ubiquitous
{
    [self setObject:[NSNumber numberWithBool:value] forKey:key ubiquitous:ubiquitous];
}

+ (void)setDefaultValueForKey:(NSString *const)key
                   ubiquitous:(BOOL const)ubiquitous
{
    id defaultObject = [self defaultObjectForKey:key];
    if (defaultObject)
    {
        [self setObject:defaultObject forKey:key ubiquitous:ubiquitous];
    }
}

#pragma mark - Synchronization

+ (void)synchronizeUbiquitous:(BOOL const)ubiquitous
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (ubiquitous)
    {
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
}

#pragma mark - Reset

+ (void)resetUbiquitous:(const BOOL)ubiquitous
{
    [NSUserDefaults resetStandardUserDefaults];
    
    if (ubiquitous)
    {
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        
        [[store dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:
         ^(NSString *key, id obj, BOOL *stop)
        {
            [store removeObjectForKey:key];
        }];
    }
}

@end
