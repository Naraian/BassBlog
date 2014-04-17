//
//  BBMixesViewControllerModelLoadOperation.h
//  BassBlog
//
//  Created by Evgeny Sivko on 31.08.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewControllerModelLoadOperation.h"


@class BBMix;
@class BBTableModel;
@class BBMixesSelectionOptions;

@interface BBMixesViewControllerModelLoadOperation : BBEntitiesViewControllerModelLoadOperation

@property (nonatomic) NSMutableArray *mixesArray;
@property (nonatomic) NSMutableDictionary *mixesDictionary;
@property (nonatomic) NSMutableDictionary *detailTextsDictionary;
@property (nonatomic) NSMutableDictionary *headerTextsDictionary;
@property (nonatomic) BBMixesSelectionOptions *mixesSelectionOptions;
@property (nonatomic) BBTableModel *tableModel;

@end
