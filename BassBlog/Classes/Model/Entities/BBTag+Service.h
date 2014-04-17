//
//  BBTag+CoreDataGeneratedAccessors.h
//  BassBlog
//
//  Created by Evgeny Sivko on 31.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity+Service.h"

#import "BBMixesCategory.h"

#import "BBTag.h"


@class BBMix;

@interface BBTag (Service)

+ (NSSortDescriptor *)nameSortDescriptor;

+ (NSFetchRequest *)fetchRequestWithMixesCategory:(BBMixesCategory)mixesCategory;

+ (NSFetchRequest *)fetchRequestWithName:(NSString *)name;

+ (NSFetchRequest *)withoutMixesFetchRequest;

@end

#pragma mark -

@interface BBTag (CoreDataGeneratedAccessors)

- (void)addMixesObject:(BBMix *)value;
- (void)removeMixesObject:(BBMix *)value;

- (void)addMixes:(NSSet *)values;
- (void)removeMixes:(NSSet *)values;

@end
