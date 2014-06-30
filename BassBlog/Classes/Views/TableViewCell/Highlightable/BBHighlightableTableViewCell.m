//
//  PTTHighlightableTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09/06/13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHighlightableTableViewCell.h"

@interface BBHighlightableTableViewCell()

@end

@implementation BBHighlightableTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
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
    UIColor *color = _backgroundColor;
    if (self.isHighlighted)
    {
        color = [self highlightedBackgroundColor];
    }
    else if (self.isSelected)
    {
        color = [self selectedBackgroundColor];
    }
    
    [super setBackgroundColor:color];
}

- (UIColor *)highlightedBackgroundColor
{
    if (_highlightedBackgroundColor)
    {
        return _highlightedBackgroundColor;
    }
    
    if (_selectedBackgroundColor)
    {
        return _selectedBackgroundColor;
    }
    
    return _backgroundColor;
}

- (UIColor *)selectedBackgroundColor
{
    if (_selectedBackgroundColor)
    {
        return _selectedBackgroundColor;
    }
    
    return _backgroundColor;
}

@end
