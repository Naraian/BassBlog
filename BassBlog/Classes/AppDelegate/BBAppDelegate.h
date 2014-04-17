//
//  BBAppDelegate.h
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@class BBRootViewController;

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

+ (BBRootViewController *)rootViewController;

+ (BBAppDelegate *)instance;

@end
