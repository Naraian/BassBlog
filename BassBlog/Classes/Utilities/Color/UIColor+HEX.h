//
//  UIColor+HEX.h
//  BassBlog
//
//  Created by Evgeny Sivko on 10.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface UIColor (HEX)

+ (UIColor *)colorWithHEX:(NSUInteger)hex;

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize;

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize
                borderColor:(UIColor *)aBorderColor borderWidth:(CGFloat)aBorderWidth
               borderRadius:(CGFloat)aRadius;

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize
                borderColor:(UIColor *)aBorderColor borderWidth:(CGFloat)aBorderWidth
               borderRadius:(CGFloat)aRadius borderInset:(CGFloat)aBorderInset;

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)aBezierPath color:(UIColor *)aColor andSize:(CGSize)aSize borderColor:(UIColor *)aBorderColor;

@end
