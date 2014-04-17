//
//  BBEntity.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import <CoreData/NSManagedObject.h>


@interface BBEntity : NSManagedObject

- (BOOL)isEqualToEntity:(BBEntity *)entity;

@end

#pragma mark -

@interface BBEntity (Abstract)

- (NSString *)key;

@end