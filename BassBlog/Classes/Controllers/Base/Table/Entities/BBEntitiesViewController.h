//
//  BBEntitiesViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 08.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTableViewController.h"


// Base abstract class for model entities list visualization.

// NOTE: all subclasses use next model scheme:
// - all entities are stored in entitiesDictionary;
// - entities ID are cell IDs in tableModel.

@interface BBEntitiesViewController : BBTableViewController
- (void)modelManagerDidFinishRefreshNotification;
- (void)modelManagerRefreshErrorNotification;

#warning TODO: move to mixes controller...

- (void)performFetch;

#pragma mark - Model

enum { eBBDefaultTableModelSectionID = 0 };

- (void)modelManagerDidFinishSaveNotification;

- (id)entityAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (id)entityForCell:(UITableViewCell *)cell inTableView:(UITableView *)tableView;

- (NSIndexPath *)indexPathOfEntity:(id)entity inTableView:(UITableView *)tableView;

- (BOOL)hasEntity:(id)entity inTableView:(UITableView *)tableView;
- (void)reloadModel;

@end

#pragma mark -

@interface BBEntitiesViewController (Abstract)

- (void)configureCell:(UITableViewCell *)cell withEntity:(id)entity;

- (void)updateCellForEntity:(id)entity; // "eBBTableViewRowAnimation"
- (void)updateCellForEntity:(id)entity
           withRowAnimation:(UITableViewRowAnimation)rowAnimation;

@end
