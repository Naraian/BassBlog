//
//  BBMacros.h
//  BassBlog
//
//  Created by Evgeny Sivko on 31.01.2013.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#ifndef BASS_BLOG_MACROS_H
#define BASS_BLOG_MACROS_H


// For settings key/other const strings implementation.

#define DEFINE_CONST_NSSTRING(name) NSString * const name = @#name

#define DEFINE_STATIC_CONST_NSSTRING(name) static DEFINE_CONST_NSSTRING(name)

// For singleton implementation.

#define SINGLETON_IMPLEMENTATION(className, methodName) \
+ (className *)methodName \
{ \
    static className *sharedInstance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^ { sharedInstance = [className new]; }); \
    return sharedInstance; \
}

#endif // BASS_BLOG_MACROS_H
