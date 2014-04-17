//
//  BBMixesTableSectionHeaderView.m
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesTableSectionHeaderView.h"

#import "BBThemeManager.h"

#import "BBFont.h"


@implementation BBMixesTableSectionHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.label.font = [BBFont boldFontLikeFont:self.label.font];
    
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    self.backgroundColor =
    [tm colorWithPatternImageNamed:@"table_view/section_header/mix_background"];
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectGetWidth(frame))
    {
        [super setFrame:frame];
    }
}

+ (CGFloat)height
{
    return 30.f;
}

@end
