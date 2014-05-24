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
#import "BBAudioManager.h"

#import "NSObject+Notification.h"


@implementation BBHistoryViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"HISTORY", @"");
        
    [self setTabBarItemTitle:self.title
                  imageNamed:@"history_tab"
                         tag:eListenedMixesCategory];
    
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachDay;
    
    _mixesSelectionOptions.category = eListenedMixesCategory;
    _mixesSelectionOptions.sortKey = eMixPlaybackDateSortKey;
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBHistoryTableViewCell nibName];
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];

    cell.label.text = [NSString stringWithFormat:@"%@ [%@]", mix.name, [self detailTextForMix:mix]];
    
    cell.paused = mix == audioManager.mix ? audioManager.paused : YES;
    
    cell.delegate = self;
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

#warning TODO
//        NSInteger sectionID = [weakSelf sectionIDForMix:mix];
//        
//        [anOperation.tableModel addCellKey:mix.key toSectionID:sectionID];
////        anOperation.detailTextsDictionary[mix.key] = [weakSelf composeDetailTextForMix:mix];
//        
//        if (anOperation.headerTextsDictionary[@(sectionID)] == nil) {
//            anOperation.headerTextsDictionary[@(sectionID)] = [weakSelf composeHeaderTextForMix:mix];
//        }
    };
    
    return operation;
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
}

@end
