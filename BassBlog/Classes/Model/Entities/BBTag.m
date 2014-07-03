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
@dynamic mainTag;
@dynamic mixes;

- (NSString *)key
{
    return self.name;
}

+ (NSString *)allName
{
    return @"ALL MIXES";
}

+ (NSString *)allNameInternal
{
    return @"drum and bass";
}

+ (NSDictionary *)formalNames
{
    static NSDictionary *sFormalNames = nil;
    
    if (!sFormalNames)
    {
        sFormalNames  = @{@"drum and bass"  : @"dnb",
                          @"320 kbps"       : @"320 kbps",
                          @"deep"           : @"deep",
                          @"drumfunk"       : @"drumfunk",
                          @"dubstep"        : @"dubstep",
                          @"hard"           : @"hard",
                          @"light"          : @"light",
                          @"liquid"         : @"liquid",
                          @"neurofunk"      : @"neurofunk",
                          @"oldschool"      : @"oldschool",
                          @"ragga-jungle"   : @"ragga-jungle"};
    }
    
    return sFormalNames;
}

+ (NSSet *)formalNamesOfTags:(NSSet *)tags
{
    NSDictionary *formalNames = [self formalNames];
    NSMutableSet *names = [NSMutableSet setWithCapacity:formalNames.count];
    
    for (BBTag *tag in tags)
    {
        NSString *tagName = [formalNames objectForKey:tag.name];
        
        if (tagName)
        {
            [names addObject:tagName];
        }
    }
    
    return names;
}

- (NSString *)formattedName
{
    return [self.name uppercaseString];
}

@end

#pragma mark -

@implementation BBTag (Service)

+ (NSSortDescriptor *)mainTagSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"mainTag" ascending:NO];
}

+ (NSSortDescriptor *)nameSortDescriptor
{
    return [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
}

+ (NSFetchRequest *)fetchRequestWithMixesCategory:(BBMixesCategory)mixesCategory {
    
    NSMutableString *format = [NSMutableString stringWithString:@"name in %@"];
    
    if (mixesCategory != eAllMixesCategory)
    {
        [format appendString:@" && ANY mixes."];
    }
    
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
                                   argumentArray:@[[[self formalNames] allKeys]]];
}

+ (NSFetchRequest *)fetchRequestWithName:(NSString *)name {
    
    return [self fetchRequestWithPredicateFormat:@"name == %@", name];
}

+ (NSFetchRequest *)withoutMixesFetchRequest {
    
    return [self fetchRequestWithPredicateFormat:@"mixes.@count == 0"];
}

@end
