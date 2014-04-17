//
//  BBAboutViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 05.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAboutViewController.h"


@implementation BBAboutViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"MORE", @"");
    
    [self setTabBarItemTitle:self.title
                  imageNamed:@"more_icon"
                         tag:4];
}

-(IBAction)facebookClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/dnb.mix.blog"]];
}

-(IBAction)twitterClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/bass_blog"]];
}

-(IBAction)VkontakteClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vk.com/bass_blog"]];
    
}

-(IBAction)aboutClick:(id)sender
{
    
}

- (IBAction)webSiteClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bassblog.pro"]];
    
}

@end
