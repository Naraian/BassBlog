//
//  BBFont.h
//  BassBlog
//
//  Created by Evgeny Sivko on 04.09.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface BBFont : UIFont

+ (UIFont *)fontOfSize:(CGFloat)fontSize;

+ (UIFont *)fontLikeFont:(UIFont *)font;

+ (UIFont *)boldFontOfSize:(CGFloat)fontSize;

+ (UIFont *)boldFontLikeFont:(UIFont *)font;

@end
