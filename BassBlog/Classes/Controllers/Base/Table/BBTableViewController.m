//
//  BBTableViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTableViewController.h"

#import "BBThemeManager.h"

#import "BBAppDelegate.h"

#import "BBTableModel.h"

#import "NSObject+Nib.h"


@implementation BBTableViewController

#pragma mark - View

- (void)viewDidLoad {
    
    NSString *cellNibName = [self cellNibNameAtIndexPath:nil];
    UITableViewCell *cell = [NSClassFromString(cellNibName) instanceFromNib:nil];
    
    if (cell) {
    
        self.tableView.rowHeight = CGRectGetHeight(cell.bounds);
    }
    
    [super viewDidLoad];
}

- (void)updateTheme
{
    [super updateTheme];
    
    UIColor *color = nil;
    switch ([BBThemeManager defaultManager].theme)
    {
        default:
            color = [UIColor blackColor];
            break;
    }
    
    self.tableView.separatorColor = color;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_tableModel numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableModel numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellNibName = [self cellNibNameAtIndexPath:indexPath];
    NSString *suffix = [BBThemeManager defaultManager].themeName;
    NSString *cellNibThemeName = [cellNibName stringByAppendingString:suffix];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellNibThemeName];

#warning TODO remove this fallback, all cells must be created from storyboard prototypes
    if (cell == nil) {
        
        UINib *nib = [UINib nibWithNibName:cellNibName bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellNibThemeName];
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellNibThemeName];
    }
    
    return cell;
}

@end
