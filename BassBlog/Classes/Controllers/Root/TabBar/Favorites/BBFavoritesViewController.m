//
//  BBFavoritesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBFavoritesViewController.h"

#import "BBFavoritesTableViewCell.h"

#import "BBMix.h"
#import "BBModelManager.h"

#import "NSObject+Notification.h"
#import "BBFont.h"


@implementation BBFavoritesViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"FAVORITES", @"");
        
    [self setTabBarItemTitle:self.title
                  imageNamed:@"favorites_tab"
                         tag:eFavoriteMixesCategory];
    
    [self showLeftBarButtonItem];
    
    _mixesSelectionOptions.category = eFavoriteMixesCategory;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setEditing:NO animated:NO];
}

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - View

- (NSString *)sectionTitleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{
    return [BBFavoritesTableViewCell nibName];
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
        
        BBMix *mix = [self entityAtIndexPath:indexPath inTableView:tableView];
        mix.favorite = NO;
        
        [BBModelManager saveContext:mix.managedObjectContext withCompletionBlock:nil];
        
        if (resetEditing)
        {
            [self setEditing:NO animated:NO];
        }
    }
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
}

@end
