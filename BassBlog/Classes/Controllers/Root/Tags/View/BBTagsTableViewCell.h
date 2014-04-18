//
//  BBTagsTableViewCell.h
//  BassBlog
//
//  Created by Evgeny Sivko on 09.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHighlightableTableViewCell.h"


@interface BBTagsTableViewCell : BBHighlightableTableViewCell

@property (nonatomic, strong) IBOutlet UIView *leftColorView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;

@end
