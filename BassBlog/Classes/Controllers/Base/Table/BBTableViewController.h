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

@interface BBTableViewController : BBViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, assign, getter=isViewVisible) BOOL viewVisible;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

#pragma mark -

@interface BBTableViewController (Abstract)

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath;

- (NSFetchRequest *)fetchRequest;

- (NSString *)sectionNameKeyPath;

@end
