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
            self.backgroundColor = [UIColor colorWithHEX:0x252525FF];
            self.selectedBackgroundColor = [UIColor colorWithHEX:0x333333FF];
            self.highlightedBackgroundColor = [UIColor colorWithHEX:0x333333FF];
            
            self.leftColorView.layer.borderWidth = 1.f;
            self.leftColorView.layer.borderColor = [UIColor colorWithHEX:0x1E1E1EFF].CGColor;
        }
        break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.leftColorView.backgroundColor = selected ? [UIColor colorWithHEX:0xD46464FF] : [UIColor colorWithHEX:0x1E1E1EFF];
}

@end
