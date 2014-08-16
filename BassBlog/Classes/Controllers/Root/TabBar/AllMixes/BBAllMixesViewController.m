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
#import "BBRefreshControl.h"

@interface BBAllMixesViewController()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) BBRefreshControl *refreshControl;

@end

@implementation BBAllMixesViewController

- (void)commonInit
{
    [super commonInit];
    
    NSString *title = NSLocalizedString(@"All Mixes", nil);
    self.title = title.uppercaseString;    
    [self setTabBarItemTitle:title imageNamed:@"mixes_tab" tag:eAllMixesCategory];
        
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachMonth;
    
    self.detailTextsDictionary = [NSMutableDictionary new];
    self.headerTextsDictionary = [NSMutableDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.searchBar.clipsToBounds = YES;
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

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self barButtonItemWithImageName:@"tags"
                                                                    selector:@selector(tagsBarButtonItemPressed)];
}

- (void)updateTheme
{
    [super updateTheme];
    
    [self showLeftBarButtonItem];
    
    [self.searchBar setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHEX:0xD8D8D8FF] andSize:CGSizeMake(1.f, 1.f)]
                        forBarPosition:UIBarPositionAny
                            barMetrics:UIBarMetricsDefault];
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
