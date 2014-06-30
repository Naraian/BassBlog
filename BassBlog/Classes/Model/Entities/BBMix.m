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
static NSString *const BBMixDateKey = @"date";
static NSString *const BBMixPlaybackDateKey = @"playbackDate";

NSString *const BBMixDaySectionIdentifierKey = @"daySectionIdentifier";
NSString *const BBMixMonthSectionIdentifierKey = @"monthSectionIdentifier";

NSString *const BBMixPlaybackDaySectionIdentifierKey = @"playbackDaySectionIdentifier";
NSString *const BBMixPlaybackMonthSectionIdentifierKey = @"playbackMonthSectionIdentifier";


#pragma mark -

@interface BBMix ()
{
    BOOL _favorite;
}

@property (nonatomic, strong) NSString *primitiveLocalUrl;

@property (nonatomic, strong) NSDate *primitiveDate;
@property (nonatomic, strong) NSDate *primitivePlaybackDate;

@property (nonatomic, strong) NSNumber *primitiveDaySectionIdentifier;
@property (nonatomic, strong) NSNumber *primitiveMonthSectionIdentifier;

@property (nonatomic, strong) NSNumber *primitivePlaybackDaySectionIdentifier;
@property (nonatomic, strong) NSNumber *primitivePlaybackMonthSectionIdentifier;

@end

#pragma mark -

@implementation BBMix

@dynamic ID;
@dynamic url;
@dynamic postUrl;
@dynamic imageUrl;
@dynamic name;
@dynamic date, primitiveDate;
@dynamic tags;
@dynamic bitrate;
@dynamic localUrl;
@dynamic favorite;
@dynamic tracklist;
@dynamic playbackDate, primitivePlaybackDate;

@dynamic primitiveLocalUrl;

@dynamic daySectionIdentifier, primitiveDaySectionIdentifier;
@dynamic monthSectionIdentifier, primitiveMonthSectionIdentifier;

@dynamic playbackDaySectionIdentifier, primitivePlaybackDaySectionIdentifier;
@dynamic playbackMonthSectionIdentifier, primitivePlaybackMonthSectionIdentifier;

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
    
    _favorite = favorite;
    
    [self didChangeValueForKey:BBMixFavoriteKey];
    
    [self postNotificationWithName:BBMixDidChangeFavoriteNotification];
}

- (void)setDate:(NSDate *)date
{
    [self willChangeValueForKey:BBMixDateKey];
    
    [self setPrimitiveDate:date];
    
    [self didChangeValueForKey:BBMixDateKey];
    
    [self setPrimitiveDaySectionIdentifier:nil];
    [self setPrimitiveMonthSectionIdentifier:nil];
}

- (void)setPlaybackDate:(NSDate *)playbackDate {
    
    [self willChangeValueForKey:BBMixPlaybackDateKey];
    
    [self setPrimitivePlaybackDate:playbackDate];
    
    [self didChangeValueForKey:BBMixPlaybackDateKey];
    
    [self setPrimitivePlaybackDaySectionIdentifier:nil];
    [self setPrimitivePlaybackMonthSectionIdentifier:nil];
    
    [self postNotificationWithName:BBMixDidChangePlaybackDateNotification];
}

- (NSNumber *)sectionIDFromDate:(NSDate *)date components:(int32_t)components
{
    if (!date)
    {
        return @(0);
    }
    
    int32_t sectionID = 0;
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:date];
    
    if (components & NSDayCalendarUnit)
    {
        sectionID |= dateComponents.day;
    }
    
    if (components & NSMonthCalendarUnit)
    {
        sectionID |= dateComponents.month << 5; // *32
    }
    
    if (components & NSYearCalendarUnit)
    {
        sectionID |= dateComponents.year << 9; // *512
    }
    
    return @(sectionID);
}

- (int32_t)daySectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:BBMixDaySectionIdentifierKey];
    NSNumber *tmp = [self primitiveDaySectionIdentifier];
    [self didAccessValueForKey:BBMixDaySectionIdentifierKey];
    
    if (tmp.integerValue == 0)
    {
        tmp = [self sectionIDFromDate:self.date components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit];
        
        [self setPrimitiveDaySectionIdentifier:tmp];
    }
    
    return [tmp integerValue];
}

- (int32_t)monthSectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:BBMixMonthSectionIdentifierKey];
    NSNumber *tmp = [self primitiveMonthSectionIdentifier];
    [self didAccessValueForKey:BBMixMonthSectionIdentifierKey];
    
    if (tmp.integerValue == 0)
    {
        tmp = [self sectionIDFromDate:self.date components:NSYearCalendarUnit | NSMonthCalendarUnit];
        
        [self setPrimitiveMonthSectionIdentifier:tmp];
    }
    
    return [tmp integerValue];
}

- (int32_t)playbackDaySectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:BBMixPlaybackDaySectionIdentifierKey];
    NSNumber *tmp = [self primitivePlaybackDaySectionIdentifier];
    [self didAccessValueForKey:BBMixPlaybackDaySectionIdentifierKey];
    
    if (tmp.integerValue == 0)
    {
        tmp = [self sectionIDFromDate:self.playbackDate components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit];
        
        [self setPrimitivePlaybackDaySectionIdentifier:tmp];
    }
    
    return [tmp integerValue];
}

- (int32_t)playbackMonthSectionIdentifier
{
    // Create and cache the section identifier on demand.
    [self willAccessValueForKey:BBMixPlaybackMonthSectionIdentifierKey];
    NSNumber *tmp = [self primitivePlaybackMonthSectionIdentifier];
    [self didAccessValueForKey:BBMixPlaybackMonthSectionIdentifierKey];
    
    if (tmp.integerValue == 0)
    {
        tmp = [self sectionIDFromDate:self.playbackDate components:NSYearCalendarUnit | NSMonthCalendarUnit];
        
        [self setPrimitivePlaybackMonthSectionIdentifier:tmp];
    }
    
    return [tmp integerValue];
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
        {
            [format appendString:@" && "];
        }
        
        [format appendString:@"ANY tags == %@"];
        [arguments addObject:tag];
    }
    
    if (substringInName.length)
    {
        if (format.length)
        {
            [format appendString:@" && "];
        }
        
        [format appendString:@"name CONTAINS[cd] %@"];
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

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier
{
    // If the value of timeStamp changes, the section identifier may change as well.
    return [NSSet setWithObjects:@"date", @"playbackDate", nil];
}

@end
