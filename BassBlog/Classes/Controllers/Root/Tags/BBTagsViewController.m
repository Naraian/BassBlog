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

#import "BBThemeManager.h"

#import "BBTagsSelectionOptions.h"
#import "BBMixesSelectionOptions.h"

#import "BBOperationManager.h"

#import "BBModelManager.h"

#import "BBEntity+Service.h"
#import "BBTag.h"
#import "BBMix.h"


const NSInteger kBBAllTagTableModelRow = 0;

@interface BBTagsViewController ()
{
    BBTagsSelectionOptions *_tagsSelectionOptions;
    
    BBTag *_tag;
}

@end

@implementation BBTagsViewController

- (void)commonInit
{
    [super commonInit];
    
    _tagsSelectionOptions = [BBTagsSelectionOptions new];
    _tagsSelectionOptions.sortKey = eTagNameSortKey;
}

#pragma mark - View

- (NSFetchRequest *)fetchRequestForSearch:(BOOL)search
{
    return [[BBModelManager defaultManager] fetchRequestForTagsWithSelectionOptions:_tagsSelectionOptions];
}

- (NSString *)sectionNameKeyPath
{
    return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [self indexPathOfEntity:_tag inTableView:self.tableView];
    
    if (!indexPath)
    {
        if ([self.tableView numberOfRowsInSection:0] > 0)
        {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    
    if (indexPath)
    {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{
    return [BBTagsTableViewCell nibName];
}

- (void)configureCell:(BBTagsTableViewCell *)cell withEntity:(BBTag *)tag
{
    if (tag.mainTag)
    {
        NSUInteger mixesCount = tag.mixes.count;
        cell.label.text = [BBTag allName];
        cell.detailLabel.text = [NSString stringWithFormat:@"%d", mixesCount];
    }
    else
    {
        cell.label.text = tag.formattedName;
        cell.detailLabel.text = nil;
    }
}

- (void)updateTheme
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    [super updateTheme];
    
    switch ([BBThemeManager defaultManager].theme)
    {
        default:
        {
            self.view.backgroundColor = [UIColor colorWithHEX:0x252525FF];
            self.tableView.backgroundColor = [UIColor colorWithHEX:0x252525FF];
        }
        break;
    }
    
    if (selectedIndexPath)
    {
        [self.tableView selectRowAtIndexPath:selectedIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Model

- (BOOL)needApplyDelegateSelectionOptions
{
    BBMixesSelectionOptions *options = [self.delegate mixesSelectionOptions];
    
    return  (_tagsSelectionOptions.category != options.category) ||
            (_tag != options.tag);
}

- (void)setDelegate:(id<BBTagsViewControllerDelegate>)delegate
{
    if (_delegate == delegate)
    {
        return;
    }
    
    _delegate = delegate;
    
    // This:
    // - prevents from unnecessary reload
    // - helps delegate to finish view update
    
    NSAssert([NSThread isMainThread], @"%s [NSThread isMainThread] == NO", __FUNCTION__);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if ([self needApplyDelegateSelectionOptions])
    {
        [self performSelector:@selector(applyDelegateSelectionOptionsAndUpdateModel)
                   withObject:nil
                   afterDelay:0.5];
    }
}

- (void)applyDelegateSelectionOptionsAndUpdateModel
{
    BBMixesSelectionOptions *options = [self.delegate mixesSelectionOptions];
    
    _tagsSelectionOptions.category = options.category;
    _tag = options.tag;

    [self reloadModel];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTag *tag = (BBTag *)[self entityAtIndexPath:indexPath inTableView:tableView];
    
    if (_tag != tag)
    {
        _tag = tag;
    
        [self.delegate tagsViewControllerDidChangeTag:_tag];
    }
    
    [[BBAppDelegate rootViewController] toggleTagsVisibility];
}

@end
