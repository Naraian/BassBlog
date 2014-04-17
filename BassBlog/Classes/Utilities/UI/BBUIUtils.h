//
//  BBUIUtils.h
//  BassBlog
//
//  Created by Evgeny Sivko on 26.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

@class BBMix;

@interface BBUIUtils : NSObject

+ (NSString *)tagsStringForMix:(BBMix *)mix;

+ (UIImage *)scaledImage:(UIImage *)image toSize:(CGSize)size;

+ (UIImage *)defaultImageWithSize:(CGSize)size;

+ (UIImage *)defaultImage;

@end
