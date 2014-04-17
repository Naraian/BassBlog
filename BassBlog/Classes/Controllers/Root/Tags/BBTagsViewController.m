//
//  BBTagsViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTagsViewController.h"
#import "BBTagsViewControllerDelegate.h"

#import "BBTagsTableViewCell.h"

#import "BBRootViewController.h"
#import "BBAppDelegate.h"

#import "BBTagsSelectionOptions.h"
#import "BBMixesSelectionOptions.h"

#import "BBOperationManager.h"
#import "BBTagsViewControllerModelLoadOperation.h"

#import "BBModelManager.h"

#import "BBTableModel.h"

#import "BBTag.h"


const NSInteger kBBAllTagTableModelRow = 0;

@interface BBTagsViewController ()
{
    BBTagsSelectionOptions *_tagsSelectionOptions;
    
    NSMutableDictionary *_mixesCountNumbersDictionary;
    
    BBTag *_tag;
}

@end

@implementation BBTagsViewController

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _tagsSelectionOptions = [BBTagsSelectionOptions new];
        _tagsSelectionOptions.sortKey = eTagNameSortKey;
        
        _tag = [BBModelManager allTag];
    }
    
    return self;
}

#pragma mark - View

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{
    return [BBTagsTableViewCell nibName];
}

- (void)configureCell:(BBTagsTableViewCell *)cell withEntity:(BBTag *)tag {
    
    cell.textLabel.text = [tag.name uppercaseString];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",
                                 [_mixesCountNumbersDictionary[tag.key] unsignedIntegerValue]];
}

- (void)updateTheme
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    [super updateTheme];
    
    [self.tableView selectRowAtIndexPath:selectedIndexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Model

- (id)modelReloadOperation {
    
    BBTagsViewControllerModelLoadOperation *operation =
    [BBTagsViewControllerModelLoadOperation new];
    
    operation.tableModel = [BBTableModel new];
    operation.tagsDictionary = [NSMutableDictionary new];
    operation.mixesCountNumbersDictionary = [NSMutableDictionary new];
    operation.tagsSelectionOptions = [_tagsSelectionOptions mutableCopy];

    BBMixesSelectionOptions *mixesSelectionOptions = [BBMixesSelectionOptions new];
    mixesSelectionOptions.category = _tagsSelectionOptions.category;
    
    operation.handleEntity = ^(BBTagsViewControllerModelLoadOperation *anOperation, BBTag *tag) {
        
        NSString *key = tag.key;
        
        mixesSelectionOptions.tag = tag;
        
        NSNumber *mixesCountNumber = @([[BBModelManager defaultManager] mixesCountWithSelectionOptions:mixesSelectionOptions]);
        
        [anOperation.mixesCountNumbersDictionary setObject:mixesCountNumber forKey:key];
        
        [anOperation.tableModel addCellKey:key toSectionID:eBBDefaultTableModelSectionID];
    };
    
    return operation;
}

- (void)applyModelLoadOperation:(BBTagsViewControllerModelLoadOperation *)operation {
    
    _tableModel = operation.tableModel;
    _entitiesDictionary = operation.tagsDictionary;
    _mixesCountNumbersDictionary = operation.mixesCountNumbersDictionary;
    
    NSIndexPath *oldAllTagIndexPath = [self indexPathOfEntity:[BBModelManager allTag]];
    
    if (oldAllTagIndexPath.row == kBBAllTagTableModelRow) {
        return;
    }
    
    NSIndexPath *newAllTagIndexPath =
    [NSIndexPath indexPathForRow:kBBAllTagTableModelRow
                       inSection:eBBDefaultTableModelSectionID];

    [_tableModel moveCellAtIndexPath:oldAllTagIndexPath toIndexPath:newAllTagIndexPath];
}

- (void)completeModelReload {
    
    [super completeModelReload];
    
    [self.tableView selectRowAtIndexPath:[self indexPathOfEntity:_tag]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}

- (void)mergeModelAndViewWithEntity:(BBTag *)tag {
    
    [self mergeModelWithEntity:tag];
    
    [self updateCellForEntity:tag];
}

- (void)mergeModelWithEntity:(BBTag *)tag {
    
#warning TODO: implement ...
}

- (BOOL)needApplyDelegateSelectionOptions {
    
    BBMixesSelectionOptions *options = [self.delegate mixesSelectionOptions];
    
    return _tagsSelectionOptions.category != options.category
        || _tag != options.tag;
}

- (void)setDelegate:(id<BBTagsViewControllerDelegate>)delegate {
    
    if (_delegate == delegate) {
        return;
    }
    
    _delegate = delegate;
    
    // This:
    // - prevents from unnecessary reload
    // - helps delegate to finish view update
    
    NSAssert([NSThread isMainThread], @"%s [NSThread isMainThread] == NO", __FUNCTION__);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ([self needApplyDelegateSelectionOptions]) {
        
        [self performSelector:@selector(applyDelegateSelectionOptionsAndUpdateModel)
                   withObject:nil
                   afterDelay:0.5];
    }
}

- (void)applyDelegateSelectionOptionsAndUpdateModel {
    
    BBMixesSelectionOptions *options = [self.delegate mixesSelectionOptions];
    
    _tagsSelectionOptions.category = options.category;
    _tag = options.tag;

    [self reloadModel];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBTag *tag = (BBTag *)[self entityAtIndexPath:indexPath];
    
    if (_tag != tag) {
        
        _tag = tag;
    
        [self.delegate tagsViewControllerDidChangeTag:_tag];
    }
    
    [[BBAppDelegate rootViewController] toggleTagsVisibility];
}

@end
