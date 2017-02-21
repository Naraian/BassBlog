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
    
    self.label.font = [BBFont boldFontOfSize:10.f];
    
    self.backgroundView =
    ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    self.label.textColor = [UIColor colorWithHEX:0x808080FF];
}

- (void)setFrame:(CGRect)frame
{
    if (CGRectGetWidth(frame) > 0.f)
    {
        [super setFrame:frame];
    }
}

+ (CGFloat)height
{
    return 22.f;
}

@end
