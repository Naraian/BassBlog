//
//  BBEntitiesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewController.h"

#import "BBActivityView.h"

#import "BBEntity.h"

#import "BBModelManager.h"
#import "BBOperationManager.h"

#import "NSObject+Notification.h"
#import "NSObject+Thread.h"


static const NSTimeInterval BBActivityViewShowDelay = 0.2;
static const NSTimeInterval BBActivityViewShowAnimationDuration = 0.1;


@interface BBEntitiesViewController ()

@property (nonatomic) BBActivityView *activityView;

@property (nonatomic) BOOL reloadModelOnSaveFinish;
@property (nonatomic) BOOL reloadDataOnViewWillAppear;
@property (nonatomic) BOOL viewDidAppear;

@property (nonatomic) dispatch_once_t loadToken;

@end

#pragma mark -

@implementation BBEntitiesViewController

#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reloadDataOnViewWillAppear = YES;
 
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.reloadDataOnViewWillAppear)
    {
        self.reloadDataOnViewWillAppear = NO;
    }
    
    self.viewDidAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    self.viewDidAppear = NO;
    
    [super viewDidDisappear:animated];
}

- (BBActivityView *)activityView {
    
    if (_activityView == nil) {
        _activityView = [BBActivityView new];
    }
    
    return _activityView;
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
    
    [self addSelector:@selector(modelManagerDidInitializeNotification)
    forNotificationWithName:BBModelManagerDidInitializeNotification];
    
    [self addSelector:@selector(modelManagerDidFinishRefreshNotification)
    forNotificationWithName:BBModelManagerDidFinishRefreshNotification];

    [self addSelector:@selector(modelManagerDidFinishSaveNotification)
    forNotificationWithName:BBModelManagerDidFinishSaveNotification];
}

- (void)modelManagerDidInitializeNotification {
    

}

- (void)modelManagerDidFinishRefreshNotification {
    

}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell withEntity:[self entityAtIndexPath:indexPath]];
    
    return cell;
}

@end

#pragma mark -

@implementation BBEntitiesViewController (Protected)

#pragma mark View

- (void)showDelayedBlockingActivityView {
    
    NSLog(@"self showDelayedBlockingActivityView: %@", self);
    
    if (self.activityView.superview) {
        return;
    }
    
    self.activityView.frame = self.view.bounds;
    self.activityView.alpha = 0.f;
    
    [self.view addSubview:self.activityView];
    
    [self performSelector:@selector(showActivityView)
               withObject:nil
               afterDelay:BBActivityViewShowDelay];
}

- (void)showActivityView {
    
    NSLog(@"self showActivityView: %@", self);
    [UIView animateWithDuration:BBActivityViewShowAnimationDuration
                     animations:^{ self.activityView.alpha = 1.f; }];
}

- (void)hideActivityView {
    
    NSLog(@"self hideActivityView: %@", self);
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showActivityView)
                                               object:nil];
    [_activityView removeFromSuperview];
}

- (void)showStubView {
    
#warning TODO: implement...
}

- (void)hideStubView {
    
#warning TODO: implement...
}

- (UIView *)stubView {
    
    return nil;
}

#pragma mark - Model

- (void)modelManagerDidFinishSaveNotification
{
    if (self.reloadModelOnSaveFinish)
    {

    }
}

- (id)entityAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return object;
}

- (id)entityForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    return [self entityAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathOfEntity:(BBEntity *)entity
{
    return [self.fetchedResultsController indexPathForObject:entity];
}

- (BOOL)hasEntity:(BBEntity *)entity
{
    return ([self.fetchedResultsController indexPathForObject:entity] != nil);
}

- (void)contentWillChange
{
    [self showDelayedBlockingActivityView];
}

- (void)contentDidChange
{
    if ([self.tableView numberOfSections])
    {
        [self hideStubView];
    }
    else
    {
        [self showStubView];
    }
    
    [self hideActivityView];
}

- (void)performFetch
{
    NSError *error = nil;
    
    if ([self.fetchedResultsController performFetch:&error])
    {
        
    }
    else
    {
        BB_ERR(@"Couldn't complete model reload operation!, %@", error);
    }
}

- (void)reloadModel
{
    self.fetchedResultsController = nil;
    
    [self performFetch];
    
    [self.tableView reloadData];
    
    self.reloadModelOnSaveFinish = NO;
    
    if ([[BBModelManager defaultManager] isSaveInProgress])
    {
        self.reloadModelOnSaveFinish = YES;
        return;
    }
}

@end