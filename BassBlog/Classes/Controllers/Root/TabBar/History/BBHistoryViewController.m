//
//  BBHistoryViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHistoryViewController.h"

#import "BBHistoryTableViewCell.h"

#import "BBMixesViewControllerModelLoadOperation.h"
#import "BBTableModel.h"
#import "BBMix.h"

#import "NSObject+Notification.h"


@implementation BBHistoryViewController

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self setTabBarItemTitle:NSLocalizedString(@"HISTORY", @"")
                      imageNamed:@"history_icon"
                             tag:eListenedMixesCategory];
        
        _tableModelSectionRule = BBMixesTableModelSectionRuleEachDay;
        
        _mixesSelectionOptions.category = eListenedMixesCategory;
        _mixesSelectionOptions.sortKey = eMixPlaybackDateSortKey;
    }
    
    return self;
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBHistoryTableViewCell nibName];
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
    
    __weak BBHistoryViewController *weakSelf = self;
    
    operation.handleEntity = ^(BBMixesViewControllerModelLoadOperation *anOperation, BBMix *mix) {
        
        NSInteger sectionID = [weakSelf sectionIDForMix:mix];
        
        [anOperation.tableModel addCellKey:mix.key toSectionID:sectionID];
        anOperation.detailTextsDictionary[mix.key] = [weakSelf detailTextForMix:mix];
        
        if (anOperation.headerTextsDictionary[@(sectionID)] == nil) {
            anOperation.headerTextsDictionary[@(sectionID)] = [weakSelf headerTextForMix:mix];
        }
    };
    
    return operation;
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
    
    [self addSelector:@selector(mixDidChangePlaybackDateNotification:)
    forNotificationWithName:BBMixDidChangePlaybackDateNotification];
}

- (void)mixDidChangePlaybackDateNotification:(NSNotification *)notification {
    
    [self mergeWithEntity:notification.object];
}

@end
