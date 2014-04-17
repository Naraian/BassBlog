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


@implementation BBFavoritesViewController

- (id)init {
    
    self = [super init];
    
    if (self)
    {
        [self setTabBarItemTitle:NSLocalizedString(@"FAVORITES", @"")
                      imageNamed:@"favorites_icon"
                             tag:eFavoriteMixesCategory];
        
        _mixesSelectionOptions.category = eFavoriteMixesCategory;
    }
    
    return self;
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath {
    
    return [BBFavoritesTableViewCell nibName];
}

#pragma mark - Model

- (BBMixesViewControllerModelLoadOperation *)modelLoadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [super modelLoadOperation];
    
    operation.handleEntity = ^(BBMixesViewControllerModelLoadOperation *operation, BBMix *mix) {
        
        [operation.tableModel addCellKey:mix.key toSectionID:eBBDefaultTableModelSectionID];
    };
    
    return operation;
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
    
    [self addSelector:@selector(mixDidChangeFavoriteNotification:)
    forNotificationWithName:BBMixDidChangeFavoriteNotification];
}

- (void)mixDidChangeFavoriteNotification:(NSNotification *)notification {
    
    [self mergeWithEntity:notification.object];
}

@end
