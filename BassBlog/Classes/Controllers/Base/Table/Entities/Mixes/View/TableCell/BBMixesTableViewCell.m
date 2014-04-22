//
//  BBMixesTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBMixesTableViewCell.h"

#import "BBThemeManager.h"

#import "BBFont.h"


@implementation BBMixesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    switch ([BBThemeManager defaultManager].theme)
    {
        case BBThemeBlack:
        case BBThemeWinter:
        {
            self.bottomSeparatorColor = [UIColor colorWithHEX:0xCCCCCCFF];
            self.selectedBottomSeparatorColor = [UIColor colorWithHEX:0xCCCCCCFF];

            self.backgroundColor = [UIColor whiteColor];
            self.highlightedBackgroundColor = [UIColor colorWithHEX:0xCCCCCCFF];
            
            self.label.textColor = [UIColor colorWithHEX:0x515151FF];
            self.detailLabel.textColor = [UIColor colorWithHEX:0x8A8A8AFF];
            
            break;
        }
            
        default:
            break;
    }
    
    self.bottomSeparatorInset = UIEdgeInsetsMake(0.f, 14.f, 0.f, 0.f);
    
    self.label.font = [BBFont boldFontLikeFont:self.label.font];
    self.detailLabel.font = [BBFont fontLikeFont:self.detailLabel.font];
    
    [self setPaused:YES];
}

- (UILabel *)textLabel {
    
    return self.label;
}

- (UILabel *)detailTextLabel {
    
    return self.detailLabel;
}

#pragma mark - Actions

- (IBAction)buttonPressed {
    
    self.paused = (self.paused == NO);
    
    [self.delegate mixesTableViewCell:self paused:self.paused];
}

@end
