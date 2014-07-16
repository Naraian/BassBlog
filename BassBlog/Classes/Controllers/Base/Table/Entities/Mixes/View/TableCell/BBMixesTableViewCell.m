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

@interface BBMixesTableViewCell()

@property (nonatomic, strong) IBOutlet UIImageView *infoImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *infoImageViewWidthConstraint;

@property (nonatomic, strong) IBOutlet UIImageView *playingImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *playingImageViewWidthConstraint;

@end


@implementation BBMixesTableViewCell

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
            self.detailLabel.textColor = [UIColor colorWithHEX:0x8A8A8AFF];
            
            break;
        }
            
        default:
            break;
    }
    
    self.label.font = [BBFont boldFontLikeFont:self.label.font];
    self.detailLabel.font = [BBFont fontLikeFont:self.detailLabel.font];
    
    [self setPaused:YES];
}

- (UILabel *)textLabel
{
    return self.label;
}

- (UILabel *)detailTextLabel
{
    return self.detailLabel;
}

- (void)setMixState:(BBMixesTableViewCellState)mixState
{
    _mixState = mixState;
    
    BBThemeManager *themeManager = [BBThemeManager defaultManager];
    
    if (self.infoImageView)
    {
        UIImage *image = nil;
        NSString *imageName = nil;
        
        switch (mixState)
        {
            case BBMixesTableViewCellStateNew:
                imageName = @"new_mix";
                break;
                
            case BBMixesTableViewCellStateFavorite:
                imageName = @"favorite";
                break;
                
            default:
                break;
        }
        
        if (imageName)
        {
            imageName = [@"table_view/cell" stringByAppendingPathComponent:imageName];
            image = [themeManager imageNamed:imageName];
        }
        
        self.infoImageView.image = image;
        self.infoImageViewWidthConstraint.constant = image ? image.size.width + 4.f : 0.f;
    }
    
    if (self.playingImageView)
    {
        NSString *imageName = [@"table_view/cell" stringByAppendingPathComponent:@"now_playing_icon"];
        UIImage *image = [themeManager imageNamed:imageName];
        self.playingImageView.image = image;
        self.playingImageViewWidthConstraint.constant = image ? image.size.width + 5.f : 0.f;

    }
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    
    if (self.playingImageView)
    {
        CGFloat playingImageViewWidth = 0.f;
        
        if (!paused && self.playingImageView.image)
        {
            playingImageViewWidth = self.playingImageView.image.size.width + 5.f;
        }
        
        self.playingImageViewWidthConstraint.constant = playingImageViewWidth;
        self.playingImageView.hidden = paused;
        [self.contentView setNeedsLayout];
    }
}

#pragma mark - Actions

- (IBAction)buttonPressed
{    
    self.paused = (self.paused == NO);
    
    [self.delegate mixesTableViewCell:self paused:self.paused];
}

@end
