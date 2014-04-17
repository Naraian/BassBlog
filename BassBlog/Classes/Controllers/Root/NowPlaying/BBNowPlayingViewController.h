//
//  BBNowPlayingViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBViewController.h"


@class BBMix;

@interface BBNowPlayingViewController : BBViewController

@property (nonatomic, strong) BBMix *mix;

- (void)activate;

@end
