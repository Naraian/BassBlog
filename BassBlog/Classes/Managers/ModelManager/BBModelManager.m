//
//  BBModelManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 13.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBModelManager.h"
#import "BBFileManager.h"

#import "BBTag+Service.h"
#import "BBMix+Service.h"

#import "BBTagsSelectionOptions.h"
#import "BBMixesSelectionOptions.h"

#import "NSObject+Notification.h"
#import "NSObject+Thread.h"

#import "BBTimeProfiler.h"
#import "BBMacros.h"
#import "BBSettings.h"

#import <CoreData/CoreData.h>

#import <GoogleBlogger/GoogleBlogger.h>
#import <GoogleBlogger/GTMOAuth2Authentication.h>

typedef NS_ENUM(NSUInteger, BBModelState) {
  
    BBModelNotInitialzed,
    BBModelIsEmpty,
    BBModelIsPopulated
};

DEFINE_CONST_NSSTRING(BBModelManagerDidInitializeNotification);

DEFINE_CONST_NSSTRING(BBModelManagerDidFinishRefreshNotification);

DEFINE_CONST_NSSTRING(BBModelManagerDidChangeRefreshStageNotification);

DEFINE_CONST_NSSTRING(BBModelManagerDidFinishSaveNotification);

DEFINE_CONST_NSSTRING(BBModelManagerRefreshProgressNotification);
DEFINE_CONST_NSSTRING(BBModelManagerRefreshProgressNotificationKey);

DEFINE_CONST_NSSTRING(BBModelManagerRefreshErrorNotification);
DEFINE_CONST_NSSTRING(BBModelManagerRefreshErrorNotificationKey);

DEFINE_STATIC_CONST_NSSTRING(BBModelManagerThreadContextKey);

static const NSUInteger kBBMixesRequestMaxItemsCount = 100;
static const NSTimeInterval kBBMixesRequestRepeatInterval = 60. * 5;

static const NSTimeInterval kBBMainContextAutoSaveDelay = 30.;

static const NSUInteger kBBMaxNumberOfUpdatedObjectsForAutoSave = 1;

#pragma mark -

@interface BBModelManager ()

@property (atomic, assign) BBModelState modelState;

@property (atomic, assign) BOOL autoSaveInProgress;
@property (atomic, assign) BOOL refreshSaveInProgress;

@property (nonatomic, assign) BBModelManagerRefreshStage refreshStage;

@property (nonatomic, strong) NSManagedObjectContext *tempContext;
@property (nonatomic, strong) NSManagedObjectContext *rootContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (atomic, retain) GTLServiceTicket *blogListTicket;

TIME_PROFILER_PROPERTY_DECLARATION

@end

#pragma mark -

@implementation BBModelManager

- (id)init
{
    self = [super init];
    
    [self startObserveNotifications];
    
    return self;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return _operationQueue;
}


SINGLETON_IMPLEMENTATION(BBModelManager, defaultManager)

TIME_PROFILER_PROPERTY_IMPLEMENTATION

#pragma mark * State

DEFINE_STATIC_CONST_NSSTRING(BBMixesJSONRequestNewestItemDate);
DEFINE_STATIC_CONST_NSSTRING(BBMixesJSONRequestNextPageToken);
DEFINE_STATIC_CONST_NSSTRING(BBMixesJSONRequestNextPageStartDate);

+ (NSDate *)dateFromGTLDateTime:(GTLDateTime*)gtlDateTime
{
    NSDate *date = gtlDateTime.date;
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    timeInterval += [gtlDateTime.timeZone secondsFromGMTForDate:date];
    
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

+ (NSDate *)newestItemDate
{
    return [BBSettings objectForKey:BBMixesJSONRequestNewestItemDate];
}

+ (void)setNewestItemDate:(NSDate *)newestItemDate
{
    [BBSettings setObject:newestItemDate forKey:BBMixesJSONRequestNewestItemDate];
    [BBSettings synchronize];
}

+ (NSString *)nextPageToken
{
    return [BBSettings objectForKey:BBMixesJSONRequestNextPageToken];
}

+ (void)setNextPageToken:(NSString *)nextPageToken
{
    [BBSettings setObject:nextPageToken forKey:BBMixesJSONRequestNextPageToken];
    [BBSettings synchronize];
}

+ (NSDate *)nextPageStartDate
{
    return [BBSettings objectForKey:BBMixesJSONRequestNextPageStartDate];
}

+ (void)setNextPageStartDate:(NSDate *)nextPageStartDate
{
    [BBSettings setObject:nextPageStartDate forKey:BBMixesJSONRequestNextPageStartDate];
    [BBSettings synchronize];
}

+ (BOOL)isModelEmpty
{
    return [self newestItemDate] == nil;
}

- (BOOL)isInitialized
{
    return self.modelState == BBModelIsPopulated;
}

#pragma mark * Entities

- (void)enumerateObjectIDs:(NSArray *)objectIDs
                usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    NSAssert(block, @"Block == nil");
    
    NSAssert([NSThread isMainThread], @"Retrieving objects not in main thread!");
    
    NSManagedObjectContext *context = [self currentThreadContext];
    
    [objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop)
    {
        NSError *error = nil;
        NSManagedObject *entity = [context existingObjectWithID:objectID error:&error];
        if (entity == nil)
        {
            [self.class handleError:error];
        }
        
        block(entity, idx, stop);
    }];
}

#pragma mark - Sort descriptors

- (NSArray *)sortDescriptorsForMixesSelectionOptions:(BBMixesSelectionOptions *)options
{
    NSSortDescriptor *sortDescriptor = nil;
    
    switch (options.sortKey)
    {
        case eMixDateSortKey:
            sortDescriptor = [BBMix dateSortDescriptor];
            break;
            
        case eMixPlaybackDateSortKey:
            sortDescriptor = [BBMix playbackDateSortDescriptor];
            break;
            
        default:
            break;
    }
    
    if (sortDescriptor)
    {
        return @[sortDescriptor, [BBMix IDSortDescriptor]];
    }

    return nil;
}

#pragma mark - Auto Save

- (BOOL)isSaveInProgress
{
    if (self.refreshSaveInProgress)
    {
        return YES;
    }
    
    // Consumer wants to perform fetch, lets force auto save if needed.
    
    if (NO == self.autoSaveInProgress)
    {
        [self cancelScheduledMainContextAutoSave];
        
        [self mainContextAutoSave];
    }
    
    return self.autoSaveInProgress;
}

- (void)scheduleOrPerformMainContextAutoSave
{
    [self cancelScheduledMainContextAutoSave];
    
    if (NO == self.autoSaveInProgress)
    {
        if ([self.rootContext updatedObjects].count >= kBBMaxNumberOfUpdatedObjectsForAutoSave)
        {
            [self mainContextAutoSave];
            return;
        }
    }
    
    [self.class mainThreadBlock:^
    {
        [self performSelector:@selector(mainContextAutoSave)
                   withObject:nil
                   afterDelay:kBBMainContextAutoSaveDelay];
    }];
}

- (void)cancelScheduledMainContextAutoSave
{
    [self.class mainThreadBlock:^
    {
        [self.class cancelPreviousPerformRequestsWithTarget:self
                                                   selector:@selector(mainContextAutoSave)
                                                     object:nil];
    }];
}

- (void)mainContextAutoSave
{
    if (NO == [self.rootContext hasChanges])
    {
        return;
    }
    
    TIME_PROFILER_MARK_TIME
    
    self.autoSaveInProgress = YES;
    
    [self deepSaveRootContextWithCompletionBlock:^(BOOL saved)
    {
        if (saved == NO)
        {
            BB_ERR(@"Couldn't auto save main context!");
        }
        
        TIME_PROFILER_LOG(@"Auto save")
        
        self.autoSaveInProgress = NO;
        
        [self postNotificationWithName:BBModelManagerDidFinishSaveNotification];
    }];
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    // Application.
    [self addSelector:@selector(applicationDidEnterBackgroundNotification:) forNotificationWithName:UIApplicationDidEnterBackgroundNotification];
    [self addSelector:@selector(applicationWillEnterForegroundNotification:) forNotificationWithName:UIApplicationWillEnterForegroundNotification];
    [self addSelector:@selector(applicationWillTerminateNotification:) forNotificationWithName:UIApplicationWillTerminateNotification];
    
    // Mix.
    [self addSelector:@selector(mixDidChangeLocalUrlNotification:) forNotificationWithName:BBMixDidChangeLocalUrlNotification];
    [self addSelector:@selector(mixDidChangeFavoriteNotification:) forNotificationWithName:BBMixDidChangeFavoriteNotification];
    [self addSelector:@selector(mixDidChangePlaybackDateNotification:) forNotificationWithName:BBMixDidChangePlaybackDateNotification];
    
    // Context.
    [self addSelector:@selector(managedObjectContextDidSaveNotification:) forNotificationWithName:NSManagedObjectContextDidSaveNotification];

#ifdef DEBUG
    // Context.
    [self addSelector:@selector(managedObjectContextWillSaveNotification:) forNotificationWithName:NSManagedObjectContextWillSaveNotification];
#endif
}

#pragma mark * Application

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self cancelScheduledMainContextAutoSave];
    
    [self cleanup];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
//    [self refresh];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self deepSaveRootContext];
}

#pragma mark * Mix

- (void)mixDidChangeLocalUrlNotification:(NSNotification *)notification
{
    [self scheduleOrPerformMainContextAutoSave];
}

- (void)mixDidChangeFavoriteNotification:(NSNotification *)notification
{
    [self scheduleOrPerformMainContextAutoSave];
}

- (void)mixDidChangePlaybackDateNotification:(NSNotification *)notification
{
    [self scheduleOrPerformMainContextAutoSave];
}

#pragma mark - Service selections

- (BBMix *)mixWithID:(NSString *)ID inContext:(NSManagedObjectContext *)context
{
    NSArray *entities = [self entitiesFetchedWithRequest:[BBMix fetchRequestWithID:ID]
                                               inContext:context];
    
    if (entities.count > 1)
    {
        BB_ERR(@"Unexpected number of mixes (%d) with ID (%@)", entities.count, ID);
    }
    
    return [entities lastObject];
}

- (BBTag *)tagWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSArray *entities = [self entitiesFetchedWithRequest:[BBTag fetchRequestWithName:name]
                                               inContext:context];
    
    if (entities.count > 1)
    {
        BB_ERR(@"Unexpected number of tags (%d) with name (%@)", entities.count, name);
    }
    
    return [entities lastObject];
}

#pragma mark - Refresh

- (void)refresh
{
    if (self.modelState != BBModelNotInitialzed)
    {
        [self loadMixes];
        return;
    }
    
    [self modelStateDiscoverCompletionBlock:^
    {
        if (self.modelState == BBModelIsPopulated)
        {
            [self postNotificationWithName:BBModelManagerDidInitializeNotification];
        }
        
        [self loadMixes];
    }];
}

- (BOOL)fetchDatabaseIfNecessary
{
    if (self.modelState == BBModelNotInitialzed)
    {
        [self loadMixes];
        return YES;
    }

    NSString *nextPageToken = [self.class nextPageToken];
    NSDate *newestItemDate = [self.class newestItemDate];

    if (nextPageToken || newestItemDate)
    {
        [self loadMixes];
        return YES;
    }
    
    return NO;
}

- (void)modelStateDiscoverCompletionBlock:(void(^)())completionBlock
{
#warning FIX
#warning FIX
#warning FIX
    [self.operationQueue addOperationWithBlock:^
    {
        NSFetchRequest *fetchRequest = [BBTag fetchRequest];
        fetchRequest.fetchLimit = 1;
        
        NSUInteger tagsCount = [self countOfFetchedEntitiesWithRequest:fetchRequest
                                                             inContext:[self currentThreadContext]];
        
        self.modelState = (tagsCount > 0) ? BBModelIsPopulated : BBModelIsEmpty;
        
        if (self.modelState == BBModelIsEmpty)
        {
            [self.class setNewestItemDate:nil];
            [self.class setNextPageToken:nil];
        }
        
        if (completionBlock)
        {
            completionBlock();
        }        
    }];
}

- (GTLServiceBlogger *)bloggerService
{
    static GTLServiceBlogger *service = nil;
    
    if (!service)
    {
        service = [[GTLServiceBlogger alloc] init];
        service.parseQueue = self.operationQueue;
        
//        // Have the service object set tickets to fetch consecutive pages
//        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = NO;
//        
//        // Have the service object set tickets to retry temporary error conditions
//        // automatically.
//        service.retryEnabled = YES;
    }
    return service;
}

- (void)loadMixes
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        self.bloggerService.APIKey = @"AIzaSyAgtNFIT3ZoYSEmR6oZ2vupakpyADkdhQI";
        
        GTLQueryBlogger *query = [GTLQueryBlogger queryForPostsListWithBlogId:@"4928216501086861761"];
        query.maxPosts = kBBMixesRequestMaxItemsCount;
        query.maxResults = kBBMixesRequestMaxItemsCount;
        query.view = kGTLBloggerViewReader;
        query.fetchImages = YES;
        query.fetchBodies = YES;
        query.fetchBody = YES;
        query.fetchUserInfo = YES;
        query.orderBy = kGTLBloggerOrderByPublished;
        
        NSString *nextPageToken = [self.class nextPageToken];
        if (nextPageToken)
        {
            NSDate *nextPageStartDate = [self.class nextPageStartDate];
            
            query.pageToken = nextPageToken;
            query.startDate = [GTLDateTime dateTimeWithDate:nextPageStartDate timeZone:nil];
        }
        else
        {
            NSDate *newestItemDate = [self.class newestItemDate];
            
            if (newestItemDate)
            {
                query.startDate = [GTLDateTime dateTimeWithDate:newestItemDate timeZone:nil];
                [self.class setNextPageStartDate:newestItemDate];
            }
        }
        
        self.blogListTicket =
        [self.bloggerService executeQuery:query
                        completionHandler:^(GTLServiceTicket *ticket, GTLBloggerPostList *postList, NSError *error)
        {
            if (error)
            {
                self.refreshStage = BBModelManagerWaitingStage;
                
                [self postNotificationForRefreshError:error];
                return;
            }
            
            self.refreshStage = BBModelManagerParsingStage;
            
            [self refreshDatabaseWithMixesPostList:postList];
        }];
    });
}

- (void)refreshDatabaseWithMixesPostList:(GTLBloggerPostList *)postList
{
    [self.operationQueue addOperationWithBlock:^
    {
        NSString *description = (self.modelState == BBModelIsEmpty) ? @"database population" : @"database update";
        
        NSManagedObjectContext *context = [self serviceContextWithTaskDescription:description];
        
        TIME_PROFILER_MARK_TIME
        
        [self updateDatabaseInContext:context fromPostList:postList];
    }];
}

- (void)finished:(id)sender
{
    
}

- (void)updateDatabaseInContext:(NSManagedObjectContext *)context
                   fromPostList:(GTLBloggerPostList *)postList
{
    NSMutableDictionary *tagsDictionary = [self tagsDictionaryInContext:context];
    
    NSDate *lastPostDate = [self.class newestItemDate];
    if (!lastPostDate)
    {
        lastPostDate = [NSDate dateWithTimeIntervalSince1970:0.0];
    }
    
    if (postList.nextPageToken)
    {
        [self.class mainThreadBlock:^
        {
             [self refresh];
        }];
    }
    
    for (GTLBloggerPost *post in postList.items)
    {
        NSString *parsedID = post.identifier;
        NSString *parsedUrl = [self.class urlStringFromPost:post];
        BOOL deleted = NO;
        
        BBMix *mix = [self mixWithID:parsedID inContext:context];
        if (deleted || (parsedUrl.length == 0))
        {
            if (mix)
            {
                BB_WRN(@"Track is deleted or parsedUrl is empty (%@)", post.content);
                [context deleteObject:mix];
            }
            
            continue;
        }
        
        if (!mix)
        {
            mix = [BBMix createInContext:context];
            mix.ID = parsedID;
        }
        
        mix.url = [self.class urlStringFromPost:post];
        
        [self.class setAttributesForMix:mix fromPost:post inContext:context tagsDictionary:tagsDictionary];
        
        if ([mix.date timeIntervalSinceDate:lastPostDate] > 0)
        {
            lastPostDate = mix.date;
        }
    }
    
    [self.class setNewestItemDate:lastPostDate];
    
    [self refreshCompletionInContext:context nextPageToken:postList.nextPageToken];
}

- (void)refreshCompletionInContext:(NSManagedObjectContext *)context
                     nextPageToken:(NSString *)nextPageToken

{
#ifdef DEBUG
    [self dumpContext:context];
#endif
    
    BOOL saveExpected = YES;
    if ([context hasChanges])
    {
        TIME_PROFILER_LOG([self.class descriptionForContext:context])
        
        self.refreshSaveInProgress = YES;
        self.refreshStage = BBModelManagerSavingStage;
        
        TIME_PROFILER_MARK_TIME
    }
    else
    {
        saveExpected = NO;
        
        self.refreshStage = BBModelManagerWaitingStage;
    }
    
    [self.class saveContext:context withCompletionBlock:^(NSError *error)
    {
        self.refreshSaveInProgress = NO;
        self.refreshStage = BBModelManagerWaitingStage;
        
        if (!error)
        {
            TIME_PROFILER_LOG(@"Database saving")

            [self.class setNextPageToken:nextPageToken];
            
            self.modelState = BBModelIsPopulated;

            if (!nextPageToken.length)
            {
                [self postAsyncNotificationWithName:BBModelManagerDidFinishRefreshNotification];
            }
        }
        else if (saveExpected)
        {
            [self postNotificationForRefreshError:error];
        }
    }];
}

- (NSMutableDictionary *)tagsDictionaryInContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *tagsDictionary = [NSMutableDictionary dictionaryWithCapacity:110];
    
    NSFetchRequest *fetchRequest = [BBTag fetchRequest];
    
    [[self entitiesFetchedWithRequest:fetchRequest inContext:context] enumerateObjectsUsingBlock:^(BBTag *tag, NSUInteger tagIdx, BOOL *tagStop)
    {
        [tagsDictionary setObject:tag forKey:tag.name];
    }];
    
    return tagsDictionary;
}

+ (NSString *)urlStringFromPost:(GTLBloggerPost *)post
{
//    let bitrateMask = ">\\[(.+?) kbps\\]</span>";
//    let bitrateRegex = NSRegularExpression.regularExpressionWithPattern(bitrateMask, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
//    let bitrateMatches = bitrateRegex.numberOfMatchesInString(htmlBody, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, htmlBody.length))
//    let bitrateMatchRange = bitrateRegex.rangeOfFirstMatchInString(htmlBody, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, htmlBody.length))
//    let bitrateMatch = htmlBody.substringWithRange(bitrateMatchRange)
    
    NSString *htmlBody = post.content;
    
    NSError *error = nil;
    
    NSString *mp3Mask = @" href=\"(.+?)mixes.bassblog.pro(.+?).mp3\"";
    NSRegularExpression *mp3Regex = [NSRegularExpression regularExpressionWithPattern:mp3Mask
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    NSUInteger mp3Matches = [mp3Regex numberOfMatchesInString:htmlBody
                                                      options:0
                                                        range:NSMakeRange(0, htmlBody.length)];
    
    NSString *mp3Match = nil;
    
    if (mp3Matches > 0)
    {
        NSRange mp3MatchRange = [mp3Regex rangeOfFirstMatchInString:htmlBody
                                                            options:0
                                                              range:NSMakeRange(0, htmlBody.length)];

        mp3Match = [htmlBody substringWithRange:mp3MatchRange];
        
        if (mp3Match.length > 1)
        {
            mp3Match = [mp3Match stringByReplacingCharactersInRange:NSMakeRange(mp3Match.length - 1, 1) withString:@""];
        }
    }
    
    mp3Match = [mp3Match stringByReplacingOccurrencesOfString:@" href=\"" withString:@""];
    
    return mp3Match;
}

+ (void)setAttributesForMix:(BBMix *)mix
                   fromPost:(GTLBloggerPost *)post
                  inContext:(NSManagedObjectContext *)context
             tagsDictionary:(NSMutableDictionary *)tagsDictionary
{
    mix.postUrl = post.url;
    mix.name = post.title;
    mix.tracklist = nil;
    
#warning Parse bitrate
    mix.bitrate = 320;
    mix.date = [self dateFromGTLDateTime:post.published];
    NSArray *parsedTags = post.labels;
    
    GTLBloggerPostImagesItem *imagesItem = (GTLBloggerPostImagesItem*)[post.images lastObject];
    mix.imageUrl = imagesItem.url;
    
    if (!mix.date)
    {
        BB_WRN(@"Date is nil for mix with name: %@", mix.name);
    }
    
    [parsedTags enumerateObjectsUsingBlock:^(NSString *aName, NSUInteger aNameIdx, BOOL *aNameStop)
    {
        BBTag *tag = [tagsDictionary objectForKey:aName];
        if (!tag)
        {
            tag = [BBTag createInContext:context];
            tag.name = aName;
            tag.mainTag = [aName isEqualToString:[BBTag allNameInternal]];
             
            [tagsDictionary setObject:tag forKey:aName];
        }
         
        [mix addTagsObject:tag];
    }];
}

- (void)setRefreshStage:(BBModelManagerRefreshStage)refreshStage
{
    if (_refreshStage == refreshStage)
    {
        return;
    }
    
    _refreshStage = refreshStage;

    [self postAsyncNotificationWithName:BBModelManagerDidChangeRefreshStageNotification];
}

- (void)postNotificationForRefreshProgress:(float)progress
{
    if (progress < 0.f)
    {
        return;
    }
    
    [self postNotificationWithName:BBModelManagerRefreshProgressNotification
                          userInfo:@{BBModelManagerRefreshProgressNotificationKey: @(progress)}];
}

- (void)postNotificationForRefreshError:(NSError *)error
{
    if (error == nil)
    {
        return;
    }
    
    [self postNotificationWithName:BBModelManagerRefreshErrorNotification
                          userInfo:@{BBModelManagerRefreshErrorNotificationKey: error}];
}

#pragma mark - Cleanup

- (void)cleanup
{
    [self deepSaveRootContext];
}

- (void)deleteEntitiesFetchedWithRequest:(NSFetchRequest *)fetchRequest
{
    NSArray *entities = [self entitiesFetchedWithRequest:fetchRequest
                                               inContext:self.rootContext];
    if (!entities.count)
    {
        return;
    }
    
    [entities enumerateObjectsUsingBlock:^(BBEntity *entity, NSUInteger entityIdx, BOOL *entityStop)
    {
        [self.rootContext deleteObject:entity];
    }];
    
    BB_WRN(@"Deleted %d \"%@\"", entities.count, fetchRequest.entityName);
}

#pragma mark - Core Data

#pragma mark * Fetch

- (NSFetchRequest *)fetchRequestForTagsWithSelectionOptions:(BBTagsSelectionOptions *)options
{
    NSFetchRequest *fetchRequest = [BBTag fetchRequestWithMixesCategory:options.category];
    
    if (options.sortKey == eTagNameSortKey)
    {
        [fetchRequest setSortDescriptors:@[[BBTag mainTagSortDescriptor], [BBTag nameSortDescriptor]]];
    }
    
    fetchRequest.fetchOffset = options.offset;
    fetchRequest.fetchLimit = options.limit;
    
    return fetchRequest;
}

- (NSFetchRequest *)fetchRequestForMixesWithSelectionOptions:(BBMixesSelectionOptions *)options forSearch:(BOOL)search
{
    NSFetchRequest *fetchRequest = [BBMix fetchRequestWithCategory:options.category
                                                   substringInName:search ? options.substringInName : nil
                                                               tag:options.tag];
    
    [fetchRequest setSortDescriptors:[self sortDescriptorsForMixesSelectionOptions:options]];
    
    fetchRequest.fetchOffset = options.offset;
    fetchRequest.fetchLimit = options.limit;
    
    return fetchRequest;
}

- (NSArray *)entitiesFetchedWithRequest:(NSFetchRequest *)fetchRequest
                              inContext:(NSManagedObjectContext *)context
{
    NSArray *__block result = nil;
    [context performBlockAndWait:^
    {
        NSError *error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        
        [self.class handleError:error];
    }];
    
    return result;
}

- (NSUInteger)countOfFetchedEntitiesWithRequest:(NSFetchRequest *)fetchRequest
                                      inContext:(NSManagedObjectContext *)context
{
    NSUInteger __block count = 0;
    [context performBlockAndWait:^
    {
        NSError *error = nil;
        count = [context countForFetchRequest:fetchRequest error:&error];
    
        [self.class handleError:error];
    }];
    
    return count;
}

#pragma mark * Save

- (void)deepSaveRootContext
{
    [self deepSaveRootContextWithCompletionBlock:nil];
}

- (void)deepSaveRootContextWithCompletionBlock:(void(^)(BOOL saved))completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.rootContext performBlock:^
        {
            [self.class saveContext:self.rootContext withCompletionBlock:^(NSError *error)
            {
                if (completionBlock)
                {
                    completionBlock(error == nil);
                }
            }];
        }];
    });

        #warning ???
//        if (!saved || !context.parentContext)
//        {
//            if (completionBlock)
//            {
//                completionBlock(saved);
//            }
//        
//            return;
//        }
        
        //[self deepSaveFromContext:context.parentContext withCompletionBlock:completionBlock];
}

+ (void)saveContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSError *error))completionBlock
{
    NSString *description = [self descriptionForContext:context];
    
    if (![context hasChanges])
    {
        BB_INF(@"No changes in %@ context", description);
        completionBlock(nil);
        return;
    }
    
    __block BOOL saved = NO;
    __block NSError *error = nil;
	
    @try
	{
        [context performBlockAndWait:^
        {
            saved = [context save:&error];
        }];
	}
	@catch (NSException *exception)
	{
        BB_ERR(@"%@ context save exception (%@)", description, exception);
	}
	@finally
    {
        if (saved)
        {
            BB_INF(@"%@ context saved", description);
        }
        else
        {
            [self handleError:error];
        }
        
        if (completionBlock)
        {
            completionBlock(error);
        }
    }
}

#pragma mark * Stack

- (NSManagedObjectContext *)tempContext
{
    if (_tempContext == nil)
    {
        _tempContext = [self serviceContextWithTaskDescription:@"temp"];
    }
    
    return _tempContext;
}

- (NSManagedObjectContext *)rootContext
{
    if (!_rootContext && self.coordinator)
    {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [self.class setDescription:@"ROOT" forContext:_rootContext];
        
        [_rootContext performBlockAndWait:^
        {
            [_rootContext setPersistentStoreCoordinator:self.coordinator];
            [_rootContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
    }
    
    return _rootContext;
}

- (NSManagedObjectContext *)currentThreadContext
{
	if ([NSThread isMainThread])
    {
		return self.rootContext;
	}
    
    @synchronized(self)
    {
        NSThread *thread = [NSThread currentThread];
        NSMutableDictionary *threadDict = [thread threadDictionary];
        NSManagedObjectContext *threadContext = [threadDict objectForKey:[NSValue valueWithNonretainedObject:thread]];
        if (threadContext == nil)
        {
            threadContext = [self serviceContextWithTaskDescription:thread.name];
            
            [threadDict setObject:threadContext forKey:[NSValue valueWithNonretainedObject:thread]];
        }
    
        return threadContext;
    }
}

- (NSManagedObjectContext *)serviceContextWithTaskDescription:(NSString *)taskDescription
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:self.rootContext];
    
    NSString *description = [NSString stringWithFormat:@"SERVICE \"%@\"", taskDescription];
    
    [self.class setDescription:description forContext:context];
    
    return context;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    if (!_coordinator)
    {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
        if (![self addAutoMigratingSqliteStore])
        {
            [self performSelector:@selector(addAutoMigratingSqliteStore)
                       withObject:nil
                       afterDelay:0.5];
        }
    }
    
    return _coordinator;
}

#pragma mark * Auto Migrating

- (BOOL)addAutoMigratingSqliteStore
{
    NSDictionary *sqliteOptions = @{@"journal_mode" : @"DELETE"};
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              NSSQLitePragmasOption : sqliteOptions};
    
    NSError *error = nil;
    NSURL *url = [[BBFileManager documentDirectoryURL] URLByAppendingPathComponent:@"BassBlog.sqlite"];
    
    if (![self addSqliteStoreAtURL:url options:options error:&error])
    {
        if ([error.domain isEqualToString:NSCocoaErrorDomain]
            && error.code == NSMigrationMissingSourceModelError)
        {
            if ([BBFileManager removeItemAtURL:url])
            {
                BB_WRN(@"Removed obsolete SQL database");
            }
            
            if ([self addSqliteStoreAtURL:url options:options error:&error])
            {
                error = nil;
            }
        }
    
        [self.class handleError:error];
    }
    
    return _coordinator.persistentStores.count;
}

- (BOOL)addSqliteStoreAtURL:(NSURL *)url
                    options:(NSDictionary *)options
                      error:(NSError *__autoreleasing *)error
{
    return [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:url
                                            options:options
                                              error:error] != nil;
}

#pragma mark * Context description

static NSString *const BBManagedObjectContextDescriptionKey =
@"pro.bassblog.ManagedObjectContextDescription";

+ (void)setDescription:(NSString *)description
            forContext:(NSManagedObjectContext *)context
{
    [context.userInfo setObject:description
                         forKey:BBManagedObjectContextDescriptionKey];
}

+ (NSString *)descriptionForContext:(NSManagedObjectContext *)context
{
    return [context.userInfo objectForKey:BBManagedObjectContextDescriptionKey];
}

#pragma mark * Error Handling

+ (void)handleError:(NSError *)error
{
    if (!error)
    {
        return;
    }
    
    [error.userInfo.allValues enumerateObjectsUsingBlock:^(id detailedError, NSUInteger detailedErrorIdx, BOOL *detailedErrorStop)
    {
        if (![detailedError isKindOfClass:[NSArray class]])
        {
            BB_ERR(@"%@", detailedError);
            
            return;
        }
        
        [(NSArray*)detailedError enumerateObjectsUsingBlock:^(id anError, NSUInteger anErrorIdx, BOOL *anErrorStop)
        {
            if ([anError respondsToSelector:@selector(userInfo)])
            {
                BB_ERR(@"%@", [(NSError *)anError userInfo]);
            }
            else
            {
                BB_ERR(@"%@", anError);
            }
        }];
    }];
    
    BB_ERR(@"Info: \n%@", error);
}

#ifdef DEBUG

#pragma mark - Debug

- (void)managedObjectContextWillSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *context = notification.object;
    
    if (context != _rootContext)
    {
        return;
    }
    
    NSMutableString *dump = [NSMutableString string];
    
    if (context.deletedObjects.count)
    {
        [dump appendFormat:@"\n\nDeleted objects: %@", [self descriptionOfEntities:context.deletedObjects]];
    }
    
    if (context.insertedObjects.count)
    {
        [dump appendFormat:@"\n\nInserted objects: %@", [self descriptionOfEntities:context.insertedObjects]];
    }
    
    if (context.updatedObjects.count)
    {
        [dump appendFormat:@"\n\nUpdated objects: %@", [self descriptionOfEntities:context.updatedObjects includingChanges:YES]];
    }
    
    if (dump.length)
    {
        BB_DBG(@"Changes in %@ context: %@", [self descriptionForContext:context], dump);
    }
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (savedContext != _rootContext)
    {
        if (_rootContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_rootContext performBlock:^
            {
                [_rootContext mergeChangesFromContextDidSaveNotification:notification];
                [self mainContextAutoSave];
            }];
        });
    }
}

- (NSString *)descriptionOfEntities:(NSSet *)entities
{
    return [self descriptionOfEntities:entities includingChanges:NO];
}

- (NSString *)descriptionOfEntities:(NSSet *)entities
                   includingChanges:(BOOL)includingChanges
{
    __block NSUInteger tagsCount = 0;
    __block NSUInteger mixesCount = 0;
    
    NSMutableString *changesDescription = [NSMutableString string];
    
    [entities enumerateObjectsUsingBlock:^(BBEntity *entity, BOOL *entityStop)
    {
        if ([entity isKindOfClass:[BBMix class]])
        {
            ++mixesCount;
         
            if (includingChanges)
            {
                [changesDescription appendFormat:@"\n\t\t[%@] : %@", entity.key, entity.changedValues];
            }
        }
        else
        {
            ++tagsCount;
        }
    }];
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"%d", entities.count];
    
    if (mixesCount)
    {
        [description appendFormat:@"\n\n\tMixes: %d %@", mixesCount, changesDescription];
    }
    
    if (tagsCount)
    {
        [description appendFormat:@"\n\n\tTags: %d", tagsCount];
    }

    return description;
}

- (void)dumpContext:(NSManagedObjectContext *)context
{
    // Dump on changes and very first time only.
    
    static BOOL firstDump = YES;
    
    if (!firstDump && ![context hasChanges])
    {
        return;
    }
    
    __block NSFetchRequest *fetchRequest = nil;
    
    BBTagsSelectionOptions *tagsSelectionOptions = [BBTagsSelectionOptions new];
    BBMixesSelectionOptions *mixesSelectionOptions = [BBMixesSelectionOptions new];
    
    NSMutableString *dump = [NSMutableString new];
    
    // Entities ----------------------------------------------------------------
    
    fetchRequest = [BBEntity fetchRequest];
    [fetchRequest setIncludesSubentities:YES];
    
    [dump appendFormat:@"\nEntities: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // All mixes ---------------------------------------------------------------
    
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions forSearch:NO];
    
    [dump appendFormat:@"\n\n\tAll mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Favorite mixes ----------------------------------------------------------
    
    mixesSelectionOptions.category = eFavoriteMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions forSearch:NO];
    
    [dump appendFormat:@"\n\t\tFavorite mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Listened mixes ----------------------------------------------------------
    
    mixesSelectionOptions.category = eListenedMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions forSearch:NO];
    
    [dump appendFormat:@"\n\t\tListened mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Downloaded mixes --------------------------------------------------------
    
    mixesSelectionOptions.category = eDownloadedMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions forSearch:NO];
    
    [dump appendFormat:@"\n\t\tDownloaded mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // All tags ----------------------------------------------------------------
    
    fetchRequest =
    [self fetchRequestForTagsWithSelectionOptions:tagsSelectionOptions];

    [dump appendFormat:@"\n\n\tAll formal tags: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Mixes per tag -----------------------------------------------------------
    
    mixesSelectionOptions.category = eAllMixesCategory;
    
    fetchRequest =
    [self fetchRequestForTagsWithSelectionOptions:tagsSelectionOptions];
    
    [[self entitiesFetchedWithRequest:fetchRequest
                            inContext:context]
     enumerateObjectsUsingBlock:^(BBTag *tag, NSUInteger tagIdx, BOOL *tagStop)
    {
        mixesSelectionOptions.tag = tag;
        fetchRequest =
        [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions forSearch:NO];
        
        [dump appendFormat:@"\n\t\t%@ : %d mixes",
         tag.name, [self countOfFetchedEntitiesWithRequest:fetchRequest
                                                 inContext:context]];
    }];
    
    BB_DBG(@"\n%@", dump);
    
    firstDump = NO;
    
    // Other tests -------------------------------------------------------------
    
//    fetchRequest = [BBTag fetchRequest];
//    
//    BB_DBG(@"Total tags: %d", [self countOfFetchedEntitiesWithRequest:fetchRequest inContext:context]);
}

#endif // DEBUG

@end
