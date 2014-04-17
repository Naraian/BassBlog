//
//  BBAnalytics.m
//  BassBlog
//
//  Created by Evgeny Sivko on 15.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAnalytics.h"

#import "Flurry.h"


@implementation BBAnalytics

+ (void)startSession
{
    NSString *appKey =
#ifdef FREE
    @"ZBHFSJ2WSNR5NB65CRQQ";
#else
    @"XJZPM2PVQ99ZJSS3D5C4";
#endif
    
    [Flurry startSession:appKey];
}

@end
