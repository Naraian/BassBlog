//
//  NSString+URLEncode.m
//  PushToTalk
//
//  Created by Alexey Akimov on 9/13/12.
//  Copyright (c) 2012 SHAPE. All rights reserved.
//

#import "NSString+URLEncode.h"


@implementation NSString(URLEncode)

- (NSString *)urlEncodedString
{
	CFStringRef str =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (__bridge CFStringRef)self,
                                            NULL,
                                            NULL,
                                            kCFStringEncodingUTF8);
    
	NSString *result = (__bridge NSString *)str;
    
    if (str)
        CFRelease(str);
    
	return result;
}

@end
