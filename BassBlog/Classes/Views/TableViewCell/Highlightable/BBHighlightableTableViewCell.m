//
//  PTTHighlightableTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 09/06/13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBHighlightableTableViewCell.h"

@interface BBHighlightableTableViewCell()

@property (strong, nonatomic) UIView *separatorView;

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

#pragma mark - 
#pragma mark Bottom separator

- (void)updateBottomSeparatorColor
{
    if (!self.selected && !self.highlighted)
    {
        self.separatorView.backgroundColor = self.bottomSeparatorColor;
    }
    else
    {
        UIColor *selectedSeparatorColor = self.selectedBottomSeparatorColor;
        
        if (!selectedSeparatorColor)
        {
            selectedSeparatorColor = [UIColor clearColor];
        }
        
        self.separatorView.backgroundColor = selectedSeparatorColor;
    }
}

- (void)setBottomSeparatorColor:(UIColor *)separatorColor
{
    _bottomSeparatorColor = separatorColor;
    
    [self setupConstraintForSeparator];
    [self updateBottomSeparatorColor];
}

- (void)setBottomSeparatorInset:(UIEdgeInsets)bottomSeparatorInset
{
    _bottomSeparatorInset = bottomSeparatorInset;
    
    [self setupConstraintForSeparator];
}

- (void)setupConstraintForSeparator
{
    if (!self.separatorView)
    {
        self.separatorView = [UIView new];
        self.separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.separatorView];
    }
    else
    {
        [self.separatorView removeAllConstraints];
    }
    
    CGFloat separatorHeight = 1.f/UI_SCREEN_SCALE;
    NSDictionary *theViews = NSDictionaryOfVariableBindings(_separatorView);
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                 attribute:NSLayoutAttributeLeft
                                                                    toItem:self.contentView
                                                                  constant:self.bottomSeparatorInset.left]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                 attribute:NSLayoutAttributeRight
                                                                    toItem:self.contentView
                                                                  constant:self.bottomSeparatorInset.right]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_separatorView(height)]|" metrics:@{@"height" : @(separatorHeight)} views:theViews]];
}

@end
