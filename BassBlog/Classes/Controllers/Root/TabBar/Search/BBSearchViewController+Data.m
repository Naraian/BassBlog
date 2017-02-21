//
//  BBSearchViewController+Data.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 2/20/17.
//  Copyright © 2017 BassBlog. All rights reserved.
//

#import "BBSearchViewController+Data.h"
#import "BBModelManager.h"

@implementation BBSearchViewController(Data)

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[BBModelManager defaultManager] fetchRequestForSearchMixesWithSelectionOptions:_mixesSelectionOptions];
    return fetchRequest;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.mixesSelectionOptions.substringInName = searchText;
    
    [self reloadModel];
}

@end
