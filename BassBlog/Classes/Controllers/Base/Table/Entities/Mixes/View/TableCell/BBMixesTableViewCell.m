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

- (void)awakeFromNib {
    
    self.backgroundColor =
    [[BBThemeManager defaultManager] colorWithPatternImageNamed:@"table_view/cell/mix_background"];
    
    [super awakeFromNib];
    
    self.label.font = [BBFont fontLikeFont:self.label.font];
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
