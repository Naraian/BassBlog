//
//  BBEntity+Service.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity.h"


@class NSFetchRequest;
@class NSEntityDescription;

@interface BBEntity (Service)

+ (id)createInContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)fetchRequest;

+ (NSFetchRequest *)fetchRequestWithPredicateFormat:(NSString *)format, ...;

+ (NSFetchRequest *)fetchRequestWithPredicateFormat:(NSString *)format
                                      argumentArray:(NSArray *)arguments;
+ (NSString *)entityName;

@end
