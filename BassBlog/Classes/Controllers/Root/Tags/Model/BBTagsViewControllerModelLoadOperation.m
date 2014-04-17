//
//  BBTagsViewControllerModelLoadOperation.m
//  BassBlog
//
//  Created by Evgeny Sivko on 30.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTagsViewControllerModelLoadOperation.h"

#import "BBTagsSelectionOptions.h"
#import "BBModelManager.h"
#import "BBTag.h"

#import "BBTableModel.h"

#import "BBTimeProfiler.h"


@interface BBTagsViewControllerModelLoadOperation ()

TIME_PROFILER_PROPERTY_DECLARATION

@end

@implementation BBTagsViewControllerModelLoadOperation

TIME_PROFILER_PROPERTY_IMPLEMENTATION

- (void)main {

    if ([self isCancelled]) {
        
        [self finishAfterBlock:nil];
        return;
    }
    
    @autoreleasepool {
    
        TIME_PROFILER_MARK_TIME
        
        NSArray *tags = [[BBModelManager defaultManager] tagsWithSelectionOptions:self.tagsSelectionOptions];
        if (tags.count == 0) {
        
            [self finishAfterBlock:^{
                
                self.completed = (self.tagsSelectionOptions.category != eAllMixesCategory);
                
                TIME_PROFILER_LOG(@"Tags [%@] not found", self.tagsSelectionOptions)
            }];
            
            return;
        }
        
        NSMutableArray *tagObjectIDs = [NSMutableArray arrayWithCapacity:tags.count];
        for (BBTag *tag in tags) {
            
            [tagObjectIDs addObject:[tag objectID]];
            
            self.handleEntity(self, tag);
            
            if ([self isCancelled]) {
                break;
            }
        }
        
        [self finishAfterBlock:^{
            
            self.completed = [self tagsDictionaryFilledWithTagObjectIDs:tagObjectIDs];
            
            TIME_PROFILER_LOG(@"Tags [%@] fetched(%d)", self.tagsSelectionOptions, tagObjectIDs.count)
        }];
    
    } // @autoreleasepool
}

- (BOOL)tagsDictionaryFilledWithTagObjectIDs:(NSArray *)tagObjectIDs {
    
    __block BOOL tagsDictionaryFilled = YES;
    
    [[BBModelManager defaultManager] enumerateObjectIDs:tagObjectIDs
                                             usingBlock:^(BBTag *tag, NSUInteger idx, BOOL *stop)
    {
        if (tag) {
             
            [self.tagsDictionary setObject:tag forKey:tag.key];
            return;
        }
         
        tagsDictionaryFilled = NO;
        *stop = YES;
    }];
    
    return tagsDictionaryFilled;
}

@end
