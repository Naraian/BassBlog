//
//  BBModelManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 13.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//


extern NSString *const BBModelManagerDidInitializeNotification;

extern NSString *const BBModelManagerDidFinishRefreshNotification;

extern NSString *const BBModelManagerDidChangeRefreshStageNotification;

extern NSString *const BBModelManagerDidFinishSaveNotification;

extern NSString *const BBModelManagerRefreshProgressNotification;
extern NSString *const BBModelManagerRefreshProgressNotificationKey;

extern NSString *const BBModelManagerRefreshErrorNotification;
extern NSString *const BBModelManagerRefreshErrorNotificationKey;

typedef NS_ENUM(NSUInteger, BBModelManagerRefreshStage) {
  
    BBModelManagerWaitingStage,
    BBModelManagerLoadingStage,
    BBModelManagerParsingStage,
    BBModelManagerSavingStage
};

@class BBTag;
@class BBTagsSelectionOptions;
@class BBMixesSelectionOptions;

@class NSFetchRequest;

@interface BBModelManager : NSObject

+ (BBModelManager *)defaultManager;

- (NSFetchRequest *)fetchRequestForTagsWithSelectionOptions:(BBTagsSelectionOptions *)options;
- (NSFetchRequest *)fetchRequestForMixesWithSelectionOptions:(BBMixesSelectionOptions *)options forSearch:(BOOL)search;
- (NSManagedObjectContext *)currentThreadContext;
- (NSManagedObjectContext *)rootContext;

+ (void)saveContext:(NSManagedObjectContext *)context withCompletionBlock:(void(^)(NSError *error))completionBlock;

#pragma mark - State

+ (BOOL)isModelEmpty;

- (BOOL)isInitialized;

- (BOOL)isSaveInProgress;

- (void)refresh;
- (BOOL)fetchDatabaseIfNecessary;

- (BBModelManagerRefreshStage)refreshStage;

#pragma mark - Entities

- (NSUInteger)countOfFetchedEntitiesWithRequest:(NSFetchRequest *)fetchRequest
                                      inContext:(NSManagedObjectContext *)context;

- (void)enumerateObjectIDs:(NSArray *)objectIDs
                usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

#pragma mark - Sort descriptors

- (NSArray *)sortDescriptorsForMixesSelectionOptions:(BBMixesSelectionOptions *)options;

@end
