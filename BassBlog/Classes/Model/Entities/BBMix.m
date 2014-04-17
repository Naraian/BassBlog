//
//  BBMix.m
//  BassBlog
//
//  Created by Evgeny Sivko on 29.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMix+Service.h"

#import "BBTag.h"

#import "NSObject+Notification.h"

#import "BBMacros.h"

#import <CoreData/NSFetchRequest.h>


DEFINE_CONST_NSSTRING(BBMixDidChangeLocalUrlNotification);
DEFINE_CONST_NSSTRING(BBMixDidChangePlaybackDateNotification);
DEFINE_CONST_NSSTRING(BBMixDidChangeFavoriteNotification);

static NSString *const BBMixLocalUrlKey = @"localUrl";
static NSString *const BBMixFavoriteKey = @"favorite";
static NSString *const BBMixPlaybackDateKey = @"playbackDate";

#pragma mark -

@interface BBMix (PrimitiveAccessors)

- (void)setPrimitiveLocalUrl:(NSString *)localUrl;
- (NSString *)primitiveLocalUrl;

- (void)setPrimitivePlaybackDate:(NSDate *)playbackDate;
- (NSDate *)primitivePlaybackDate;

- (void)setPrimitiveFavorite:(BOOL)favorite;
- (BOOL)primitiveFavorite;

@end

#pragma mark -

@implementation BBMix

@dynamic ID;
@dynamic url;
@dynamic name;
@dynamic date;
@dynamic tags;
@dynamic bitrate;
@dynamic localUrl;
@dynamic favorite;
@dynamic tracklist;
@dynamic playbackDate;

#pragma mark -

- (NSString *)key {
    
    return self.ID;
}

- (void)setLocalUrl:(NSString *)localUrl {
    
    [self willChangeValueForKey:BBMixLocalUrlKey];
    
    [self setPrimitiveLocalUrl:localUrl];
    
    [self didChangeValueForKey:BBMixLocalUrlKey];
    
    [self postNotificationWithName:BBMixDidChangeLocalUrlNotification];
}

- (void)setFavorite:(BOOL)favorite {
    
    [self willChangeValueForKey:BBMixFavoriteKey];
    
    [self setPrimitiveFavorite:favorite];
    
    [self didChangeValueForKey:BBMixFavoriteKey];
    
    [self postNotificationWithName:BBMixDidChangeFavoriteNotification];
}

- (void)setPlaybackDate:(NSDate *)playbackDate {
    
    [self willChangeValueForKey:BBMixPlaybackDateKey];
    
    [self setPrimitivePlaybackDate:playbackDate];
    
    [self didChangeValueForKey:BBMixPlaybackDateKey];
    
    [self postNotificationWithName:BBMixDidChangePlaybackDateNotification];
}

@end

#pragma mark -

@implementation BBMix (Service)

#pragma mark Fetch

+ (NSFetchRequest *)fetchRequestWithCategory:(BBMixesCategory)category
                             substringInName:(NSString *)substringInName
                                         tag:(BBTag *)tag
{
    NSMutableString *format = [NSMutableString string];
    NSMutableArray *arguments = [NSMutableArray array];
    
    switch (category)
    {
        case eDownloadedMixesCategory:
            [format appendString:[self downloadedPredicateFormat]];
            break;
            
        case eFavoriteMixesCategory:
            [format appendString:[self favoritePredicateFormat]];
            break;
            
        case eListenedMixesCategory:
            [format appendString:[self listenedPredicateFormat]];
            break;
            
        default:
            break;
    }
    
    if (tag)
    {
        if (format.length)
            [format appendString:@" && "];
        
        [format appendString:@"ANY tags == %@"];
        [arguments addObject:tag];
    }
    
    if (substringInName.length)
    {
        if (format.length)
            [format appendString:@" && "];
        
        [format appendString:@"name CONTAINS[c] %@"];
        [arguments addObject:substringInName];
    }
    
    return [self fetchRequestWithPredicateFormat:format
                                   argumentArray:arguments];
}

+ (NSFetchRequest *)fetchRequestWithID:(NSString *)ID
{
    return [self fetchRequestWithPredicateFormat:@"ID == %@", ID];
}

+ (NSFetchRequest *)withoutTagsFetchRequest
{
    return [self fetchRequestWithPredicateFormat:@"tags.@count == 0"];
}

#pragma mark - Sort

+ (NSSortDescriptor *)IDSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
}

+ (NSSortDescriptor *)dateSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
}

+ (NSSortDescriptor *)playbackDateSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"playbackDate" ascending:NO];
}

#pragma mark - Predicate format

+ (NSString *)downloadedPredicateFormat
{
    return @"localUrl != NIL";
}

+ (NSString *)listenedPredicateFormat
{
    return @"playbackDate != NIL";
}

+ (NSString *)favoritePredicateFormat
{
    return @"favorite == YES";
}

@end
