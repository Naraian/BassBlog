//
//  BBTag.h
//  BassBlog
//
//  Created by Evgeny Sivko on 29.05.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntity.h"


@interface BBTag : BBEntity

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *mixes;

@property (nonatomic, readonly) BOOL isAllTag;
@property (nonatomic, readonly) NSString *formattedName;

+ (NSSet *)formalNamesOfTags:(NSSet *)tags;

+ (NSString *)allName;

@end
