//
//  BBThemeManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBThemeManager.h"

#import "NSObject+Notification.h"

#import "BBMacros.h"


DEFINE_CONST_NSSTRING(BBThemeManagerDidToggleThemeNotification);

@interface BBThemeManager ()
{
    NSArray *_themeNames;
    NSArray *_bundleNames;
}

@end

@implementation BBThemeManager

SINGLETON_IMPLEMENTATION(BBThemeManager, defaultManager)

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _themeNames = @[@"Black"];
        _bundleNames = @[@"BlackTheme.bundle"];
    }
    
    return self;
}

- (NSString *)themeName
{
    return [_themeNames objectAtIndex:_theme];
}

- (NSString *)bundleName
{
    return [_bundleNames objectAtIndex:_theme];
}

- (BBTheme)nextTheme
{
    if (++_theme >= BBNumberOfThemes) {
        _theme = 0;
    }
    
    [self postNotificationWithName:BBThemeManagerDidToggleThemeNotification];
    
    return _theme;
}

- (BBTheme)prevTheme
{
    if (--_theme < 0) {
        _theme = BBNumberOfThemes - 1;
    }
    
    [self postNotificationWithName:BBThemeManagerDidToggleThemeNotification];
    
    return _theme;
}

#pragma mark - UI

- (UIImage *)imageNamed:(NSString *)name {
    
    NSString *fullName = [[self bundleName] stringByAppendingPathComponent:name];
    
    return [UIImage imageNamed:fullName];
}

- (UIColor *)colorWithPatternImageNamed:(NSString *)name {
    
    return [UIColor colorWithPatternImage:[self imageNamed:name]];
}

@end
