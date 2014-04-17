//
//  BBEntity.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity+Service.h"

#import "CoreData/NSFetchRequest.h"
#import "CoreData/NSEntityDescription.h"


@implementation BBEntity

- (BOOL)isEqualToEntity:(BBEntity *)entity
{
    return [self.key isEqualToString:entity.key];
}

@end

#pragma mark -

@implementation BBEntity (Service)

+ (id)createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    [fetchRequest setIncludesSubentities:NO];
    
    return fetchRequest;
}

+ (NSFetchRequest *)fetchRequestWithPredicateFormat:(NSString *)format, ...
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    if (format.length)
    {
        va_list arguments;
        va_start(arguments, format);
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:format
                                                          arguments:arguments]];
    }
    
    return fetchRequest;
}

+ (NSFetchRequest *)fetchRequestWithPredicateFormat:(NSString *)format
                                      argumentArray:(NSArray *)arguments
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    if (format.length)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:format
                                                      argumentArray:arguments]];
    return fetchRequest;
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

@end
