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
#import "BBModelManager.h"
#import "BBRootViewController.h"

@interface BBAllMixesViewController()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation BBAllMixesViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"ALL MIXES", @"");
    
    [self setTabBarItemTitle:self.title
                  imageNamed:@"mixes_tab"
                         tag:eAllMixesCategory];
        
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachMonth;
    
    self.detailTextsDictionary = [NSMutableDictionary new];
    self.headerTextsDictionary = [NSMutableDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PULL TO REFRESH", nil)];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    // Create a UITableViewController so we can use a UIRefreshControl.
    UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:self.tableView.style];
    tvc.tableView = self.tableView;
    tvc.refreshControl = self.refreshControl;
    [self addChildViewController:tvc];
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
    
    self.searchBar.backgroundImage = [UIImage new];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.searchDisplayController.isActive)
    {
        return UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleLightContent;
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

- (void)refreshTable
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"LOADING"];

    [[BBModelManager defaultManager] refresh];
}

- (void)modelManagerDidFinishRefreshNotification
{
    [super modelManagerDidFinishRefreshNotification];
    
    [self.refreshControl endRefreshing];
}

- (void)modelManagerRefreshErrorNotification
{
    [super modelManagerRefreshErrorNotification];
    
    [self.refreshControl endRefreshing];
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

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
