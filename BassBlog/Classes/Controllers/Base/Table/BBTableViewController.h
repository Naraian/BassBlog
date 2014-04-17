//
//  BBTableViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBViewController.h"


// Base abstract class for table view controller.

enum { eBBTableViewRowAnimation = UITableViewRowAnimationFade };

@class BBTableModel;

@interface BBTableViewController : BBViewController
<
UITableViewDelegate,
UITableViewDataSource
>
{
    BBTableModel *_tableModel;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

#pragma mark -

@interface BBTableViewController (Abstract)

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath;

@end
