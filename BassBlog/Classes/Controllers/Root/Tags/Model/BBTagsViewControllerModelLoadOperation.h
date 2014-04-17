//
//  BBTagsViewControllerModelLoadOperation.h
//  BassBlog
//
//  Created by Evgeny Sivko on 30.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewControllerModelLoadOperation.h"


@class BBTableModel;
@class BBTagsSelectionOptions;

@interface BBTagsViewControllerModelLoadOperation : BBEntitiesViewControllerModelLoadOperation

@property (nonatomic) BBTableModel *tableModel;
@property (nonatomic) NSMutableDictionary *tagsDictionary;
@property (nonatomic) NSMutableDictionary *mixesCountNumbersDictionary;
@property (nonatomic) BBTagsSelectionOptions *tagsSelectionOptions;

@end
