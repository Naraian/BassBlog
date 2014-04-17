//
//  BBMixesJSONLoader.h
//  BassBlog
//
//  Created by Evgeny Sivko on 31.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface BBMixesJSONLoader : NSObject

- (void)loadWithDataBlock:(void(^)(NSData *data))dataBlock
            progressBlock:(void(^)(float progress))progressBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

+ (NSInteger)requestArgValue;
+ (void)setRequestArgValue:(NSInteger)requestArgValue;

@end
