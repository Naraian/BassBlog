//
//  BBAppDelegate.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAppDelegate.h"

#import "BBRootViewController.h"

#import "BBThemeManager.h"

#import "BBFont.h"
#import "BBUIUtils.h"


@implementation BBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    
//    self.window.rootViewController = [BBRootViewController new];
    
    [self.window makeKeyAndVisible];
    
    [BBAnalytics startSession];
    
    return YES;
}

+ (BBRootViewController *)rootViewController
{
    return (BBRootViewController *)(self.instance.window.rootViewController);
}

+ (BBAppDelegate *)instance
{
    return (BBAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
