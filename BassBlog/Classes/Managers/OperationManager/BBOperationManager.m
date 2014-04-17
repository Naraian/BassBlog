//
//  BBOperationManager.m
//  BassBlog
//
//  Created by Evgeny Sivko on 29.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBOperationManager.h"

#import "NSObject+Notification.h"

#import "BBMacros.h"


static NSString *const NSOperationQueueOperationCountKeyPath = @"operationCount";

DEFINE_CONST_NSSTRING(BBOperationManagerDidFinishAllOperations);

@interface BBOperationManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BBOperationManager

SINGLETON_IMPLEMENTATION(BBOperationManager, defaultManager)

- (NSOperationQueue *)operationQueue {
    
    if (_operationQueue == nil) {
        
        _operationQueue = [NSOperationQueue new];
    
        [_operationQueue addObserver:self
                          forKeyPath:NSOperationQueueOperationCountKeyPath
                             options:kNilOptions
                             context:NULL];
        
        // TODO: test, do we need to set max concurent operations?
    }
    
    return _operationQueue;
}

- (void)addOperation:(NSOperation *)operation {
    
    [self.operationQueue addOperation:operation];
}

- (void)addOperationWithBlock:(void (^)(void))block {
    
    [self.operationQueue addOperationWithBlock:block];
}

- (BOOL)noOperations {

    return self.operationQueue.operationCount == 0;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSAssert(object == self.operationQueue, @"%s object != self.operationQueue", __FUNCTION__);
    
    if ([keyPath isEqualToString:NSOperationQueueOperationCountKeyPath] == NO) {
        return;
    }
    
    if (self.noOperations) {
        
        [self postNotificationWithName:BBOperationManagerDidFinishAllOperations];
    }
}

@end
