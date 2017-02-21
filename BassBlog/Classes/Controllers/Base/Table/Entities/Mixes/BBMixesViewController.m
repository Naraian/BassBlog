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
#import "BBFont.h"

#import "BBOperationManager.h"
#import "BBAudioManager.h"
#import "BBThemeManager.h"
#import "BBModelManager.h"

#import "BBMix.h"
#import "BBTag.h"

#import "NSObject+Nib.h"
#import "NSObject+Thread.h"
#import "NSObject+Notification.h"

#import "BBUIUtils.h"
#import "BBMacros.h"

#import <UIImageView+AFNetworking.h>

DEFINE_STATIC_CONST_NSSTRING(kBBBBMixesViewControllerHeaderID);

static const NSUInteger kBBMixesStartFetchRequestLimit = 30;

@interface BBMixesViewController () <BBAudioManagerDelegate>

@property (nonatomic) NSDateFormatter *detailTextDateFormatter;
@property (nonatomic) NSDateFormatter *headerDateFormatter;

@property (nonatomic) BBMixesTableFooterView *tableFooterView;

@property (nonatomic, weak) IBOutlet UIView *emptyStateView;
@property (nonatomic, weak) IBOutlet UILabel *emptyStateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *emptyStateImageView;

@end

@implementation BBMixesViewController

- (void)commonInit
{    
    [super commonInit];
    
    _mixesSelectionOptions = [BBMixesSelectionOptions new];
    _mixesSelectionOptions.category = eAllMixesCategory;
    _mixesSelectionOptions.sortKey = eMixDateSortKey;
//    _mixesSelectionOptions.limit = kBBMixesStartFetchRequestLimit;
//    _mixesSelectionOptions.tag = [BBModelManager allTag];
    
    _detailTextsDictionary = [NSMutableDictionary new];
    _headerTextsDictionary = [NSMutableDictionary new];
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[BBMixesTableSectionHeaderView nib] forHeaderFooterViewReuseIdentifier:kBBBBMixesViewControllerHeaderID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateEmptyStateVisibility];
}

- (void)contentDidChange
{
    [super contentDidChange];
    
    [self updateEmptyStateVisibility];
}

- (void)updateTheme
{
    [super updateTheme];
    
    [self showNowPlayingBarButtonItem];
    
    BBThemeManager *themeManager = [BBThemeManager defaultManager];
    
    switch (themeManager.theme)
    {
        default:
            self.emptyStateView.backgroundColor = [UIColor colorWithHEX:0xFBFBFBFF];
            self.emptyStateLabel.textColor = [UIColor colorWithHEX:0x999999FF];
            break;
    }
    
    self.emptyStateLabel.font = [BBFont boldFontLikeFont:self.emptyStateLabel.font];
    self.emptyStateLabel.text = [[self titleForEmptyState] uppercaseString];
    
    self.emptyStateImageView.image = [themeManager imageNamed:[self imageNameForEmptyState]];
}

- (void)updateEmptyStateVisibility
{
    BOOL isEmpty = (self.fetchedResultsController.fetchedObjects.count == 0);
    self.emptyStateView.hidden = !isEmpty;
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix
{
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    cell.label.text = [mix.name uppercaseString];
    cell.detailLabel.text = [self detailTextForMix:mix];
    [cell.image setImageWithURL:[NSURL URLWithString:mix.imageUrl] placeholderImage:[BBUIUtils defaultImage]];
    
    cell.paused = (mix == audioManager.mix) ? audioManager.paused : YES;
    
    BBMixesTableViewCellState mixCellState = mix.favoriteDate ? BBMixesTableViewCellStateFavorite : BBMixesTableViewCellStateNormal;
    
    if (!mix.playbackDate)
    {
        mixCellState = BBMixesTableViewCellStateNew;
    }
    
    cell.mixState = mixCellState;
    cell.delegate = self;
}

- (void)updateNowPlayingCellAndSelectRow:(BOOL)selectRow
{
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    BBMix *mix = audioManager.mix;
    
    if ([self hasEntity:mix inTableView:self.tableView] == NO)
    {
        return;
    }

    NSIndexPath *indexPath = [self indexPathOfEntity:mix inTableView:self.tableView];
    BBMixesTableViewCell *cell = (BBMixesTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (cell == nil)
    {
        return;
    }
    
    cell.paused = !selectRow;
}

- (void)showTableFooterView
{
    self.tableView.tableFooterView = self.tableFooterView;
}

- (void)hideTableFooterView
{
    self.tableView.tableFooterView = nil;
}

- (BBMixesTableFooterView *)tableFooterView
{
    if (_tableFooterView == nil)
    {
        _tableFooterView = [BBMixesTableFooterView instanceFromNib:nil];
    }
    
    return _tableFooterView;
}

- (void)setTitle:(NSString *)title
{
    NSString *tabBarItemTitle = self.tabBarItem.title;
    
    [super setTitle:title];
    
    self.tabBarItem.title = tabBarItemTitle;
}

#pragma mark - Model

- (void)modelManagerDidFinishSaveNotification
{
    [super modelManagerDidFinishSaveNotification];
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

    NSFetchedResultsController *fetchedResultsController = self.fetchedResultsController;

    NSInteger currentMixIndex = [fetchedResultsController.fetchedObjects indexOfObject:currentMix];
    
    if (currentMixIndex == NSNotFound)
    {
        // Suppose user did change tag, when audio manager still playing mix from previous mixes fetch.
        
        currentMixIndex = 0;
    }
    
    NSInteger newMixIndex = MAX(MIN(fetchedResultsController.fetchedObjects.count - 1, currentMixIndex + indexOffset), 0);
    
    return [fetchedResultsController.fetchedObjects objectAtIndex:newMixIndex];
}

- (NSDateFormatter *)detailTextDateFormatter
{
    if (_detailTextDateFormatter == nil)
    {
        _detailTextDateFormatter = [NSDateFormatter new];
        [_detailTextDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_detailTextDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return _detailTextDateFormatter;
}

- (NSDateFormatter *)headerDateFormatter
{
    if (_headerDateFormatter == nil)
    {
        _headerDateFormatter = [NSDateFormatter new];
        
        if (_tableModelSectionRule == BBMixesTableModelSectionRuleEachMonth)
        {
            _headerDateFormatter.dateFormat = @"MMMM yyyy";
        }
        else
        {
            _headerDateFormatter.dateFormat = @"dd.MM.yyyy";
        }
        
//        [_headerDateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        [_headerDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return _headerDateFormatter;
}

- (NSString *)sectionNameKeyPath
{
    if (_tableModelSectionRule == BBMixesTableModelSectionRuleNone)
    {
        return nil;
    }
    
    if (self.mixesSelectionOptions.sortKey == eMixPlaybackDateSortKey)
    {
        return (_tableModelSectionRule == BBMixesTableModelSectionRuleEachDay) ? BBMixPlaybackDaySectionIdentifierKey : BBMixPlaybackMonthSectionIdentifierKey;
    }
    
    return (_tableModelSectionRule == BBMixesTableModelSectionRuleEachDay) ? BBMixDaySectionIdentifierKey : BBMixMonthSectionIdentifierKey;
}

#pragma mark - Actions

- (void)tagsBarButtonItemPressed
{
    [[BBAppDelegate rootViewController] toggleTagsVisibility];
}

#pragma mark - Notifications

- (void)startObserveNotifications
{
    [super startObserveNotifications];
    
    [self addSelector:@selector(audioManagerDidStartPlayNotification) forNotificationWithName:BBAudioManagerDidStartPlayNotification];
    [self addSelector:@selector(audioManagerDidStopNotification:) forNotificationWithName:BBAudioManagerDidStopNotification];
}

- (void)audioManagerDidStartPlayNotification
{
    [self updateNowPlayingCellAndSelectRow:YES];
}

- (void)audioManagerDidStopNotification:(NSNotification *)notification
{
    BBAudioManagerStopReason reason = [notification.userInfo[BBAudioManagerStopReasonKey] integerValue];
    
    [self updateNowPlayingCellAndSelectRow:reason != BBAudioManagerWillChangeMix];
}

#pragma mark - BBMixesTableViewCellDelegate

- (void)mixesTableViewCell:(BBMixesTableViewCell *)cell paused:(BOOL)paused
{
#warning DEAL WITH THIS
    BBMix *mix = [self entityForCell:cell inTableView:self.tableView];
    
    [self pause:paused mix:mix];
}

#pragma mark - BBTagsViewControllerDelegate

- (void)tagsViewControllerDidChangeTag:(BBTag *)tag
{
    _mixesSelectionOptions.tag = tag;
    
    [self reloadModel];
    
    if (self.fetchedResultsController.fetchedObjects.count > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBMix *mix = [self entityAtIndexPath:indexPath inTableView:tableView];
  
    [self pause:NO mix:mix];
    
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibilityFromNavigationController:self.navigationController];
}

- (NSString *)sectionTitleForHeaderInSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    NSString *sectionIDString = [sectionInfo name];
    
    if (!sectionIDString)
    {
        return nil;
    }

    NSNumber *sectionID = @([sectionIDString integerValue]);
    NSString *sectionHeader = self.headerTextsDictionary[sectionID];
    
    if (!sectionHeader)
    {
        BBMix *mix = (BBMix *)sectionInfo.objects.lastObject;
        sectionHeader = [self composeHeaderTextForMix:mix];
        self.headerTextsDictionary[sectionID] = sectionHeader;
    }
    
    return sectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self sectionTitleForHeaderInSection:section inTableView:tableView];
    
    if (!sectionTitle)
    {
        return nil;
    }
    
    BBMixesTableSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kBBBBMixesViewControllerHeaderID];
    headerView.label.text = sectionTitle;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self sectionTitleForHeaderInSection:section inTableView:tableView];
    
    if (!sectionTitle)
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
    NSFetchRequest *fetchRequest = [[BBModelManager defaultManager] fetchRequestForMixesWithSelectionOptions:_mixesSelectionOptions];
    return fetchRequest;
}

- (NSString *)detailTextForMix:(BBMix *)mix
{
    NSString *detailText = _detailTextsDictionary[mix.key];
    
    if (!detailText)
    {
        detailText = [self composeDetailTextForMix:mix];
        self.detailTextsDictionary[mix.key] = detailText;
    }
    
    return detailText;
}

- (NSString *)composeDetailTextForMix:(BBMix *)mix
{
//    return [self.detailTextDateFormatter stringFromDate:[self dateOfMix:mix]];
    return [BBUIUtils tagsStringForMix:mix];
}

- (NSString *)composeHeaderTextForMix:(BBMix *)mix
{
    return [self.headerDateFormatter stringFromDate:[self dateOfMix:mix]];
}

- (NSDate *)dateOfMix:(BBMix *)mix {
    
    if (self.mixesSelectionOptions.sortKey == eMixPlaybackDateSortKey) {
        return mix.playbackDate;
    }
    
    return mix.date;
}

- (NSString *)titleForEmptyState
{
    return nil;
}

- (NSString *)imageNameForEmptyState
{
    return nil;
}

@end
