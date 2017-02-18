//
//  BBThemeManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 09.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//


typedef NS_ENUM(NSInteger, BBTheme)
{
    BBThemeDefault,
    BBNumberOfThemes
};

#define BBThemeManagerTabBarTintColor           [UIColor colorWithHEX:0xF45D5DFF]
#define BBThemeManagerBarBarTintColor           [UIColor colorWithHEX:0xFAFAFAFF]
#define BBThemeManagerSliderLineColor           [UIColor colorWithHEX:0xDFDFDFFF]

extern NSString *const BBThemeManagerDidToggleThemeNotification;

@interface BBThemeManager : NSObject

@property (nonatomic, assign) BBTheme theme;

+ (BBThemeManager *)defaultManager;

- (NSString *)themeName;

- (BBTheme)nextTheme;

- (BBTheme)prevTheme;

#pragma mark - UI

- (UIImage *)imageNamed:(NSString *)name;

- (UIColor *)colorWithPatternImageNamed:(NSString *)name;

@end
