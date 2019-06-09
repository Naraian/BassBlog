//
//  NSString+URLEncode.m
//  PushToTalk
//
//  Created by Alexey Akimov on 9/13/12.
//  Copyright (c) 2012 SHAPE. All rights reserved.
//

#import "NSString+URLEncode.h"


@implementation NSString(URLEncode)

- (NSString *)urlEncodedString {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
}

@end
