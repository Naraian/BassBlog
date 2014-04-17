//
//  BBEntitiesSelectionOptions.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesCategory.h"


enum { eEntityNoneSortKey = 0 };

typedef NSUInteger BBEntitiesSortKey;

@interface BBEntitiesSelectionOptions : NSObject <NSMutableCopying>

@property (nonatomic, assign) BBEntitiesSortKey sortKey;
@property (nonatomic, assign) BBMixesCategory category;

@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger limit;

- (NSString *)categoryString;

- (NSString *)sortKeyString;

- (NSUInteger)totalLimit;

@end
