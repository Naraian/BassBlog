//
//  BBMixesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesViewController.h"

#import "BBTagsViewController.h"
#import "BBRootViewController.h"
#import "BBAppDelegate.h"

#import "BBMixesTableViewCell.h"
#import "BBMixesTableFooterView.h"
#import "BBMixesTableSectionHeaderView.h"

#import "BBMixesSelectionOptions.h"
#import "BBEntitiesViewControllerModelLoadOperation.h"

#import "BBOperationManager.h"
#import "BBAudioManager.h"
#import "BBThemeManager.h"
#import "BBModelManager.h"

#import "BBTableModel.h"

#import "BBMix.h"
#import "BBTag.h"

#import "NSObject+Nib.h"
#import "NSObject+Thread.h"
#import "NSObject+Notification.h"

#import "BBUIUtils.h"


static const NSUInteger kBBMixesStartFetchRequestLimit = 30;

@interface BBMixesViewController ()
<
BBAudioManagerDelegate
>
{    
    NSMutableArray *_mixesArray;
    
    UINib *_sectionHeaderNib;
}

@property (nonatomic) NSDateFormatter *detailTextDateFormatter;
@property (nonatomic) NSDateFormatter *headerDateFormatter;

@property (nonatomic) BBMixesTableFooterView *tableFooterView;

@end

@implementation BBMixesViewController

- (void)commonInit
{    
    [super commonInit];
    
    _mixesSelectionOptions = [BBMixesSelectionOptions new];
    _mixesSelectionOptions.category = eAllMixesCategory;
    _mixesSelectionOptions.sortKey = eMixDateSortKey;
    _mixesSelectionOptions.limit = kBBMixesStartFetchRequestLimit;
    _mixesSelectionOptions.tag = [BBModelManager allTag];
    
    _detailTextsDictionary = [NSMutableDictionary new];
    _headerTextsDictionary = [NSMutableDictionary new];
}

#pragma mark - View

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self updateNavigationBar];
    
    [[BBAppDelegate rootViewController] tagsViewController].delegate = self;
}

- (void)updateTheme {
    
    [super updateTheme];
    
    [self showLeftBarButtonItem];
    
    [self showNowPlayingBarButtonItem];
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    cell.label.text = mix.name;
    cell.detailLabel.text = [self detailTextForMix:mix];
    [cell.button setImage:[BBUIUtils defaultImage] forState:UIControlStateNormal];
    
    cell.paused = mix == audioManager.mix ? audioManager.paused : YES;
    
    cell.delegate = self;
}

- (void)updateNowPlayingCellAndSelectRow:(BOOL)selectRow {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    BBMix *mix = audioManager.mix;
    
    if ([self hasEntity:mix] == NO) {
        return;
    }

    NSIndexPath *indexPath = [self indexPathOfEntity:mix];
    BBMixesTableViewCell *cell =
    (BBMixesTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (cell == nil) {
        return;
    }
    
    cell.paused = audioManager.paused;
    
    if (selectRow) {
        
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        
        [self.tableView deselectRowAtIndexPath:indexPath
                                      animated:YES];
    }
}

- (BBMixesTableSectionHeaderView *)sectionHeaderView {
    
    if (_sectionHeaderNib == nil) {
        _sectionHeaderNib = [BBMixesTableSectionHeaderView nib];
    }

    return [BBMixesTableSectionHeaderView instanceFromNib:_sectionHeaderNib];
}

- (void)showTableFooterView {
    
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)hideTableFooterView {
    
    self.tableView.tableFooterView = nil;
}

- (BBMixesTableFooterView *)tableFooterView {
    
    if (_tableFooterView == nil) {
        _tableFooterView = [BBMixesTableFooterView instanceFromNib:nil];
    }
    
    return _tableFooterView;
}

- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem =
    [self barButtonItemWithImageName:@"tags"
                            selector:@selector(tagsBarButtonItemPressed)];
    
    //self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)showNowPlayingBarButtonItem
{
    self.navigationItem.rightBarButtonItem =
    [self barButtonItemWithImageName:@"now_playing"
                            selector:@selector(nowPlayingBarButtonItemPressed)];
}

- (void)updateNavigationBar
{
    BOOL hasMixes = (self.fetchedResultsController.fetchedObjects.count > 0);
    
    self.navigationItem.leftBarButtonItem.enabled = hasMixes;
    
    if (hasMixes)
    {
        self.title = [_mixesSelectionOptions.tag.name uppercaseString];
    }
    else
    {
        self.title = self.tabBarItem.title;
    }
}

- (void)setTitle:(NSString *)title {
    
    NSString *tabBarItemTitle = self.tabBarItem.title;
    
    [super setTitle:title];
    
    self.tabBarItem.title = tabBarItemTitle;
}

#pragma mark - Model

- (void)modelManagerDidFinishSaveNotification {
    
    [super modelManagerDidFinishSaveNotification];
}

- (id)modelReloadOperation
{    
    BBEntitiesViewControllerModelLoadOperation *operation = [self modelLoadOperation];
    
    return operation;
}

- (void)completeModelReload
{
    [super completeModelReload];
    
    [self updateNavigationBar];
}

- (void)pause:(BOOL)pause mix:(BBMix *)mix
{
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    [audioManager setMix:mix paused:pause];
    audioManager.delegate = self;
}

- (BBMix *)mixWithCurrentIndexOffset:(NSInteger)indexOffset
{
    BBMix *currentMix = [BBAudioManager defaultManager].mix;
    
    NSInteger currentMixIndex = [_mixesArray indexOfObject:currentMix];
    
    if (currentMixIndex == NSNotFound) {
        
        // Suppose user did change tag, when audio manager still playing mix from previous mixes fetch.
        
        currentMixIndex = 0;
    }
    
    NSInteger mixIndex = currentMixIndex + indexOffset;
    if (mixIndex < 0) {
        mixIndex = 0;
    }
    else if (mixIndex >= _mixesArray.count) {
        mixIndex = _mixesArray.count;
    }
    
    return [_mixesArray objectAtIndex:mixIndex];
}

- (NSDateFormatter *)detailTextDateFormatter {
    
    if (_detailTextDateFormatter == nil) {
        
        _detailTextDateFormatter = [NSDateFormatter new];
        [_detailTextDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_detailTextDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return _detailTextDateFormatter;
}

- (NSDateFormatter *)headerDateFormatter {
    
    if (_headerDateFormatter == nil) {
        
        _headerDateFormatter = [NSDateFormatter new];
        [_headerDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [_headerDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return _headerDateFormatter;
}

- (NSInteger)sectionIDFromDate:(NSDate *)date components:(NSUInteger)components {
    
    NSAssert(date, @"%s date == nil", __FUNCTION__);
    
    NSInteger sectionID = 0;
    
    NSDateComponents *dateComponents =
    [[NSCalendar currentCalendar] components:components fromDate:date];
    
    if (components & NSDayCalendarUnit) {
        sectionID |= dateComponents.day;
    }
    
    if (components & NSMonthCalendarUnit) {
        sectionID |= dateComponents.month << 5; // 31 (11111)
    }
    
    if (components & NSYearCalendarUnit) {
        sectionID |= dateComponents.year << 9; // 12 (1100)
    }
    
    return sectionID;
}

- (NSString *)sectionNameKeyPath
{
    if (self.mixesSelectionOptions.sortKey == eMixPlaybackDateSortKey)
    {
        return (_tableModelSectionRule == BBMixesTableModelSectionRuleEachDay) ? BBMixPlaybackDaySectionIdentifierKey : BBMixPlaybackMonthSectionIdentifierKey;
    }
    
    return (_tableModelSectionRule == BBMixesTableModelSectionRuleEachDay) ? BBMixDaySectionIdentifierKey : BBMixMonthSectionIdentifierKey;
}

- (NSInteger)sectionIDForMix:(BBMix *)mix
{
    NSString *keyPath = [self sectionNameKeyPath];
    NSNumber *sectionID = [mix valueForKey:keyPath];
    
    return [sectionID integerValue];
}

#pragma mark - Actions

- (void)tagsBarButtonItemPressed
{
    [[BBAppDelegate rootViewController] toggleTagsVisibility];
}

- (void)nowPlayingBarButtonItemPressed {
    
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibilityFromNavigationController:self.navigationController];
}

#pragma mark - Notifications

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
    
    [self addSelector:@selector(audioManagerDidStartPlayNotification)
    forNotificationWithName:BBAudioManagerDidStartPlayNotification];
    
    [self addSelector:@selector(audioManagerDidStopNotification:)
    forNotificationWithName:BBAudioManagerDidStopNotification];
}

- (void)audioManagerDidStartPlayNotification {
    
    [self updateNowPlayingCellAndSelectRow:YES];
}

- (void)audioManagerDidStopNotification:(NSNotification *)notification{
    
    BBAudioManagerStopReason reason = [notification.userInfo[BBAudioManagerStopReasonKey] integerValue];
    
    [self updateNowPlayingCellAndSelectRow:reason != BBAudioManagerWillChangeMix];
}

#pragma mark - BBMixesTableViewCellDelegate

- (void)mixesTableViewCell:(BBMixesTableViewCell *)cell paused:(BOOL)paused
{
    BBMix *mix = [self entityForCell:cell];
    
    [self pause:paused mix:mix];
}

#pragma mark - BBTagsViewControllerDelegate

- (void)tagsViewControllerDidChangeTag:(BBTag *)tag
{
    _mixesSelectionOptions.tag = tag;
    
    [self reloadModel];
}

- (BBMixesSelectionOptions *)mixesSelectionOptions
{
    return _mixesSelectionOptions;
}

#pragma mark - BBAudioManagerDelegate

- (BBMix *)nextMix
{
    return [self mixWithCurrentIndexOffset:1];
}

- (BBMix *)prevMix
{
    return [self mixWithCurrentIndexOffset:-1];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBMix *mix = [self entityAtIndexPath:indexPath];
  
    [self pause:NO mix:mix];
    
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibilityFromNavigationController:self.navigationController];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    if (_headerTextsDictionary.count == 0)
    {
        return nil;
    }
    
    BBMixesTableSectionHeaderView *headerView = [self sectionHeaderView];

    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSString *sectionIDString = [sectionInfo name];
    NSNumber *sectionID = @([sectionIDString integerValue]);
    
    headerView.label.text = _headerTextsDictionary[sectionID];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_headerTextsDictionary.count == 0)
    {
        return 0.f;
    }
    
    return [BBMixesTableSectionHeaderView height];
}

#pragma mark - UIScrollView

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
#warning there was upload
    if (self.tableView.tableFooterView)
    {
        return;
    }
    
    if ((*targetContentOffset).y < self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds))
    {
        return;
    }
}

@end

#pragma mark -

@implementation BBMixesViewController (Protected)

- (NSFetchRequest *)fetchRequest
{
    return [[BBModelManager defaultManager] fetchRequestForMixesWithSelectionOptions:_mixesSelectionOptions];
}

- (BBEntitiesViewControllerModelLoadOperation *)modelLoadOperation
{
    BBEntitiesViewControllerModelLoadOperation *operation = [BBEntitiesViewControllerModelLoadOperation new];
    
    return operation;
}

- (NSString *)detailTextForMix:(BBMix *)mix {
    return _detailTextsDictionary[mix.key];
}

- (NSString *)composeDetailTextForMix:(BBMix *)mix {
    
    return [self.detailTextDateFormatter stringFromDate:[self dateOfMix:mix]];
}

- (NSString *)composeHeaderTextForMix:(BBMix *)mix {
    
    return [self.headerDateFormatter stringFromDate:[self dateOfMix:mix]];
}

- (NSDate *)dateOfMix:(BBMix *)mix {
    
    if (self.mixesSelectionOptions.sortKey == eMixPlaybackDateSortKey) {
        return mix.playbackDate;
    }
    
    return mix.date;
}

@end
