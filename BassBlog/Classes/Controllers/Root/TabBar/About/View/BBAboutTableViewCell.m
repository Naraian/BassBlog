//
//  BBAboutTableViewCell.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 04.05.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBAboutTableViewCell.h"

#import "BBThemeManager.h"
#import "BBFont.h"

@implementation BBAboutTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    switch ([BBThemeManager defaultManager].theme)
    {
        case BBThemeBlack:
        case BBThemeWinter:
        {
            self.backgroundColor = [UIColor whiteColor];
            self.highlightedBackgroundColor = [UIColor colorWithHEX:0xCCCCCCFF];
            
            self.label.textColor = [UIColor colorWithHEX:0x515151FF];
            
            break;
        }
            
        default:
            break;
    }
    
    self.label.font = [BBFont boldFontLikeFont:self.label.font];
}

- (UILabel *)textLabel
{    
    return self.label;
}

@end
