//
//  BBFavoritesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBFavoritesViewController.h"

#import "BBFavoritesTableViewCell.h"

#import "BBMixesViewControllerModelLoadOperation.h"
#import "BBTableModel.h"
#import "BBMix.h"

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
        
    _mixesSelectionOptions.category = eFavoriteMixesCategory;
}

- (UIBarButtonItem *)editButtonItem
{
    UIBarButtonItem *editButtonItem = [super editButtonItem];
    
    NSDictionary *attributes = @{UITextAttributeTextColor:[UIColor whiteColor],
                                 UITextAttributeFont:[BBFont fontOfSize:18]};

    [editButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    return editButtonItem;
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

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBFavoritesTableViewCell nibName];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BBMix *mix = [self entityAtIndexPath:indexPath];
        mix.favorite = NO;
    }
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
}

@end
