//
//  BBEntitiesViewControllerModelLoadOperation.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.10.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewControllerModelLoadOperation.h"

#import "NSObject+Thread.h"


@interface BBEntitiesViewControllerModelLoadOperation ()

@property (nonatomic, getter = isCompleted) BOOL completed;

@end

@implementation BBEntitiesViewControllerModelLoadOperation

- (void)finishAfterBlock:(void(^)())blockOrNil {
    
    if ([self isCancelled]) {
        return;
    }
    
    [self.class mainThreadBlock:^{
        
        if (blockOrNil) {
            blockOrNil();
        }
        
        if (self.finish) {
            self.finish(self);
        }
    }];
}

@end
