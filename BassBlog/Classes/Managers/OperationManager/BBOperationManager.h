//
//  BBOperationManager.h
//  BassBlog
//
//  Created by Evgeny Sivko on 29.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//


extern NSString *const BBOperationManagerDidFinishAllOperations;

@interface BBOperationManager : NSObject

+ (BBOperationManager *)defaultManager;

- (void)addOperation:(NSOperation *)operation;

- (void)addOperationWithBlock:(void (^)(void))block;

- (BOOL)noOperations;

@end
