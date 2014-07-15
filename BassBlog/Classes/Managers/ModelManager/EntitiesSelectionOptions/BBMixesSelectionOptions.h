//
//  BBMixesSelectionOptions.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBEntitiesSelectionOptions.h"


NS_ENUM(BBEntitiesSortKey, BBMixesSortKey)
{
    eMixDateSortKey = eEntityNoneSortKey + 1,
    eMixPlaybackDateSortKey,
    eMixFavoriteDateSortKey
};

@class BBTag;

@interface BBMixesSelectionOptions : BBEntitiesSelectionOptions

@property (nonatomic, strong) BBTag *tag;
@property (nonatomic, strong) NSString *substringInName;

@end
