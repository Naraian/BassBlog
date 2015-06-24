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
    
    switch ([BBThemeManager defaultManager].theme)
    {
        case BBThemeBlack:
        case BBThemeWinter:
            
            self.backgroundView =
            ({
                UIView * view = [[UIView alloc] initWithFrame:self.bounds];
                view.backgroundColor = [UIColor colorWithHEX:0xEBEBEBFF];
                view;
            });
            
            self.layer.borderColor = [UIColor colorWithHEX:0xCCCCCCFF].CGColor;
            self.layer.borderWidth = 1.f/UI_SCREEN_SCALE;
            self.label.textColor = [UIColor colorWithHEX:0x5C5C5CFF];
            break;
            
        default:
            break;
    }
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
    return 26.f;
}

@end
