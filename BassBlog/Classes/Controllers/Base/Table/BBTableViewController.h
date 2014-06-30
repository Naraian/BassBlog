//
//  BBTableViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBViewController.h"

#import <CoreData/CoreData.h>


// Base abstract class for table view controller.

enum { eBBTableViewRowAnimation = UITableViewRowAnimationFade };

@interface BBTableViewController : BBViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchControllerDelegate>

@property (nonatomic, assign, getter=isViewVisible) BOOL viewVisible;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

@end

#pragma mark -

@interface BBTableViewController (Abstract)

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath;

- (NSFetchRequest *)fetchRequestForSearch:(BOOL)search;

- (void)filterContentForSearchText:(NSString*)searchText;

- (NSString *)sectionNameKeyPath;

- (void)contentWillChange;
- (void)contentDidChange;

@end
