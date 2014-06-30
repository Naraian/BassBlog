//
//  BBAllMixesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAllMixesViewController.h"
#import "BBTagsViewController.h"

#import "BBMixesTableSectionHeaderView.h"
#import "BBAllMixesTableViewCell.h"

#import "BBMix.h"
#import "BBTag.h"

#import "NSObject+Nib.h"
#import "BBUIUtils.h"
#import "BBAppDelegate.h"
#import "BBRootViewController.h"


@implementation BBAllMixesViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"ALL MIXES", @"");
    
    [self setTabBarItemTitle:self.title
                  imageNamed:@"mixes_tab"
                         tag:eAllMixesCategory];
        
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachDay;
    
    self.detailTextsDictionary = [NSMutableDictionary new];
    self.headerTextsDictionary = [NSMutableDictionary new];
}

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self barButtonItemWithImageName:@"tags"
                                                                    selector:@selector(tagsBarButtonItemPressed)];
}

- (void)updateTheme
{
    [super updateTheme];
    
    [self showLeftBarButtonItem];
}

- (void)updateNavigationBar
{
    BOOL hasMixes = (self.fetchedResultsController.fetchedObjects.count > 0);
    
    self.navigationItem.leftBarButtonItem.enabled = YES; //hasMixes;
    
    if (hasMixes)
    {
        self.title = self.mixesSelectionOptions.tag ? self.mixesSelectionOptions.tag.formattedName : [[BBTag allName] uppercaseString];
    }
    else
    {
        self.title = self.tabBarItem.title;
    }
}

#pragma mark - View

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateNavigationBar];
    
    [[BBAppDelegate rootViewController] tagsViewController].delegate = self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{    
    return [BBAllMixesTableViewCell nibName];
}

- (NSString *)composeDetailTextForMix:(BBMix *)mix
{
    return [BBUIUtils tagsStringForMix:mix];
}

- (void)contentDidChange
{
    [super contentDidChange];
    
    [self updateNavigationBar];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.mixesSelectionOptions.substringInName = searchText;
    
    [super filterContentForSearchText:searchText];
}

@end
