//
//  BBSettings+iCloud.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.08.12.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

#import "BBSettings.h"


@interface BBSettings (iCloud)

#pragma mark - Setters

+ (void)setObject:(id const)object 
           forKey:(NSString *const)key
       ubiquitous:(BOOL const)ubiquitous;

+ (void)setInteger:(const NSInteger)value 
            forKey:(NSString *const)key
        ubiquitous:(BOOL const)ubiquitous;

+ (void)setFloat:(const float)value 
          forKey:(NSString *const)key
      ubiquitous:(BOOL const)ubiquitous;

+ (void)setDouble:(const double)value 
           forKey:(NSString *const)key
       ubiquitous:(BOOL const)ubiquitous;

+ (void)setBool:(const BOOL)value 
         forKey:(NSString *const)key
     ubiquitous:(BOOL const)ubiquitous;

+ (void)setDefaultValueForKey:(NSString *const)key
                   ubiquitous:(BOOL const)ubiquitous;

#pragma mark - Synchronization

+ (void)synchronizeUbiquitous:(BOOL const)ubiquitous;

#pragma mark - Reset

+ (void)resetUbiquitous:(BOOL const)ubiquitous;

@end
