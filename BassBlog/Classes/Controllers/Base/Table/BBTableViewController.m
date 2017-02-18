//
//  BBTableViewController.mself.text = self.recurrence.title()
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTableViewController.h"

#import "BBThemeManager.h"

#import "BBAppDelegate.h"

#import "BBModelManager.h"

#import "NSObject+Nib.h"


@implementation BBTableViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.viewVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.viewVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.viewVisible = NO;
}

- (void)updateTheme
{
    [super updateTheme];
    
    if (self.isViewVisible)
    {
        [self.tableView reloadData];
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return (tableView == self.tableView) ? _fetchedResultsController : _searchFetchedResultsController;
}

- (UITableView *)tableViewForFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    return (fetchedResultsController == _fetchedResultsController) ? self.tableView : self.searchDisplayController.searchResultsTableView;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [self fetchRequestForSearch:NO];
        
        NSString *sectionNameKeyPath = [self sectionNameKeyPath];        
        NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                      managedObjectContext:[[BBModelManager defaultManager] rootContext]
                                                                                                        sectionNameKeyPath:sectionNameKeyPath
                                                                                                                 cacheName:nil]; //NSStringFromClass(self.class)];
        #warning deal with cache name

        _fetchedResultsController = theFetchedResultsController;
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (!_searchFetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [self fetchRequestForSearch:YES];
        
        NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                      managedObjectContext:[[BBModelManager defaultManager] rootContext]
                                                                                                        sectionNameKeyPath:nil
                                                                                                                 cacheName:nil]; //NSStringFromClass(self.class)];
        _searchFetchedResultsController = theFetchedResultsController;
        _searchFetchedResultsController.delegate = self;
    }
    
    return _searchFetchedResultsController;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    _searchFetchedResultsController.delegate = nil;
    _searchFetchedResultsController = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellNibName = [self cellNibNameAtIndexPath:indexPath];
    NSString *suffix = [BBThemeManager defaultManager].themeName;
    NSString *cellNibThemeName = [cellNibName stringByAppendingString:suffix];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellNibThemeName];
    
    if (cell == nil)
    {
        BB_WRN(@"Cell with ID (%@) not found in (%@)", cellNibThemeName, NSStringFromClass(self.class));
    }
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self contentWillChange];
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [[self tableViewForFetchedResultsController:controller] beginUpdates];
}

- (void)contentWillChange
{
    
}

- (void)contentDidChange
{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    UITableViewRowAnimation rowAnimation = self.isViewVisible ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = [self tableViewForFetchedResultsController:controller];
    UITableViewRowAnimation rowAnimation = self.isViewVisible ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
            break;
            
        case NSFetchedResultsChangeMove:
            break;

    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    @try
    {
        // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
        [[self tableViewForFetchedResultsController:controller] endUpdates];
    }
    @catch (NSException *exception)
    {
        
    }

    [self contentDidChange];
}

#pragma mark -
#pragma mark Search Bar

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.tableFooterView = [UIView new];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
