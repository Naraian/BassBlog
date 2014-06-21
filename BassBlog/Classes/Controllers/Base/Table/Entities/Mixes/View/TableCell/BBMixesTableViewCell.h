//
//  BBMixesTableViewCell.h
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHighlightableTableViewCell.h"


@protocol BBMixesTableViewCellDelegate;

@interface BBMixesTableViewCell : BBHighlightableTableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;

@property (nonatomic, weak) id<BBMixesTableViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL paused;

@end

@protocol BBMixesTableViewCellDelegate

- (void)mixesTableViewCell:(BBMixesTableViewCell *)cell paused:(BOOL)paused;

@end