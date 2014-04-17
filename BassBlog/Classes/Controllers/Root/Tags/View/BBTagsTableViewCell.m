//
//  BBTagsTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTagsTableViewCell.h"

#import "BBThemeManager.h"

#import "BBFont.h"


@implementation BBTagsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.label.font = [BBFont boldFontLikeFont:self.label.font];
    self.detailLabel.font = [BBFont boldFontLikeFont:self.detailLabel.font];
    
    switch ([BBThemeManager defaultManager].theme)
    {
        default:
        {
            selectedBackgroundColor = [UIColor colorWithHEX:0x555555FF];
            highlightedBackgroundColor = [UIColor colorWithHEX:0x777777FF];
        }
            break;
    }
}

- (UILabel *)textLabel {
    
    return self.label;
}

- (UILabel *)detailTextLabel {
    
    return self.detailLabel;
}

@end
