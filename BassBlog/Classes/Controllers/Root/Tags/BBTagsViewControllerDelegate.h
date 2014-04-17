//
//  BBTagsViewControllerDelegate.h
//  BassBlog
//
//  Created by Evgeny Sivko on 10.04.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

@class BBTag;
@class BBTagsViewController;
@class BBMixesSelectionOptions;

@protocol BBTagsViewControllerDelegate

- (void)tagsViewControllerDidChangeTag:(BBTag *)tag;

- (BBMixesSelectionOptions *)mixesSelectionOptions;

@end
