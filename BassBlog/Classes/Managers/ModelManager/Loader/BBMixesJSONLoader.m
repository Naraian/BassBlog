//
//  BBMixesJSONLoader.m
//  BassBlog
//
//  Created by Evgeny Sivko on 31.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesJSONLoader.h"

#import "RDHTTP.h"

#import "BBOperationManager.h"

#import "BBSettings.h"

#import "BBTimeProfiler.h"
#import "BBMacros.h"


static NSString *const BBMixesJSONRequestUrl = @"http://app.bassblog.pro/json/mixes_list";
static NSString *const BBMixesJSONRequestArg = @"updated";

static const NSTimeInterval kBBMixesJSONRequestInterval = 60;

DEFINE_STATIC_CONST_NSSTRING(BBMixesJSONRequestArgSettingsKey);


@interface BBMixesJSONLoader ()

TIME_PROFILER_PROPERTY_DECLARATION

@end


@implementation BBMixesJSONLoader

TIME_PROFILER_PROPERTY_IMPLEMENTATION

- (void)loadWithDataBlock:(void(^)(NSData *data))dataBlock
            progressBlock:(void(^)(float progress))progressBlock
               errorBlock:(void(^)(NSError *error))errorBlock
{
    RDHTTPRequest *request =
    [RDHTTPRequest getRequestWithURLString:[self.class requestURLString]];
    
    [request setTimeoutInterval:kBBMixesJSONRequestInterval];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setDownloadProgressHandler:progressBlock];
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    TIME_PROFILER_MARK_TIME
    
    NSOperation *operation =
    [request operationWithCompletionHandler:^(RDHTTPResponse *response) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (response.error) {
            
            BB_ERR(@"Couldn't load data due (%@)", response.error);
        
            if (errorBlock) {
                errorBlock(response.error);
            }
            
            return;
        }
        
        static BOOL firstDump = YES;
        
        TIME_PROFILER_LOG(@"Loading JSON")
        
        if (firstDump) {
            BB_DBG(@"\nStatus code: %d\nResponse headers: %@",
                response.statusCode, response.allHeaderFields);
        }
        else {
            BB_DBG(@"Status code: %d", response.statusCode);
        }
        
        if (dataBlock) {
            dataBlock(response.responseData);
        }
        
        firstDump = NO;
    }];
    
    [[BBOperationManager defaultManager] addOperation:operation];
}

+ (NSString *)requestURLString {
    
    return [NSString stringWithFormat:@"%@?%@=%d",
            BBMixesJSONRequestUrl, BBMixesJSONRequestArg, [self requestArgValue]];
}

+ (NSInteger)requestArgValue
{
    return [BBSettings integerForKey:BBMixesJSONRequestArgSettingsKey];
}

+ (void)setRequestArgValue:(NSInteger)requestArgValue
{
    [BBSettings setInteger:requestArgValue
                    forKey:BBMixesJSONRequestArgSettingsKey];
    [BBSettings synchronize];
}

@end
