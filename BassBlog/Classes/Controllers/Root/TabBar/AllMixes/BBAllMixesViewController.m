//
//  BBAllMixesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAllMixesViewController.h"

#import "BBMixesTableSectionHeaderView.h"
#import "BBAllMixesTableViewCell.h"

#import "BBMixesViewControllerModelLoadOperation.h"
#import "BBTableModel.h"
#import "BBMix.h"

#import "NSObject+Nib.h"
#import "BBUIUtils.h"


@implementation BBAllMixesViewController

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self setTabBarItemTitle:NSLocalizedString(@"ALL MIXES", @"")
                      imageNamed:@"all_mixes_icon"
                             tag:eAllMixesCategory];
        
        _tableModelSectionRule = BBMixesTableModelSectionRuleEachMonth;
    }
    
    return self;
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBAllMixesTableViewCell nibName];
}

#pragma mark - Model

- (id)modelReloadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [super modelReloadOperation];
    
    operation.detailTextsDictionary = [NSMutableDictionary new];
    operation.headerTextsDictionary = [NSMutableDictionary new];
    
    return operation;
}

- (BBMixesViewControllerModelLoadOperation *)modelLoadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [super modelLoadOperation];
    
    __weak BBAllMixesViewController *weakSelf = self;
    
    operation.handleEntity = ^(BBMixesViewControllerModelLoadOperation *anOperation, BBMix *mix) {
        
        NSInteger sectionID = [weakSelf sectionIDForMix:mix];
        
        [anOperation.tableModel addCellKey:mix.key toSectionID:sectionID];
        anOperation.detailTextsDictionary[mix.key] = [BBUIUtils tagsStringForMix:mix];
        
        if (anOperation.headerTextsDictionary[@(sectionID)] == nil) {
            anOperation.headerTextsDictionary[@(sectionID)] = [weakSelf headerTextForMix:mix];
        }
    };
    
    return operation;
}

@end
