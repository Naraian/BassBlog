//
//  BBMixesSelectionOptions.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesSelectionOptions.h"


@implementation BBMixesSelectionOptions

- (id)mutableCopyWithZone:(NSZone *)zone
{
    BBMixesSelectionOptions *copy = [super mutableCopyWithZone:zone];
    
    if (copy) {
        
        [copy setTag:self.tag];
        [copy setSubstringInName:[self.substringInName copyWithZone:zone]];
    }
    
    return copy;
}

- (NSString *)description {
    
    NSMutableString *string =
    [NSMutableString stringWithString:[super description]];
    
    if (self.sortKey) {
        [string appendFormat:@", sortKey(%@)", [self sortKeyString]];
    }
    
    return string;
}

- (NSString *)sortKeyString {
    
    switch (self.sortKey) {
    
        case eMixDateSortKey:
            return @"date";
            
        case eMixPlaybackDateSortKey:
            return @"playback date";
    
        default:
            return [super sortKeyString];
    }
}

@end
