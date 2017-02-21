//
//  BBSearchTableViewCell.m
//  BassBlog
//
//  Created by Evgeny Sivko on 26.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBSearchTableViewCell.h"
#import "MarqueeLabel.h"

@interface BBSearchTableViewCell()

@property (nonatomic, strong) IBOutlet MarqueeLabel *label;

@end

@implementation BBSearchTableViewCell

@dynamic label;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.label.trailingBuffer = 30.f;
    self.label.animationDelay = 1.0;
    self.label.rate = 30.f;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.marqueeType = MLContinuous;
}

- (void)setPaused:(BOOL)paused
{
    [super setPaused:paused];

    self.label.labelize = paused;
}

@end
