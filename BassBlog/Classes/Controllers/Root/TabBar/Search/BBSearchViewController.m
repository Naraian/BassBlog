//
//  BBSearchViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBSearchViewController.h"
#import "BBSearchViewController+Data.h"
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
#import "BBRefreshControl.h"

@interface BBSearchViewController() <UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) BBRefreshControl *refreshControl;

@end

@implementation BBSearchViewController

- (UISearchController *)searchController
{
    if (!_searchController)
    {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchBar.clipsToBounds = NO;
        
        [_searchController.searchBar setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHEX:0xD8D8D8FF] andSize:CGSizeMake(1.f, 1.f)]
                                         forBarPosition:UIBarPositionAny
                                             barMetrics:UIBarMetricsDefault];
    }
    
    return _searchController;
}

- (void)commonInit
{
    [super commonInit];
    
    NSString *title = NSLocalizedString(@"Search", nil).uppercaseString;
    self.title = title;
    [self setTabBarItemTitle:title imageNamed:@"mixes_tab" tag:eSearchMixesCategory];
        
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachMonth;
    
    self.detailTextsDictionary = [NSMutableDictionary new];
    self.headerTextsDictionary = [NSMutableDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.searchController.searchBar.showsCancelButton = NO;
    self.searchController.searchBar.translucent = NO;
    self.searchController.searchBar.backgroundImage = nil;
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Artist or mix name", nil).uppercaseString;
}

- (void)viewDidLayoutSubviews
{
    if (!self.refreshControl)
    {
        self.refreshControl = [[BBRefreshControl alloc] initWithScrollView:self.tableView];
        [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
        
        [self.view layoutSubviews];
    }
    
    [super viewDidLayoutSubviews];
}

- (void)showRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [self barButtonItemWithTitle:NSLocalizedString(@"History", nil).uppercaseString
                                                                 selector:@selector(historyBarButtonItemPressed)];
}

- (void)historyBarButtonItemPressed
{
    [self.searchController setActive:NO];
    
    [self performSegueWithIdentifier:@"historySegueID" sender:nil];
}

- (void)updateTheme
{
    [super updateTheme];
    
    [self showRightBarButtonItem];
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
        NSString *titleName = self.mixesSelectionOptions.tag.formattedName;
        
        if (!self.mixesSelectionOptions.tag || self.mixesSelectionOptions.tag.mainTag)
        {
            titleName = [BBTag allName];
        }
        
        self.title = titleName;
    }
    else
    {
        self.title = self.tabBarItem.title;
    }
}

- (void)refreshTable
{
    [[BBModelManager defaultManager] refresh];
}

- (void)modelManagerWillStartRefreshNotification
{
    [super modelManagerWillStartRefreshNotification];
    
    [self.refreshControl beginRefreshing];
}

- (void)modelManagerWillStartFullRefreshNotification
{
    [super modelManagerWillStartFullRefreshNotification];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchController setActive:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{    
    return [BBAllMixesTableViewCell nibName];
}

- (void)contentDidChange
{
    [super contentDidChange];
    
    [self updateNavigationBar];
}

#pragma mark - 
#pragma mark Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self filterContentForSearchText:searchController.searchBar.text];
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.refreshControl endRefreshing];
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    searchController.searchBar.showsCancelButton = NO;
}

- (void)willDismissSearchController:(UISearchController *)searchController;
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    if ([BBModelManager defaultManager].refreshStage != BBModelManagerWaitingStage)
    {
        if (self.tableView.contentOffset.y <= -self.tableView.contentInset.top)
        {
            [self.refreshControl beginRefreshing];
        }
    }        
}

#pragma mark -
#pragma mark Refresh control

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControl containingScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshControl containingScrollViewDidScroll:scrollView];
}

@end
