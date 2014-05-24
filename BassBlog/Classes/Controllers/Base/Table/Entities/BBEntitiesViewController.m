//
//  BBEntitiesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewController.h"

#import "BBActivityView.h"

#import "BBTableModel.h"
#import "BBEntity.h"

#import "BBModelManager.h"
#import "BBOperationManager.h"
#import "BBEntitiesViewControllerModelLoadOperation.h"

#import "NSObject+Notification.h"
#import "NSObject+Thread.h"


static const NSTimeInterval BBActivityViewShowDelay = 0.2;
static const NSTimeInterval BBActivityViewShowAnimationDuration = 0.1;


@interface BBEntitiesViewController ()
{
    BBEntitiesViewControllerModelLoadOperation *_reloadOperation;
}

@property (nonatomic) BBActivityView *activityView;

@property (nonatomic) BOOL reloadModelOnSaveFinish;
@property (nonatomic) BOOL reloadDataOnViewWillAppear;
@property (nonatomic) BOOL viewDidAppear;

@end

#pragma mark -

@implementation BBEntitiesViewController

#pragma mark View

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[BBModelManager defaultManager] isInitialized]) {
        
        [self reloadModel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.reloadDataOnViewWillAppear) {
        self.reloadDataOnViewWillAppear = NO;
        
        [self.tableView reloadData];
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
    
    [self reloadModel];
}

- (void)modelManagerDidFinishRefreshNotification {
    
    [self reloadModel];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    
    [self configureCell:cell withEntity:[self entityAtIndexPath:indexPath]];
    
    return cell;
}

@end

#pragma mark -

@implementation BBEntitiesViewController (Protected)

#pragma mark View

- (void)showDelayedBlockingActivityView {
    
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
    
    [UIView animateWithDuration:BBActivityViewShowAnimationDuration
                     animations:^{ self.activityView.alpha = 1.f; }];
}

- (void)hideActivityView {
    
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
        [self reloadModel];
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
#warning TODO
    return nil;//[_tableModel indexPathOfCellKey:entity.key];
}

- (void)mergePendingEntities
{
}

- (void)mergeWithEntity:(BBEntity *)entity
{
    if (self.reloadModelOnSaveFinish)
    {
        return;
    }
    
    if (self.viewDidAppear)
    {
    }
    else
    {
        self.reloadDataOnViewWillAppear = YES;
    }
}

- (BOOL)hasEntity:(BBEntity *)entity
{
#warning TODO
    return YES;
//    return [_entitiesDictionary objectForKey:entity.key] != nil;
}

- (void)reloadModel {
    
    [_reloadOperation cancel];
    _reloadOperation = nil;
    
    [self showDelayedBlockingActivityView];
    
    self.reloadModelOnSaveFinish = NO;
    
    if ([[BBModelManager defaultManager] isSaveInProgress]) {
        
        self.reloadModelOnSaveFinish = YES;
        return;
    }
    
    _reloadOperation = [BBEntitiesViewControllerModelLoadOperation new];
    
    __weak BBEntitiesViewController *weakSelf = self;
    __weak BBEntitiesViewControllerModelLoadOperation *reloadOperation = _reloadOperation;
    
    reloadOperation.finish = ^(BBEntitiesViewControllerModelLoadOperation *operation)
    {    
        if ([operation isCompleted])
        {
            NSError *error = nil;
            
            if (![self.fetchedResultsController performFetch:&error])
            {
                
            }
            
            return;
        }
        
        ERR(@"Couldn't complete model reload operation!");
    };
    
    [reloadOperation setCompletionBlock:^{
        
        if ([reloadOperation isCancelled]) {
            return;
        }
        
        [self.class mainThreadAsyncBlock:^{
            [weakSelf completeModelReload];
        }];
    }];
    
    [[BBOperationManager defaultManager] addOperation:_reloadOperation];
}

- (void)completeModelReload {
    
    [self.tableView reloadData];
    
    if ([self.tableView numberOfSections]) {
        
        [self hideStubView];
    }
    else {
        
        [self showStubView];
    }
    
    [self hideActivityView];
}

@end