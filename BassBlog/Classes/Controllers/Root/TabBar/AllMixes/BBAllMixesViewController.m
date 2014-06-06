//
//  BBAllMixesViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 08.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBAllMixesViewController.h"
#import "BBTagsViewController.h"

#import "BBMixesTableSectionHeaderView.h"
#import "BBAllMixesTableViewCell.h"

#import "BBMix.h"

#import "NSObject+Nib.h"
#import "BBUIUtils.h"
#import "BBAppDelegate.h"
#import "BBRootViewController.h"


@implementation BBAllMixesViewController

- (void)commonInit
{
    [super commonInit];
    
    self.title = NSLocalizedString(@"ALL MIXES", @"");
    
    [self setTabBarItemTitle:self.title
                  imageNamed:@"mixes_tab"
                         tag:eAllMixesCategory];
        
    _tableModelSectionRule = BBMixesTableModelSectionRuleEachMonth;
    
    self.detailTextsDictionary = [NSMutableDictionary new];
    self.headerTextsDictionary = [NSMutableDictionary new];
}


- (void)showLeftBarButtonItem
{
    self.navigationItem.leftBarButtonItem =
    [self barButtonItemWithImageName:@"tags"
                            selector:@selector(tagsBarButtonItemPressed)];
    
    //self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)updateTheme {
    
    [super updateTheme];
    
    [self showLeftBarButtonItem];
}

#pragma mark - View

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[BBAppDelegate rootViewController] tagsViewController].delegate = self;
}

- (NSString *)cellNibNameAtIndexPath:(NSIndexPath *)indexPath
{    
    return [BBAllMixesTableViewCell nibName];
}

#pragma mark - Model

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(BBMix *)mix atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [super controller:controller didChangeObject:mix atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
    NSInteger sectionID = [self sectionIDForMix:mix];
    
    self.detailTextsDictionary[mix.key] = [BBUIUtils tagsStringForMix:mix];
    
    if (self.headerTextsDictionary[@(sectionID)] == nil)
    {
        self.headerTextsDictionary[@(sectionID)] = [self composeHeaderTextForMix:mix];
    }
}

@end
