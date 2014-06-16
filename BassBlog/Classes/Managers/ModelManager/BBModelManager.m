//
//  BBModelManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 13.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBModelManager.h"
#import "BBFileManager.h"

#import "BBMixesJSONLoader.h"
#import "BBMixesJSONParser.h"

#import "BBTag+Service.h"
#import "BBMix+Service.h"

#import "BBTagsSelectionOptions.h"
#import "BBMixesSelectionOptions.h"

#import "NSObject+Notification.h"
#import "NSObject+Thread.h"

#import "BBTimeProfiler.h"
#import "BBMacros.h"

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

static const NSTimeInterval kBBMixesRequestRepeatInterval = 60. * 5;

static const NSTimeInterval kBBMainContextAutoSaveDelay = 30.;

static const NSUInteger kBBMaxNumberOfUpdatedObjectsForAutoSave = 10;

#pragma mark -

@interface BBModelManager ()

@property (atomic, assign) BBModelState modelState;

@property (atomic, assign) BOOL autoSaveInProgress;
@property (atomic, assign) BOOL refreshSaveInProgress;

@property (nonatomic, strong) BBTag *allTag;

@property (nonatomic, assign) BBModelManagerRefreshStage refreshStage;

@property (nonatomic, strong) NSManagedObjectContext *tempContext;
@property (nonatomic, strong) NSManagedObjectContext *rootContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, strong) NSError *error;

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

- (dispatch_queue_t)dispatchQueue {
    
    if (_dispatchQueue == NULL) {
        
        _dispatchQueue = dispatch_queue_create("pro.bassblog.ModelManagerDispatchQueue", NULL);
    
        // TODO: configure priority here if needed...
    }
    
    return _dispatchQueue;
}


SINGLETON_IMPLEMENTATION(BBModelManager, defaultManager)

TIME_PROFILER_PROPERTY_IMPLEMENTATION

#pragma mark * State

+ (BOOL)isModelEmpty {
    
#warning TODO: incorrect but fast test...
    
    return [BBMixesJSONLoader requestArgValue] == 0;
}

- (BOOL)isInitialized {
    
    return self.modelState == BBModelIsPopulated;
}

#pragma mark * Entities

+ (BBTag *)allTag {
    
    return [[self defaultManager] allTag];
}

- (BBTag *)allTag {
    
    if (_allTag == nil) {
        
        _allTag = [BBTag createInContext:self.tempContext];
        _allTag.name = [BBTag allName];
    }
    
    return _allTag;
}

- (NSArray *)tagsWithSelectionOptions:(BBTagsSelectionOptions *)options {
    
    NSFetchRequest *fetchRequest =
    [self fetchRequestForTagsWithSelectionOptions:options];
    
    NSArray *tags =
    [self entitiesFetchedWithRequest:fetchRequest
                           inContext:[self currentThreadContext]];
    
    if (tags.count) {
        tags = [tags arrayByAddingObject:self.allTag];
    }
    
    return tags;
}

- (NSArray *)mixesWithSelectionOptions:(BBMixesSelectionOptions *)options {
    
    NSFetchRequest *fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:options];
    
    NSArray *mixes =
    [self entitiesFetchedWithRequest:fetchRequest
                           inContext:[self currentThreadContext]];
    return mixes;
}

- (NSUInteger)mixesCountWithSelectionOptions:(BBMixesSelectionOptions *)options {
    
    NSFetchRequest *fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:options];
    
    NSUInteger count =
    [self countOfFetchedEntitiesWithRequest:fetchRequest
                                  inContext:[self currentThreadContext]];
    return count;
}

- (void)enumerateObjectIDs:(NSArray *)objectIDs
                usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    
    NSAssert(block, @"Block == nil");
    
    NSAssert([NSThread isMainThread], @"Retrieving objects not in main thread!");
    
    NSManagedObjectContext *context = [self currentThreadContext];
    
    [objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        
        NSError *__autoreleasing error = nil;
        NSManagedObject *entity = [context existingObjectWithID:objectID error:&error];
        if (entity == nil) {
            
            if ([objectID isEqual:[self.allTag objectID]]) {
                entity = self.allTag;
            }
            else {
                [self handleError:error];
            }
        }
        
        block(entity, idx, stop);
    }];
}

#pragma mark - Sort descriptors

- (NSArray *)sortDescriptorsForMixesSelectionOptions:(BBMixesSelectionOptions *)options {
    
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
    
    if (sortDescriptor) {
        return @[sortDescriptor, [BBMix IDSortDescriptor]];
    }

    return nil;
}

#pragma mark - Auto Save

- (BOOL)isSaveInProgress {
    
    if (self.refreshSaveInProgress) {
        
        return YES;
    }
    
    // Consumer wants to perform fetch, lets force auto save if needed.
    
    if (NO == self.autoSaveInProgress) {
        
        [self cancelScheduledMainContextAutoSave];
        
        [self mainContextAutoSave];
    }
    
    return self.autoSaveInProgress;
}

- (void)scheduleOrPerformMainContextAutoSave {
    
    [self cancelScheduledMainContextAutoSave];
    
    if (NO == self.autoSaveInProgress) {
        
        if ([self.mainContext updatedObjects].count > kBBMaxNumberOfUpdatedObjectsForAutoSave) {
            
            [self mainContextAutoSave];
            return;
        }
    }
    
    [self.class mainThreadBlock:^{
        
        [self performSelector:@selector(mainContextAutoSave)
                   withObject:nil
                   afterDelay:kBBMainContextAutoSaveDelay];
    }];
}

- (void)cancelScheduledMainContextAutoSave {
    
    [self.class mainThreadBlock:^{
        
        [self.class cancelPreviousPerformRequestsWithTarget:self
                                                   selector:@selector(mainContextAutoSave)
                                                     object:nil];
    }];
}

- (void)mainContextAutoSave {
 
    if (NO == [self.mainContext hasChanges]) {
        
        return;
    }
    
    TIME_PROFILER_MARK_TIME
    
    self.autoSaveInProgress = YES;
    
    [self deepSaveFromContext:self.mainContext withCompletionBlock:^(BOOL saved) {
        
        if (saved == NO) {
            
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
    
    [self addSelector:@selector(applicationDidEnterBackgroundNotification:)
    forNotificationWithName:UIApplicationDidEnterBackgroundNotification];
    
    [self addSelector:@selector(applicationWillEnterForegroundNotification:)
    forNotificationWithName:UIApplicationWillEnterForegroundNotification];
    
    [self addSelector:@selector(applicationWillTerminateNotification:)
    forNotificationWithName:UIApplicationWillTerminateNotification];
    
    // Mix.
    
    [self addSelector:@selector(mixDidChangeLocalUrlNotification:)
    forNotificationWithName:BBMixDidChangeLocalUrlNotification];
    
    [self addSelector:@selector(mixDidChangeFavoriteNotification:)
    forNotificationWithName:BBMixDidChangeFavoriteNotification];

    [self addSelector:@selector(mixDidChangePlaybackDateNotification:)
    forNotificationWithName:BBMixDidChangePlaybackDateNotification];


#ifdef DEBUG
    
    // Context.
    
    [self addSelector:@selector(managedObjectContextWillSaveNotification:)
    forNotificationWithName:NSManagedObjectContextWillSaveNotification];
    
#endif
}

#pragma mark * Application

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    
    [self cancelScheduledMainContextAutoSave];
    
    [self cancelScheduledMixesRequest];
    
    [self cleanup];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [self refresh];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self deepSaveFromContext:self.mainContext];
}

#pragma mark * Mix

- (void)mixDidChangeLocalUrlNotification:(NSNotification *)notification {
    
    [self scheduleOrPerformMainContextAutoSave];
}

- (void)mixDidChangeFavoriteNotification:(NSNotification *)notification {
    
    [self scheduleOrPerformMainContextAutoSave];
}

- (void)mixDidChangePlaybackDateNotification:(NSNotification *)notification {
    
    [self scheduleOrPerformMainContextAutoSave];
}

#pragma mark - Service selections

- (BBMix *)mixWithID:(NSString *)ID inContext:(NSManagedObjectContext *)context
{
    NSArray *entities =
    [self entitiesFetchedWithRequest:[BBMix fetchRequestWithID:ID]
                           inContext:context];
    
    if (entities.count > 1)
        BB_ERR(@"Unexpected number of mixes (%d) with ID (%@)", entities.count, ID);
    
    return [entities lastObject];
}

- (BBTag *)tagWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSArray *entities =
    [self entitiesFetchedWithRequest:[BBTag fetchRequestWithName:name]
                           inContext:context];
    
    if (entities.count > 1)
        BB_ERR(@"Unexpected number of tags (%d) with name (%@)", entities.count, name);
    
    return [entities lastObject];
}

#pragma mark - Refresh

- (void)refresh {
    
    if (self.modelState != BBModelNotInitialzed) {
        
        [self loadMixes];
        return;
    }
    
    [self modelStateDiscoverCompletionBlock:^{
        
        if (self.modelState == BBModelIsPopulated) {
            
            [self postNotificationWithName:BBModelManagerDidInitializeNotification];
        }
        
        [self loadMixes];
    }];
}

- (void)modelStateDiscoverCompletionBlock:(void(^)())completionBlock {
    
    dispatch_async(self.dispatchQueue, ^{
        
        NSFetchRequest *fetchRequest = [BBTag fetchRequest];
        fetchRequest.fetchLimit = 1;
        
        NSUInteger tagsCount =
        [self countOfFetchedEntitiesWithRequest:fetchRequest
                                      inContext:[self currentThreadContext]];
        
        self.modelState = tagsCount ? BBModelIsPopulated : BBModelIsEmpty;
        
        if (self.modelState == BBModelIsEmpty) {
            
            [BBMixesJSONLoader setRequestArgValue:0];
        }
        
        if (completionBlock) {
            completionBlock();
        }        
    });
}

- (GTLServiceBlogger *)bloggerService {
    static GTLServiceBlogger *service = nil;
    
    if (!service) {
        service = [[GTLServiceBlogger alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}

- (void)loadMixes {
    
    void(^dataBlock)(NSData *) = ^(NSData *data) {
        
        self.refreshStage = BBModelManagerParsingStage;
        
        [self refreshDatabaseWithMixesJSON:data];
    };
    
    void(^progressBlock)(float) = ^(float progress) {
        
        self.refreshStage = BBModelManagerLoadingStage;
        
        [self postNotificationForRefreshProgress:progress];
    };
    
    void(^errorBlock)(NSError *) = ^(NSError *error) {
        
        self.refreshStage = BBModelManagerWaitingStage;
        
        [self postNotificationForRefreshError:error];
    };
    
    NSString *clientID = @"181428101607-lq94fbn93v8shiigrhs1r7l7hgl3ud1v.apps.googleusercontent.com";
    NSString *clientSecret = @"bfQcW2itarMDI4_g2CJKw26J";
    
    NSURL *tokenURL = [NSURL URLWithString:@"https://api.example.com/oauth/token"];
    
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    NSString *redirectURI = @"http://www.google.com/OAuthCallback";
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Custom Service"
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:clientID
                                                         clientSecret:clientSecret];
    self.bloggerService.authorizer = auth;

    
//    [[BBMixesJSONLoader new] loadWithDataBlock:dataBlock
//                                 progressBlock:progressBlock
//                                    errorBlock:errorBlock];
}

- (void)refreshDatabaseWithMixesJSON:(NSData *)JSON {
    
    dispatch_async(self.dispatchQueue, ^ {
            
        NSString *description = nil;
        if (self.modelState == BBModelIsEmpty) {
            description = @"database population";
        }
        else {
            description = @"database update";
        }
        
        NSManagedObjectContext *context =
        [self serviceContextWithTaskDescription:description];
        
        BBMixesJSONParser *parser = [BBMixesJSONParser parserWithData:JSON];
        
        TIME_PROFILER_MARK_TIME
        
        if (self.modelState == BBModelIsEmpty) {
            [self populateDatabaseInContext:context fromParser:parser];
        }
        else {
            [self updateDatabaseInContext:context fromParser:parser];
        }
    });
}

#warning TODO: create private context connected to persistent store directly...

// NOTE: we use two quite similar methods for performance reasons.

- (void)populateDatabaseInContext:(NSManagedObjectContext *)context
                       fromParser:(BBMixesJSONParser *)parser
{    
    __block NSMutableDictionary *tagsDictionary =
    [self tagsDictionaryInContext:context];
    
    __block NSMutableDictionary *urlsDictionary =
    [NSMutableDictionary dictionaryWithCapacity:5200];
    
    [parser parseWithMixBlock:^(NSString *parsedID,
                                NSString *parsedUrl,
                                NSString *parsedName,
                                NSString *parsedTracklist,
                                NSInteger parsedBitrate,
                                NSArray *parsedTags,
                                NSDate *parsedDate,
                                BOOL deleted)
    {
        if (deleted)
        {
            return;
        }
        
        BBMix *mix = [urlsDictionary objectForKey:parsedUrl];
        if (mix)
        {
            [mix removeTags:mix.tags];
        }
        else
        {
            mix = [BBMix createInContext:context];
            [urlsDictionary setObject:mix forKey:parsedUrl];
        }
        
        mix.ID = parsedID;
        
        setMixAttributes(mix, parsedUrl, parsedName, parsedTracklist, parsedBitrate, parsedDate);
        
        [parsedTags enumerateObjectsUsingBlock: ^(NSString *aName, NSUInteger aNameIdx, BOOL *aNameStop)
        {
             BBTag *tag = [tagsDictionary objectForKey:aName];
             if (tag == nil)
             {
                 tag = [BBTag createInContext:context];
                 tag.name = aName;
                 
                 [tagsDictionary setObject:tag forKey:aName];
             }
             
             [mix addTagsObject:tag];
         }];
    }
    progressBlock:^(float progress)
    {
        [self postNotificationForRefreshProgress:progress];
    }
    completionBlock:^(NSInteger newRequestArgValue)
    {
        [self refreshCompletionInContext:context
                  withNewRequestArgValue:newRequestArgValue];
    }]; // parse
}

#warning TODO: divide model refresh on stage a) - mixes load, b) - entities insertion. Start b) on fetch operations count == 0

- (void)updateDatabaseInContext:(NSManagedObjectContext *)context
                     fromParser:(BBMixesJSONParser *)parser
{
    __block NSMutableDictionary *tagsDictionary =
    [self tagsDictionaryInContext:context];
    
    [parser parseWithMixBlock:^(NSString *ID,
                                NSString *url,
                                NSString *name,
                                NSString *tracklist,
                                NSInteger bitrate,
                                NSArray *tags,
                                NSDate *date,
                                BOOL deleted)
    {
        BBMix *mix = [self mixWithID:ID inContext:context];
        if (deleted)
        {
            if (mix)
            {
                // TODO: think about it...
                
                [context deleteObject:mix];
                
                BB_WRN(@"Deleted mix named (%@)", name);
            }
            
            return;
        }
        
        if (!mix)
        {
            mix = [BBMix createInContext:context];
            mix.ID = ID;
        }
        
        setMixAttributes(mix, url, name, tracklist, bitrate, date);
        
        [tags enumerateObjectsUsingBlock:
         ^(NSString *name, NSUInteger nameIdx, BOOL *nameStop)
        {
            // TODO: current logic doesn't delete old tags from mix if needed...
            
            BBTag *tag = [tagsDictionary objectForKey:name];
            if (!tag)
            {
                tag = [BBTag createInContext:context];
                tag.name = name;
                 
                [tagsDictionary setObject:tag forKey:name];
            }
             
            if (![mix.tags containsObject:tag])
            {
                [mix addTagsObject:tag];
            }
        }];
    }
                       progressBlock:nil
                     completionBlock:^(NSInteger newRequestArgValue)
    {
        [self refreshCompletionInContext:context
                  withNewRequestArgValue:newRequestArgValue];
    }]; // parse
}

- (void)refreshCompletionInContext:(NSManagedObjectContext *)context
            withNewRequestArgValue:(NSInteger)newRequestArgValue
{
#ifdef DEBUG
    [self dumpContext:context];
#endif
    
    BOOL saveExpected = YES;
    if ([context hasChanges]) {
        
        TIME_PROFILER_LOG([self descriptionForContext:context])
        
        self.refreshSaveInProgress = YES;
        self.refreshStage = BBModelManagerSavingStage;
        
        TIME_PROFILER_MARK_TIME
    }
    else {
        
        saveExpected = NO;
        
        self.refreshStage = BBModelManagerWaitingStage;
    }
    
    [self deepSaveFromContext:context withCompletionBlock:^(BOOL saved) {
        
        self.refreshSaveInProgress = NO;
        self.refreshStage = BBModelManagerWaitingStage;
        
        if (saved)
        {
            TIME_PROFILER_LOG(@"Database saving")

            NSUInteger requestArgValue = [BBMixesJSONLoader requestArgValue];
            if (requestArgValue > newRequestArgValue)
            {
                BB_ERR(@"New request arg value (%d) < actual one (%d)",
                    newRequestArgValue, requestArgValue);
            }

            [BBMixesJSONLoader setRequestArgValue:newRequestArgValue];
            
            self.modelState = BBModelIsPopulated;

            // NOTE: async because we want to finish possible current UI activity.

            [self postAsyncNotificationWithName:BBModelManagerDidFinishRefreshNotification];
        }
        else if (saveExpected) {
            
            [self postNotificationForRefreshError:self.error];
        }
    }];
    
    [self scheduleMixesRequest];
}

- (NSMutableDictionary *)tagsDictionaryInContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *tagsDictionary =
    [NSMutableDictionary dictionaryWithCapacity:110];
    
    NSFetchRequest *fetchRequest = [BBTag fetchRequest];
    
    [[self entitiesFetchedWithRequest:fetchRequest inContext:context]
     enumerateObjectsUsingBlock:^(BBTag *tag, NSUInteger tagIdx, BOOL *tagStop) {
        
        [tagsDictionary setObject:tag forKey:tag.name];
    }];
    
    return tagsDictionary;
}

static inline void setMixAttributes(BBMix *mix,
                                    NSString *url,
                                    NSString *name,
                                    NSString *tracklist,
                                    NSInteger bitrate,
                                    NSDate *date)
{
    mix.tracklist = tracklist;
    mix.bitrate = bitrate;
    mix.name = name;
    mix.date = date;
    mix.url = url;
}

- (void)scheduleMixesRequest
{
    [self cancelScheduledMixesRequest];
    
    [self.class mainThreadBlock:^{
        
        [self performSelector:@selector(refresh)
                   withObject:nil
                   afterDelay:kBBMixesRequestRepeatInterval];
    }];
}

- (void)cancelScheduledMixesRequest
{
    [self.class mainThreadBlock:^{
        
        [self.class cancelPreviousPerformRequestsWithTarget:self
                                                   selector:@selector(refresh)
                                                     object:nil];
    }];
}

- (void)setRefreshStage:(BBModelManagerRefreshStage)refreshStage {
    
    if (_refreshStage == refreshStage) {
        return;
    }
    
    _refreshStage = refreshStage;

    [self postAsyncNotificationWithName:BBModelManagerDidChangeRefreshStageNotification];
}

- (void)postNotificationForRefreshProgress:(float)progress {
    
    if (progress < 0.f) {
        return;
    }
    
    [self postNotificationWithName:BBModelManagerRefreshProgressNotification
                          userInfo:@{BBModelManagerRefreshProgressNotificationKey: @(progress)}];
}

- (void)postNotificationForRefreshError:(NSError *)error {
    
    if (error == nil) {
        return;
    }
    
    [self postNotificationWithName:BBModelManagerRefreshErrorNotification
                          userInfo:@{BBModelManagerRefreshErrorNotificationKey: error}];
}

#pragma mark - Cleanup

- (void)cleanup
{
    [self deleteEntitiesFetchedWithRequest:[BBTag withoutMixesFetchRequest]];
    
    [self deleteEntitiesFetchedWithRequest:[BBMix withoutTagsFetchRequest]];
    
    [self deepSaveFromContext:self.mainContext];
}

- (void)deleteEntitiesFetchedWithRequest:(NSFetchRequest *)fetchRequest
{
    NSArray *entities = [self entitiesFetchedWithRequest:fetchRequest
                                               inContext:self.mainContext];
    if (!entities.count)
        return;
    
    [entities enumerateObjectsUsingBlock:
     ^(BBEntity *entity, NSUInteger entityIdx, BOOL *entityStop)
    {
        [self.mainContext deleteObject:entity];
    }];
    
    BB_WRN(@"Deleted %d \"%@\"", entities.count, fetchRequest.entityName);
}

#pragma mark - Core Data

#pragma mark * Fetch

- (NSFetchRequest *)fetchRequestForTagsWithSelectionOptions:(BBTagsSelectionOptions *)options
{
    NSFetchRequest *fetchRequest =
    [BBTag fetchRequestWithMixesCategory:options.category];
    
    if (options.sortKey == eTagNameSortKey)
        [fetchRequest setSortDescriptors:@[[BBTag nameSortDescriptor]]];
    
    fetchRequest.fetchOffset = options.offset;
    fetchRequest.fetchLimit = options.limit;
    
    return fetchRequest;
}

- (NSFetchRequest *)fetchRequestForMixesWithSelectionOptions:(BBMixesSelectionOptions *)options
{
    BBTag *tag = options.tag;
    if ([tag isEqualToEntity:[self allTag]]) {
        tag = nil;
    }
    
    NSFetchRequest *fetchRequest =
    [BBMix fetchRequestWithCategory:options.category
                    substringInName:options.substringInName
                                tag:tag];
    
    
    [fetchRequest setSortDescriptors:
     [self sortDescriptorsForMixesSelectionOptions:options]];
    
    fetchRequest.fetchOffset = options.offset;
    fetchRequest.fetchLimit = options.limit;
    
    return fetchRequest;
}

- (NSArray *)entitiesFetchedWithRequest:(NSFetchRequest *)fetchRequest
                              inContext:(NSManagedObjectContext *)context
{
    _error = nil;
    
    NSArray *__block result = nil;
    [context performBlockAndWait:^{
        
        NSError *__autoreleasing error = nil;
        result = [context executeFetchRequest:fetchRequest error:&error];
        
        [self handleError:error];
    }];
    
    return result;
}

- (NSUInteger)countOfFetchedEntitiesWithRequest:(NSFetchRequest *)fetchRequest
                                      inContext:(NSManagedObjectContext *)context
{
    _error = nil;
    
    NSUInteger __block count = 0;
    [context performBlockAndWait:^{
        
        NSError *__autoreleasing error = nil;
        count = [context countForFetchRequest:fetchRequest error:&error];
    
        [self handleError:error];
    }];
    
    return count;
}

#pragma mark * Save

- (void)deepSaveFromContext:(NSManagedObjectContext *)context
{
    [self deepSaveFromContext:context withCompletionBlock:nil];
}

- (void)deepSaveFromContext:(NSManagedObjectContext *)context
        withCompletionBlock:(void(^)(BOOL saved))completionBlock
{
    [context performBlock:^
    {
        __block BOOL saved = NO;
        
        [self saveContext:context
      withCompletionBlock:^(BOOL contextSaved)
        {
            saved = contextSaved;
        }];
        
        if (!saved || !context.parentContext)
        {
            if (completionBlock)
                completionBlock(saved);
        
            return;
        }
        
        [self deepSaveFromContext:context.parentContext
              withCompletionBlock:completionBlock];
    }];
}

- (void)saveContext:(NSManagedObjectContext *)context
withCompletionBlock:(void(^)(BOOL saved))completionBlock
{
    _error = nil;

    NSString *description = [self descriptionForContext:context];
    
    if (![context hasChanges])
    {
        BB_INF(@"No changes in %@ context", description);
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
            completionBlock(saved);
    }
}

#pragma mark * Stack

- (NSManagedObjectContext *)tempContext {
    
    if (_tempContext == nil) {
     
        _tempContext = [self serviceContextWithTaskDescription:@"temp"];
    }
    
    return _tempContext;
}

- (NSManagedObjectContext *)rootContext
{
    if (!_rootContext && self.coordinator)
    {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [self setDescription:@"ROOT" forContext:_rootContext];
        
        [_rootContext performBlockAndWait:^
        {
            [_rootContext setPersistentStoreCoordinator:self.coordinator];
            [_rootContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        }];
    }
    
    return _rootContext;
}

- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext)
    {
        _mainContext = [[NSManagedObjectContext alloc]
                           initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_mainContext setParentContext:self.rootContext];
        
        [self setDescription:@"MAIN" forContext:_mainContext];
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)currentThreadContext
{
	if ([NSThread isMainThread]) {
		return self.mainContext;
	}
    
    @synchronized(self) {
        
        NSThread *thread = [NSThread currentThread];
        NSMutableDictionary *threadDict = [thread threadDictionary];
        NSManagedObjectContext *threadContext = [threadDict objectForKey:[NSValue valueWithNonretainedObject:thread]];
        if (threadContext == nil) {
            
            threadContext = [self serviceContextWithTaskDescription:thread.name];
            
            [threadDict setObject:threadContext forKey:[NSValue valueWithNonretainedObject:thread]];
        }
    
        return threadContext;
    }
}

- (NSManagedObjectContext *)serviceContextWithTaskDescription:(NSString *)taskDescription
{
    NSManagedObjectContext *context =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [context setParentContext:self.mainContext];
    
    NSString *description =
    [NSString stringWithFormat:@"SERVICE \"%@\"", taskDescription];
    
    [self setDescription:description forContext:context];
    
    return context;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    if (!_coordinator)
    {
        NSManagedObjectModel *model =
        [NSManagedObjectModel mergedModelFromBundles:nil];
        
        _coordinator = [[NSPersistentStoreCoordinator alloc]
                        initWithManagedObjectModel:model];
    
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
    NSDictionary *sqliteOptions = @{@"journal_mode" : @"WAL"};
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @YES, NSMigratePersistentStoresAutomaticallyOption,
                             @YES, NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption, nil];
    
    NSError __autoreleasing *error = nil;
    NSURL *url = [[BBFileManager documentDirectoryURL]
                  URLByAppendingPathComponent:@"BassBlog.sqlite"];
    
    _error = nil;
    
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
    
        [self handleError:error];
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

- (void)setDescription:(NSString *)description
            forContext:(NSManagedObjectContext *)context
{
    [context.userInfo setObject:description
                         forKey:BBManagedObjectContextDescriptionKey];
}

- (NSString *)descriptionForContext:(NSManagedObjectContext *)context
{
    return [context.userInfo objectForKey:BBManagedObjectContextDescriptionKey];
}

#pragma mark * Error Handling

- (void)handleError:(NSError *)error
{
    if (!error)
        return;
    
    [error.userInfo.allValues enumerateObjectsUsingBlock:
     ^(id detailedError, NSUInteger detailedErrorIdx, BOOL *detailedErrorStop)
    {
        if (![detailedError isKindOfClass:[NSArray class]])
        {
            BB_ERR(@"%@", detailedError);
            
            return;
        }
        
        [detailedError enumerateObjectsUsingBlock:
         ^(id anError, NSUInteger anErrorIdx, BOOL *anErrorStop)
        {
            if ([anError respondsToSelector:@selector(userInfo)])
            {
                BB_ERR(@"%@", [anError userInfo]);
            }
            else
            {
                BB_ERR(@"%@", anError);
            }
        }];
    }];
    
    BB_ERR(@"Info: \n%@", error);
    
    self.error = error;
}

#ifdef DEBUG

#pragma mark - Debug

- (void)managedObjectContextWillSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *context = notification.object;
    
    if (context != _mainContext) {
        return;
    }
    
    NSMutableString *dump = [NSMutableString string];
    
    if (context.deletedObjects.count)
    {
        [dump appendFormat:@"\n\nDeleted objects: %@",
         [self descriptionOfEntities:context.deletedObjects]];
    }
    
    if (context.insertedObjects.count)
    {
        [dump appendFormat:@"\n\nInserted objects: %@",
         [self descriptionOfEntities:context.insertedObjects]];
    }
    
    if (context.updatedObjects.count)
    {
        [dump appendFormat:@"\n\nUpdated objects: %@",
         [self descriptionOfEntities:context.updatedObjects
                    includingChanges:YES]];
    }
    
    if (dump.length)
    {
        BB_DBG(@"Changes in %@ context: %@",
            [self descriptionForContext:context], dump);
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
                [changesDescription appendFormat:@"\n\t\t[%@] : %@",
                 entity.key, entity.changedValues];
        }
        else
            ++tagsCount;
    }];
    
    NSMutableString *description =
    [NSMutableString stringWithFormat:@"%d", entities.count];
    
    if (mixesCount)
        [description appendFormat:@"\n\n\tMixes: %d %@", mixesCount, changesDescription];
    
    if (tagsCount)
        [description appendFormat:@"\n\n\tTags: %d", tagsCount];

    return description;
}

- (void)dumpContext:(NSManagedObjectContext *)context
{
    // Dump on changes and very first time only.
    
    static BOOL firstDump = YES;
    
    if (!firstDump && ![context hasChanges])
        return;
    
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
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions];
    
    [dump appendFormat:@"\n\n\tAll mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Favorite mixes ----------------------------------------------------------
    
    mixesSelectionOptions.category = eFavoriteMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions];
    
    [dump appendFormat:@"\n\t\tFavorite mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Listened mixes ----------------------------------------------------------
    
    mixesSelectionOptions.category = eListenedMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions];
    
    [dump appendFormat:@"\n\t\tListened mixes: %d",
     [self countOfFetchedEntitiesWithRequest:fetchRequest
                                   inContext:context]];
    
    // Downloaded mixes --------------------------------------------------------
    
    mixesSelectionOptions.category = eDownloadedMixesCategory;
    fetchRequest =
    [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions];
    
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
        [self fetchRequestForMixesWithSelectionOptions:mixesSelectionOptions];
        
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
