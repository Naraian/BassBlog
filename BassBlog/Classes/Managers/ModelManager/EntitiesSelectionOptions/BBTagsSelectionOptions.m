//
//  BBTagsSelectionOptions.m
//  BassBlog
//
//  Created by Evgeny Sivko on 15.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTagsSelectionOptions.h"


@implementation BBTagsSelectionOptions

- (NSString *)description {
    
    NSMutableString *string =
    [NSMutableString stringWithString:[super description]];
    
    if (self.sortKey) {
        [string appendFormat:@", sortKey(%@)", [self sortKeyString]];
    }
    
    return string;
}

- (NSString *)sortKeyString {
    
    if (self.sortKey == eTagNameSortKey) {
        return @"name";
    }

    return [super sortKeyString];
}

@end
