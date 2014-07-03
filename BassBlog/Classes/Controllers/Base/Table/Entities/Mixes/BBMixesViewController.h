//
//  BBMixesViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewController.h"
#import "BBMixesTableViewCell.h"

#import "BBTagsViewControllerDelegate.h"

#import "BBMixesSelectionOptions.h"


typedef NS_ENUM(NSInteger, BBMixesTableModelSectionRule)
{
    BBMixesTableModelSectionRuleNone = 0,
    BBMixesTableModelSectionRuleEachDay,
    BBMixesTableModelSectionRuleEachMonth
};

@class BBMixesSelectionOptions;
@class BBMixesTableSectionHeaderView;

@interface BBMixesViewController : BBEntitiesViewController <BBTagsViewControllerDelegate, BBMixesTableViewCellDelegate>
{
    BBMixesTableModelSectionRule _tableModelSectionRule;
    
    BBMixesSelectionOptions *_mixesSelectionOptions;
}

@property (nonatomic, strong) NSMutableDictionary *detailTextsDictionary;
@property (nonatomic, strong) NSMutableDictionary *headerTextsDictionary;

- (void)updateEmptyStateVisibility;

@end

#pragma mark -

@class BBMix;
@class BBMixesViewControllerModelLoadOperation;

@interface BBMixesViewController (Protected)

- (NSString *)detailTextForMix:(BBMix *)mix;
- (NSString *)composeDetailTextForMix:(BBMix *)mix;
- (NSString *)composeHeaderTextForMix:(BBMix *)mix;

- (NSDate *)dateOfMix:(BBMix *)mix;

- (NSString *)titleForEmptyState;
- (NSString *)imageNameForEmptyState;

@end