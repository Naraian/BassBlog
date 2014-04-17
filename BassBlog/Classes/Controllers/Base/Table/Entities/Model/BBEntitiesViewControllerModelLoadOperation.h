//
//  BBEntitiesViewControllerModelLoadOperation.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.10.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@interface BBEntitiesViewControllerModelLoadOperation : NSOperation

@property (nonatomic, copy) void (^finish)(id anOperation);
@property (nonatomic, copy) void (^handleEntity)(id anOperation, id anEntity);

- (BOOL)isCompleted;

@end

@interface BBEntitiesViewControllerModelLoadOperation (Protected)

- (void)finishAfterBlock:(void(^)())blockOrNil;

- (void)setCompleted:(BOOL)completed;

@end
