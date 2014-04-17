//
//  BBMixesViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesViewController.h"

#import "BBTagsViewControllerDelegate.h"

#import "BBMixesSelectionOptions.h"


typedef NS_ENUM(NSInteger, BBMixesTableModelSectionRule) {
    
    BBMixesTableModelSectionRuleEachDay,
    BBMixesTableModelSectionRuleEachMonth
};

@class BBMixesSelectionOptions;
@class BBMixesTableSectionHeaderView;

@interface BBMixesViewController : BBEntitiesViewController <BBTagsViewControllerDelegate>
{
    BBMixesTableModelSectionRule _tableModelSectionRule;
    
    BBMixesSelectionOptions *_mixesSelectionOptions;
}

@end

#pragma mark -

@class BBMix;
@class BBMixesViewControllerModelLoadOperation;

@interface BBMixesViewController (Protected)

- (BBMixesViewControllerModelLoadOperation *)modelLoadOperation;

- (NSString *)detailTextForMix:(BBMix *)mix;

- (NSString *)headerTextForMix:(BBMix *)mix;

- (NSInteger)sectionIDForMix:(BBMix *)mix;

- (NSDate *)dateOfMix:(BBMix *)mix;

@end