//
//  BBMixesViewControllerModelLoadOperation.m
//  BassBlog
//
//  Created by Evgeny Sivko on 31.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesViewControllerModelLoadOperation.h"

#import "BBMixesSelectionOptions.h"
#import "BBModelManager.h"
#import "BBMix.h"
#import "BBTag.h"

#import "BBTableModel.h"

#import "BBTimeProfiler.h"


static const CGFloat kBBFetchLimitIncreaseRatio = 1.34;

@interface BBMixesViewControllerModelLoadOperation ()

TIME_PROFILER_PROPERTY_DECLARATION

@end

@implementation BBMixesViewControllerModelLoadOperation

TIME_PROFILER_PROPERTY_IMPLEMENTATION

- (void)main {
    
    if ([self isCancelled]) {
        
        [self finishAfterBlock:nil];
        return;
    }
    
    @autoreleasepool {
        
        TIME_PROFILER_MARK_TIME
        
        NSArray *mixes = [[BBModelManager defaultManager] mixesWithSelectionOptions:self.mixesSelectionOptions];
        if (mixes.count == 0) {
            
            [self finishAfterBlock:^{
                
                self.completed = (self.mixesSelectionOptions.category != eAllMixesCategory);
                
                TIME_PROFILER_LOG(@"Mixes [%@] not found", self.mixesSelectionOptions)
            }];
            
            return;
        }
        
        NSMutableArray *mixObjectIDs = [NSMutableArray arrayWithCapacity:self.mixesSelectionOptions.limit];
        for (BBMix *mix in mixes) {
            
            [mixObjectIDs addObject:[mix objectID]];
            
            self.handleEntity(self, mix);
            
            if ([self isCancelled]) {
                break;
            }
        }
        
        [self finishAfterBlock:^{
            
            self.completed = [self mixesContainersFilledWithMixObjectIDs:mixObjectIDs];
            
            TIME_PROFILER_LOG(@"Mixes [%@], fetched(%d)", self.mixesSelectionOptions, mixObjectIDs.count)
        }];
        
    } // @autoreleasepool
}

- (BOOL)mixesContainersFilledWithMixObjectIDs:(NSArray *)mixObjectIDs {
    
    __block BOOL mixesContainersFilled = YES;
    
    [[BBModelManager defaultManager] enumerateObjectIDs:mixObjectIDs
                                             usingBlock:^(BBMix *mix, NSUInteger idx, BOOL *stop)
    {
        if (mix) {
             
            [self.mixesArray addObject:mix];
            [self.mixesDictionary setObject:mix forKey:mix.key];
             
            return;
        }
         
        mixesContainersFilled = NO;
        *stop = YES;
    }];
    
    return mixesContainersFilled;
}

@end
