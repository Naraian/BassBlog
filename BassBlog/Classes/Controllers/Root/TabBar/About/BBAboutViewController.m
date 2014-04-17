//
//  BBAboutViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 05.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAboutViewController.h"


@implementation BBAboutViewController

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = NSLocalizedString(@"MORE", @"");
        
        [self setTabBarItemTitle:self.title
                      imageNamed:@"more_icon"
                             tag:4];
    }
    
    return self;
}

@end
