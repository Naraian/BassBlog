//
//  BBMixesJSONParser.m
//  BassBlog
//
//  Created by Evgeny Sivko on 30.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesJSONParser.h"

#import "NSString+HTML.h"

#import "BBLog.h"


static NSString *const BBMixIDJSONKey        = @"id";
static NSString *const BBMixNameJSONKey      = @"name";
static NSString *const BBMixUrlJSONKey       = @"mp3";
static NSString *const BBMixDateJSONKey      = @"date";
static NSString *const BBMixBitrateJSONKey   = @"bitrate";
static NSString *const BBMixTracklistJSONKey = @"tracklist";
static NSString *const BBMixTagsJSONKey      = @"labels";
static NSString *const BBMixUpdatedJSONKey   = @"updated";
static NSString *const BBMixDeletedJSONKey   = @"trash";

static const float BBProgressDelta = 0.05f; // 5%

@interface BBMixesJSONParser ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSRegularExpression *bitrateRegularExpression;

@end

@implementation BBMixesJSONParser

+ (BBMixesJSONParser *)parserWithData:(NSData *)data
{
    return [[self alloc] initWithData:data];
}

- (id)initWithData:(NSData *)data
{
    if (!data.length)
    {
        ERR(@"Empty \"data\" (%@)", data);
        
        return nil;
    }
    
    self = [super init];
    
    if (self)
    {
        if (!self.dateFormatter || !self.bitrateRegularExpression)
        {
            return nil;
        }
        
        self.data = data;
    }
    
    return self;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    
    return _dateFormatter;
}

- (NSRegularExpression *)bitrateRegularExpression
{
    if (!_bitrateRegularExpression)
    {
        NSError *__autoreleasing error = nil;
        _bitrateRegularExpression =
        [[NSRegularExpression alloc] initWithPattern:@"\\S*(\\d*)\\S*"
                                             options:NSRegularExpressionCaseInsensitive
                                               error:&error];
        if (error)
        {
            ERR(@"Couldn't create regular expression due (%@)", error);
        }
    }
    
    return _bitrateRegularExpression;
}

- (void)parseWithMixBlock:(BBMixesJSONParserMixBlock)mixBlock
            progressBlock:(void(^)(float progress))progressBlock
          completionBlock:(void(^)(NSInteger updated))completionBlock
{
    NSAssert(mixBlock, @"Mix block == nil in %s", __FUNCTION__);
    
    NSAssert(completionBlock, @"Completion block == nil in %s", __FUNCTION__);
    
    NSError *__autoreleasing error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:_data
                                              options:kNilOptions
                                                error:&error];
    if (json == nil) {
        
        ERR(@"Couldn't create JSON object due (%@)", error);
        return;
    }
    
    if ([json isKindOfClass:[NSArray class]] == NO) {
        
        ERR(@"JSON object (%@) not an array!", [json class]);
        return;
    }
    
    NSArray *jsonArray = (NSArray*)json;
    
    NSUInteger mixesCount = [jsonArray count];
    NSUInteger mixIdxProgressDelta = mixesCount * BBProgressDelta;
    __block NSUInteger mixIdxToReportProgress = mixIdxProgressDelta;
    if (progressBlock == nil) {
        mixIdxToReportProgress = mixesCount;
    }
    
    [jsonArray enumerateObjectsUsingBlock:^(id mix, NSUInteger mixIdx, BOOL *mixStop) {

#ifdef DEBUG
        
        if (![mix isKindOfClass:[NSDictionary class]]) {
            
            ERR(@"JSON item (%@) not a dictionary!", [mix class]);
            
            *mixStop = YES;
            return;
        }
#endif
        
        NSDictionary *mixDictionary = (NSDictionary*)mix;
    
        NSString *ID = [[mixDictionary objectForKey:BBMixIDJSONKey] stringValue];
        NSString *url = [mixDictionary objectForKey:BBMixUrlJSONKey];
        NSString *name = [mixDictionary objectForKey:BBMixNameJSONKey];
        
        NSString *tracklist = nil;
        id tracklistObject = [mixDictionary objectForKey:BBMixTracklistJSONKey];
        if ([tracklistObject isKindOfClass:[NSString class]])
        {
            tracklist = [tracklistObject stringByUnescapingFromHTML];
        }
        
        NSInteger bitrate = 0;
        id bitrateObject = [mixDictionary objectForKey:BBMixBitrateJSONKey];
        if ([bitrateObject isKindOfClass:[NSString class]])
        {
            NSString *bitrateString = (NSString *)bitrateObject;
            
            NSRange range = NSMakeRange(0, [bitrateString length]);
            
            bitrateString =
            [_bitrateRegularExpression stringByReplacingMatchesInString:bitrateString
                                                                options:kNilOptions
                                                                  range:range
                                                           withTemplate:@"$1"];
            bitrate = [bitrateString intValue];
        }
        
        NSArray *tags = [[mixDictionary objectForKey:BBMixTagsJSONKey]
                         componentsSeparatedByString:@","];
        
        NSDate *date = [_dateFormatter dateFromString:
                        [mixDictionary objectForKey:BBMixDateJSONKey]];
        
        BOOL deleted = [[mixDictionary objectForKey:BBMixDeletedJSONKey] boolValue];
        
        mixBlock(ID, url, name, tracklist, bitrate, tags, date, deleted);
        
        if (mixIdx >= mixIdxToReportProgress) {
            
            mixIdxToReportProgress += mixIdxProgressDelta;
            
            if (mixIdxToReportProgress >= mixesCount) {
                mixIdxToReportProgress = mixesCount - 1;
            }
            
            progressBlock((float)mixIdx / mixesCount);
        }
    }];
    
    NSDictionary *lastMix = [json lastObject];
    NSInteger updated = [[lastMix objectForKey:BBMixUpdatedJSONKey] intValue];
    
    completionBlock(updated);
}

@end
