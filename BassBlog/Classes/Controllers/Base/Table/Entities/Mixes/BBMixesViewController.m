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
#import "BBMixesViewControllerModelLoadOperation.h"

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
BBAudioManagerDelegate,
BBMixesTableViewCellDelegate
>
{
    BBEntitiesViewControllerModelLoadOperation *_uploadOperation;
    
    NSMutableDictionary *_detailTextsDictionary;
    
    NSMutableDictionary *_headerTextsDictionary;
    
    NSMutableArray *_mixesArray;
    
    UINib *_sectionHeaderNib;
    
    BOOL _shouldUploadModel;
}

@property (nonatomic) NSDateFormatter *detailTextDateFormatter;
@property (nonatomic) NSDateFormatter *headerDateFormatter;

@property (nonatomic) BBMixesTableFooterView *tableFooterView;
@property (nonatomic) BOOL uploadModelOnSaveFinish;

@end

@implementation BBMixesViewController

- (id)init {
    
    self = [self initWithNibName:[BBMixesViewController nibName]
                          bundle:nil];
    if (self) {
        
        _mixesSelectionOptions = [BBMixesSelectionOptions new];
        _mixesSelectionOptions.category = eAllMixesCategory;
        _mixesSelectionOptions.sortKey = eMixDateSortKey;
        _mixesSelectionOptions.limit = kBBMixesStartFetchRequestLimit;
        _mixesSelectionOptions.tag = [BBModelManager allTag];
    }
    
    return self;
}

#pragma mark - View

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self updateNavigationBar];
    
    [[BBAppDelegate rootViewController] tagsViewController].delegate = self;
}

- (void)updateTheme {
    
    [super updateTheme];
    
    [self showTagsBarButtonItem];
    
    [self showNowPlayingBarButtonItem];
}

- (void)configureCell:(BBMixesTableViewCell *)cell withEntity:(BBMix *)mix {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    cell.label.text = mix.name;
    cell.detailLabel.text = _detailTextsDictionary[mix.key];
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

- (void)showTagsBarButtonItem
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

- (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                       selector:(SEL)selector
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button addTarget:self
               action:selector
            forControlEvents:UIControlEventTouchUpInside];
    
    imageName = [@"navigation_bar/item" stringByAppendingPathComponent:imageName];
    [button setImage:[tm imageNamed:imageName] forState:UIControlStateNormal];
    
    imageName = [imageName stringByAppendingString:@"_highlighted"];
    [button setImage:[tm imageNamed:imageName] forState:UIControlStateHighlighted];
    
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)updateNavigationBar
{
    BOOL hasMixes = (_entitiesDictionary.count > 0);
    
    self.navigationItem.leftBarButtonItem.enabled = hasMixes;
    
    if (hasMixes) {
        self.title = [_mixesSelectionOptions.tag.name uppercaseString];
    }
    else {
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
    
    if (self.uploadModelOnSaveFinish) {
        
        [self uploadModel];
    }
}

- (id)modelReloadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [self modelLoadOperation];
    
    operation.tableModel = [BBTableModel new];
    operation.mixesArray = [NSMutableArray new];
    operation.mixesDictionary = [NSMutableDictionary new];
    
    return operation;
}

- (id)modelUploadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [self modelLoadOperation];
    
    operation.tableModel = [_tableModel mutableCopy];
    operation.mixesArray = [_mixesArray mutableCopy];
    operation.mixesDictionary = [_entitiesDictionary mutableCopy];
    operation.detailTextsDictionary = [_detailTextsDictionary mutableCopy];
    operation.headerTextsDictionary = [_headerTextsDictionary mutableCopy];
    operation.mixesSelectionOptions.offset = _mixesArray.count;
    
    return operation;
}

- (void)applyModelLoadOperation:(BBMixesViewControllerModelLoadOperation *)operation {
        
    _tableModel = operation.tableModel;
    _mixesArray = operation.mixesArray;
    _entitiesDictionary = operation.mixesDictionary;
    _detailTextsDictionary = operation.detailTextsDictionary;
    _headerTextsDictionary = operation.headerTextsDictionary;
    
    _shouldUploadModel = operation.mixesSelectionOptions.totalLimit == _mixesArray.count;
}

- (void)completeModelReload {
    
    [super completeModelReload];
    
    [self updateNavigationBar];
}

- (void)uploadModel {
    
    [_uploadOperation cancel];
    _uploadOperation = nil;
    
    [self showTableFooterView];
    
    self.uploadModelOnSaveFinish = NO;
    
    if ([[BBModelManager defaultManager] isSaveInProgress]) {
        
        self.uploadModelOnSaveFinish = YES;
        return;
    }
    
    _uploadOperation = [self modelUploadOperation];
    
    __weak BBMixesViewController *weakSelf = self;
    __weak BBEntitiesViewControllerModelLoadOperation *uploadOperation = _uploadOperation;
    
    uploadOperation.finish = ^(BBEntitiesViewControllerModelLoadOperation *operation) {
        
        if ([operation isCompleted]) {
            
            [weakSelf applyModelLoadOperation:operation];
            [weakSelf mergePendingEntities];
            return;
        }
        
        ERR(@"Couldn't complete model upload operation!");
    };
    
    [uploadOperation setCompletionBlock:^{
        
        if ([uploadOperation isCancelled]) {
            return;
        }
        
        [self.class mainThreadAsyncBlock:^{
            [weakSelf completeModelUpload];
        }];
    }];
    
    [[BBOperationManager defaultManager] addOperation:_uploadOperation];
}

- (void)completeModelUpload {
    
    [self hideTableFooterView];
    
    [self.tableView reloadData];
}

- (void)pause:(BOOL)pause mix:(BBMix *)mix {
    
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    [audioManager setMix:mix paused:pause];
    audioManager.delegate = self;
}

- (BBMix *)mixWithCurrentIndexOffset:(NSInteger)indexOffset {
    
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

- (void)mergeModelAndViewWithEntity:(BBMix *)mix {
    
    if (NO == [self shouldMergeMix:mix]) {
        return;
    }
    
#warning TODO: implement using table view animations...
    
    [self mergeModelWithEntity:mix];
    
    [self.tableView reloadData];
}

- (void)mergeModelWithEntity:(BBMix *)mix {
    
    if (NO == [self shouldMergeMix:mix]) {
        return;
    }
    
    // Updated containers.
    
    id key = mix.key;
    NSUInteger mixesArrayIndex = 0;
    
    if ([self hasEntity:mix]) {
     
        [_mixesArray removeObject:mix];
        [_tableModel removeCellKey:key];
        
        mixesArrayIndex =
        [_mixesArray indexOfObjectPassingTest:^BOOL(BBMix *theMix, NSUInteger idx, BOOL *stop) {
            
            return [[self dateOfMix:mix] compare:[self dateOfMix:theMix]] != NSOrderedAscending;
        }];
    }
    else {
        
        [_entitiesDictionary setObject:mix forKey:key];
        
        if (_detailTextsDictionary) {
            _detailTextsDictionary[key] = [self detailTextForMix:mix];
        }
    }
    
    [_mixesArray insertObject:mix atIndex:mixesArrayIndex];
    
    // Update table model.
    
    NSInteger sectionID = [self sectionIDForMix:mix];
    NSArray *cellKeysArray = [_tableModel cellKeysInSectionID:sectionID];
    
    if (cellKeysArray) {
        
        BBMix *nextMix = [_mixesArray objectAtIndex:mixesArrayIndex + 1];
        NSUInteger cellKeysArrayIndex = [cellKeysArray indexOfObject:nextMix.key];
        
        [_tableModel insertCellKey:key toSectionID:sectionID atIndex:cellKeysArrayIndex];
    }
    else {
        
        for (NSUInteger section = 0; section < [_tableModel numberOfSections]; ++section) {
            
            NSInteger IDOfSection = [_tableModel IDOfSection:section];
            if (sectionID > IDOfSection) {
                
                [_tableModel insertSectionID:sectionID atIndex:section];
                break;
            }
        }
        
        [_tableModel addCellKey:key toSectionID:sectionID];
        
        if (_headerTextsDictionary) {
            _headerTextsDictionary[@(sectionID)] = [self headerTextForMix:mix];
        }
    }
}

- (BOOL)shouldMergeMix:(BBMix *)mix {
    
    BBTag *tag = _mixesSelectionOptions.tag;
    
#warning TODO: replace containsObject with custom contains test if needed...
    
    return tag == [BBModelManager allTag]
        || [mix.tags containsObject:tag];
}

#pragma mark - Actions

- (void)tagsBarButtonItemPressed {
    
    [[BBAppDelegate rootViewController] toggleTagsVisibility];
}

- (void)nowPlayingBarButtonItemPressed {
    
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibility];
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

- (void)audioManagerDidStopNotification:(NSNotification *)notification {
    
    BBAudioManagerStopReason reason =
    [notification.userInfo[BBAudioManagerStopReasonKey] integerValue];
    
    [self updateNowPlayingCellAndSelectRow:reason != BBAudioManagerWillChangeMix];
}

#pragma mark - BBMixesTableViewCellDelegate

- (void)mixesTableViewCell:(BBMixesTableViewCell *)cell paused:(BOOL)paused {
    
    BBMix *mix = [self entityForCell:cell];
    
    [self pause:paused mix:mix];
}

#pragma mark - BBTagsViewControllerDelegate

- (void)tagsViewControllerDidChangeTag:(BBTag *)tag {
    
    _mixesSelectionOptions.tag = tag;
    
    [self reloadModel];
}

- (BBMixesSelectionOptions *)mixesSelectionOptions
{
    return _mixesSelectionOptions;
}

#pragma mark - BBAudioManagerDelegate

- (BBMix *)nextMix {
    
    return [self mixWithCurrentIndexOffset:1];
}

- (BBMix *)prevMix {
    
    return [self mixWithCurrentIndexOffset:-1];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBMix *mix = [self entityAtIndexPath:indexPath];
  
    [self pause:NO mix:mix];
    
    [[BBAppDelegate rootViewController] toggleNowPlayingVisibility];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (_headerTextsDictionary == nil) {
        
        return nil;
    }
    
    BBMixesTableSectionHeaderView *headerView = [self sectionHeaderView];
    
    id key = @([_tableModel IDOfSection:section]);
    headerView.label.text = _headerTextsDictionary[key];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_headerTextsDictionary == nil) {
        
        return 0.f;
    }
    
    return [BBMixesTableSectionHeaderView height];
}

#pragma mark - UIScrollView

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (_shouldUploadModel == NO) {
        return;
    }
    
    if (self.tableView.tableFooterView) {
        return;
    }
    
    if ((*targetContentOffset).y < self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds)) {
        return;
    }
    
    [self uploadModel];
}

@end

#pragma mark -

@implementation BBMixesViewController (Protected)

- (BBMixesViewControllerModelLoadOperation *)modelLoadOperation {
    
    BBMixesViewControllerModelLoadOperation *operation = [BBMixesViewControllerModelLoadOperation new];
    
    operation.mixesSelectionOptions = [_mixesSelectionOptions mutableCopy];
    
    return operation;
}

- (NSString *)detailTextForMix:(BBMix *)mix {
    
    return [self.detailTextDateFormatter stringFromDate:[self dateOfMix:mix]];
}

- (NSString *)headerTextForMix:(BBMix *)mix {
    
    return [self.headerDateFormatter stringFromDate:[self dateOfMix:mix]];
}

- (NSInteger)sectionIDForMix:(BBMix *)mix {
    
    NSUInteger components = NSYearCalendarUnit | NSMonthCalendarUnit;
    
    if (_tableModelSectionRule == BBMixesTableModelSectionRuleEachDay) {
        components |= NSDayCalendarUnit;
    }
    
    return [self sectionIDFromDate:[self dateOfMix:mix] components:components];
}

- (NSDate *)dateOfMix:(BBMix *)mix {
    
    if (self.mixesSelectionOptions.sortKey == eMixPlaybackDateSortKey) {
        return mix.playbackDate;
    }
    
    return mix.date;
}

@end
