//
//  BBMixesJSONParser.h
//  BassBlog
//
//  Created by Evgeny Sivko on 30.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

typedef void(^BBMixesJSONParserMixBlock)(NSString *ID,
                                         NSString *url,
                                         NSString *name,
                                         NSString *tracklist,
                                         NSInteger bitrate,
                                         NSArray *tags,
                                         NSDate *date,
                                         BOOL deleted);
@interface BBMixesJSONParser : NSObject

+ (BBMixesJSONParser *)parserWithData:(NSData *)data;

- (void)parseWithMixBlock:(BBMixesJSONParserMixBlock)mixBlock
            progressBlock:(void(^)(float progress))progressBlock
          completionBlock:(void(^)(NSInteger updated))completionBlock;
@end
