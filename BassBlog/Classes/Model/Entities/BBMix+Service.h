//
//  BBMix+CoreDataGeneratedAccessors.h
//  BassBlog
//
//  Created by Evgeny Sivko on 31.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity+Service.h"

#import "BBMixesCategory.h"

#import "BBMix.h"


@class BBTag;

@interface BBMix (Service)

#pragma mark Fetch

+ (NSFetchRequest *)fetchRequestWithCategory:(BBMixesCategory)category
                             substringInName:(NSString *)substringInName
                                         tag:(BBTag *)tag;

+ (NSFetchRequest *)fetchRequestWithID:(NSString *)ID;

+ (NSFetchRequest *)withoutTagsFetchRequest;

#pragma mark - Sort descriptor

+ (NSSortDescriptor *)IDSortDescriptor;

+ (NSSortDescriptor *)dateSortDescriptor;

+ (NSSortDescriptor *)playbackDateSortDescriptor;

#pragma mark - Predicate format

+ (NSString *)downloadedPredicateFormat;

+ (NSString *)listenedPredicateFormat;

+ (NSString *)favoritePredicateFormat;

@end

#pragma mark -

@interface BBMix (CoreDataGeneratedAccessors)

- (void)addTagsObject:(BBTag *)value;
- (void)removeTagsObject:(BBTag *)value;

- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
