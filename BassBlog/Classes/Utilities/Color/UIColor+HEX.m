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

@end
