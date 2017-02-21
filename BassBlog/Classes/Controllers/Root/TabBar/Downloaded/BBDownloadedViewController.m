//
//  BBDownloadedViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBDownloadedViewController.h"
#import "BBDownloadedTableViewCell.h"

#import "BBMix.h"
#import "BBModelManager.h"
#import "BBAudioManager.h"

#import "NSObject+Notification.h"

@implementation BBDownloadedViewController

- (void)commonInit
{
    [super commonInit];
    
    NSString *title = NSLocalizedString(@"Downloaded", nil);
    self.title = title.uppercaseString;
    [self setTabBarItemTitle:title imageNamed:@"downloads_icon" tag:eDownloadedMixesCategory];

    _mixesSelectionOptions.category = eDownloadedMixesCategory;
    
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachDay;
    
    _mixesSelectionOptions.category = eListenedMixesCategory;
    _mixesSelectionOptions.sortKey = eMixPlaybackDateSortKey;
    
    [self showLeftBarButtonItem];
}

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{
    return [BBDownloadedTableViewCell nibName];
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix
{
    [super configureCell:cell withEntity:mix];
    
    cell.label.text = [NSString stringWithFormat:@"%@ [%@]", mix.name, [self detailTextForMix:mix]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPat
{
    [self setEditing:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL resetEditing = (self.fetchedResultsController.fetchedObjects.count == 1);
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell.showingDeleteConfirmation)
        {
            //If deleting single cell, reset editing state
            resetEditing = YES;
        }
        
        BBMix *mix = [self entityAtIndexPath:indexPath inTableView:tableView];
        mix.favoriteDate = nil;
        
        [self updateEmptyStateVisibility];
        
        if (resetEditing)
        {
            [self setEditing:NO animated:YES];
        }
    }
}

- (NSString *)titleForEmptyState
{
    return NSLocalizedString(@"History is empty", nil);
}

- (NSString *)imageNameForEmptyState
{
    return @"no_history";
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
}

@end
