//
//  PTTHighlightableTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09/06/13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHighlightableTableViewCell.h"


@implementation BBHighlightableTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    backgroundColor = self.backgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self updateBackgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self updateBackgroundColor];
}

- (void)updateBackgroundColor
{
    if (self.isHighlighted)
    {
        self.backgroundColor = [self highlightedBackgroundColor];
    }
    else if (self.isSelected)
    {
        self.backgroundColor = [self selectedBackgroundColor];
    }
    else
    {
        self.backgroundColor = backgroundColor;
    }
}

- (UIColor *)highlightedBackgroundColor
{
    if (highlightedBackgroundColor)
        return highlightedBackgroundColor;
    
    if (selectedBackgroundColor)
        return selectedBackgroundColor;
    
    return backgroundColor;
}

- (UIColor *)selectedBackgroundColor
{
    if (selectedBackgroundColor)
        return selectedBackgroundColor;
    
    return backgroundColor;
}

@end
