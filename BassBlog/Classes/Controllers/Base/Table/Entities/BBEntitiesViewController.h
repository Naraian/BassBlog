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
{
    NSMutableDictionary *_entitiesDictionary;    
}

@end

#pragma mark -

@interface BBEntitiesViewController (Abstract)

- (void)configureCell:(UITableViewCell *)cell withEntity:(id)entity;

- (void)applyModelLoadOperation:(id)operation;

- (void)mergeModelAndViewWithEntity:(id)entity;

- (void)mergeModelWithEntity:(id)entity;

- (id)modelReloadOperation;

- (id)modelUploadOperation;

@end

#pragma mark -

@interface BBEntitiesViewController (Protected)

#pragma mark View

- (void)updateCellForEntity:(id)entity; // "eBBTableViewRowAnimation"
- (void)updateCellForEntity:(id)entity
           withRowAnimation:(UITableViewRowAnimation)rowAnimation;

- (void)showDelayedBlockingActivityView;
- (void)hideActivityView;

#warning TODO: move to mixes controller...

- (void)showStubView;
- (void)hideStubView;
- (UIView *)stubView;

#pragma mark - Model

enum { eBBDefaultTableModelSectionID = 0 };

- (void)modelManagerDidFinishSaveNotification;

- (id)entityAtIndexPath:(NSIndexPath *)indexPath;
- (id)entityForCell:(UITableViewCell *)cell;

- (NSIndexPath *)indexPathOfEntity:(id)entity;

- (void)mergePendingEntities;

- (void)mergeWithEntity:(id)entity;

- (BOOL)hasEntity:(id)entity;

- (void)completeModelReload;

- (void)reloadModel;

@end