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

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{
    return [BBHistoryTableViewCell nibName];
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix
{
    BBAudioManager *audioManager = [BBAudioManager defaultManager];

    cell.label.text = [NSString stringWithFormat:@"%@ [%@]", mix.name, [self detailTextForMix:mix]];
    
    cell.paused = mix == audioManager.mix ? audioManager.paused : YES;
    
    cell.delegate = self;
}

#pragma mark - Model

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(BBMix *)mix atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [super controller:controller didChangeObject:mix atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
    NSInteger sectionID = [self sectionIDForMix:mix];
    
    self.detailTextsDictionary[mix.key] = [self composeDetailTextForMix:mix];
    
    if (self.headerTextsDictionary[@(sectionID)] == nil)
    {
        self.headerTextsDictionary[@(sectionID)] = [self composeHeaderTextForMix:mix];
    }
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
}

@end
