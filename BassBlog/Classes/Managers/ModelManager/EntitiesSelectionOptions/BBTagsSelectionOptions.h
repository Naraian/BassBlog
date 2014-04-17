//
//  BBTagsSelectionOptions.h
//  BassBlog
//
//  Created by Evgeny Sivko on 15.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesSelectionOptions.h"


NS_ENUM(BBEntitiesSortKey, BBTagsSortKey)
{
    eTagNameSortKey = eEntityNoneSortKey + 1
};

@interface BBTagsSelectionOptions : BBEntitiesSelectionOptions

@end
