//
//  BBUIUtils.m
//  BassBlog
//
//  Created by Evgeny Sivko on 26.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBUIUtils.h"

#import "BBTag.h"
#import "BBMix.h"

@implementation BBUIUtils

+ (NSString *)tagsStringForMix:(BBMix *)mix {
    
    return [[[BBTag formalNamesOfTags:mix.tags] allObjects] componentsJoinedByString:@", "];
}

+ (UIImage *)scaledImage:(UIImage *)image toSize:(CGSize)size {
    
#warning TODO: implement...
    
    return nil;
}

+ (UIImage *)defaultImageWithSize:(CGSize)size {
    
    return [self scaledImage:[self defaultImage] toSize:size];
}

+ (UIImage *)defaultImage {
    
    return [UIImage imageNamed:@"default_image"];
}

@end
