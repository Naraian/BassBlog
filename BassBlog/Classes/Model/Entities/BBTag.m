//
//  BBTag.m
//  BassBlog
//
//  Created by Evgeny Sivko on 29.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTag+Service.h"
#import "BBMix+Service.h"

#import <CoreData/NSFetchRequest.h>


@implementation BBTag

@dynamic name;
@dynamic mixes;

- (NSString *)key {
    
    return self.name;
}

+ (NSString *)allName {
    
    return @"all mixes";
}

+ (NSArray *)formalNames {
    
    return @[@"drum and bass",
             @"320 kbps",
             @"deep",
             @"drumfunk",
             @"dubstep",
             @"hard",
             @"light",
             @"liquid",
             @"neurofunk",
             @"oldschool",
             @"ragga-jungle"];
}

+ (NSSet *)formalNamesOfTags:(NSSet *)tags
{
    NSArray *formalNames = [self formalNames];
    NSMutableSet *names = [NSMutableSet setWithCapacity:formalNames.count];
    
    for (BBTag *tag in tags)
    {
        NSString *tagName = tag.name;
        
        if ([formalNames containsObject:tagName])
        {
            [names addObject:tagName];
        }
    }
    
    return names;
}

@end

#pragma mark -

@implementation BBTag (Service)

+ (NSSortDescriptor *)nameSortDescriptor {
    
    return [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
}

+ (NSFetchRequest *)fetchRequestWithMixesCategory:(BBMixesCategory)mixesCategory {
    
    NSMutableString *format = [NSMutableString stringWithString:@"name in %@"];
    
    if (mixesCategory != eAllMixesCategory)
        [format appendString:@" && ANY mixes."];
    
    switch (mixesCategory)
    {
        case eDownloadedMixesCategory:
            [format appendString:[BBMix downloadedPredicateFormat]];
            break;
            
        case eFavoriteMixesCategory:
            [format appendString:[BBMix favoritePredicateFormat]];
            break;
            
        case eListenedMixesCategory:
            [format appendString:[BBMix listenedPredicateFormat]];
            break;
            
        default:
            break;
    }
    
    return [self fetchRequestWithPredicateFormat:format
                                   argumentArray:@[[self formalNames]]];
}

+ (NSFetchRequest *)fetchRequestWithName:(NSString *)name {
    
    return [self fetchRequestWithPredicateFormat:@"name == %@", name];
}

+ (NSFetchRequest *)withoutMixesFetchRequest {
    
    return [self fetchRequestWithPredicateFormat:@"mixes.@count == 0"];
}

@end
