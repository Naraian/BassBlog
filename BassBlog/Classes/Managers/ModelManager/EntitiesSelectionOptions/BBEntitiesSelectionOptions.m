//
//  BBEntitiesSelectionOptions.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesSelectionOptions.h"


@implementation BBEntitiesSelectionOptions

- (id)mutableCopyWithZone:(NSZone *)zone
{
    BBEntitiesSelectionOptions *copy = [[self class] new];
    
    if (copy) {
        
        [copy setSortKey:self.sortKey];
        [copy setCategory:self.category];
        
        [copy setOffset:self.offset];
        [copy setLimit:self.limit];
    }
    
    return copy;
}

- (NSString *)description {
    
    NSMutableString *string =
    [NSMutableString stringWithFormat:@"category(%@)", [self categoryString]];
    
    if (self.offset) {
        [string appendFormat:@", offset(%lu)", (unsigned long)self.offset];
    }
    
    if (self.limit) {
        [string appendFormat:@", limit(%lu)", (unsigned long)self.limit];
    }
    
    return string;
}

- (NSString *)categoryString {
    
    switch (self.category) {
        
        case eAllMixesCategory:
            return @"all";
            
        case eDownloadedMixesCategory:
            return @"downloaded";
            
        case eSearchMixesCategory:
            return @"search";
            
        case eFavoriteMixesCategory:
            return @"favorite";
            
        case eListenedMixesCategory:
            return @"listened";            
    }
}

- (NSString *)sortKeyString {
    
    if (self.sortKey == eEntityNoneSortKey) {
        return @"none";
    }
    
    return @"unknown";
}

- (NSUInteger)totalLimit {
    
    return self.offset + self.limit;
}

@end
