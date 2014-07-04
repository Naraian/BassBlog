//
//  UIColor+HEX.m
//  BassBlog
//
//  Created by Evgeny Sivko on 10.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "UIColor+HEX.h"


#define BYTE_TO_FLOAT(color) (color) / 255.f

@implementation UIColor (HEX)

+ (UIColor *)colorWithHEX:(NSUInteger)hex
{
    return [UIColor colorWithRed:BYTE_TO_FLOAT((hex & 0xFF000000) >> 24)
                           green:BYTE_TO_FLOAT((hex & 0x00FF0000) >> 16)
                            blue:BYTE_TO_FLOAT((hex & 0x0000FF00) >> 8)
                           alpha:BYTE_TO_FLOAT((hex & 0x000000FF) >> 0)];
}

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize
{
    return [self imageWithColor:aColor andSize:aSize borderColor:nil borderWidth:0.f borderRadius:0.f];
}

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize borderColor:(UIColor *)aBorderColor borderWidth:(CGFloat)aBorderWidth borderRadius:(CGFloat)aRadius borderInset:(CGFloat)aBorderInset
{
    if (!aBorderColor)
    {
        aBorderWidth = 0.f;
    }
    
    UIBezierPath *thePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(aBorderInset, aBorderInset, aSize.width - 2.f * aBorderInset, aSize.height - 2.f * aBorderInset) cornerRadius:aRadius];
    thePath.lineWidth = aBorderWidth;
    
    return [self imageWithBezierPath:thePath color:aColor andSize:aSize borderColor:aBorderColor];
}

+ (UIImage *)imageWithColor:(UIColor *)aColor andSize:(CGSize)aSize borderColor:(UIColor *)aBorderColor borderWidth:(CGFloat)aBorderWidth borderRadius:(CGFloat)aRadius
{
    return [self imageWithColor:aColor andSize:aSize borderColor:aBorderColor borderWidth:aBorderWidth borderRadius:aRadius borderInset:0.f];
}

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)aBezierPath color:(UIColor *)aColor andSize:(CGSize)aSize borderColor:(UIColor *)aBorderColor
{
    UIGraphicsBeginImageContextWithOptions(aSize, NO, 0.f);
    
    if (aColor)
    {
        [aColor setFill];
        [aBezierPath fill];
    }
    
    if (aBorderColor)
    {
        [aBorderColor setStroke];
        [aBezierPath stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
