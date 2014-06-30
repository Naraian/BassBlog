//
//  BBHistoryViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHistoryViewController.h"

#import "BBHistoryTableViewCell.h"

#import "BBMix.h"
#import "BBModelManager.h"
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
    
    [self showLeftBarButtonItem];
}

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self barButtonItemWithTitle:@"CLEAR" selector:@selector(clearHistory)];
}

- (void)clearHistory
{
    if (self.fetchedResultsController.fetchedObjects.count > 0)
    {
        for (BBMix *mix in self.fetchedResultsController.fetchedObjects)
        {
            mix.playbackDate = nil;
        }
        
        [BBModelManager saveContext:self.fetchedResultsController.managedObjectContext withCompletionBlock:nil];
    }
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

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
}

@end
