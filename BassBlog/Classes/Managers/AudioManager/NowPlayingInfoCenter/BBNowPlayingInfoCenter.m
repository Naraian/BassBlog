//
//  BBNowPlayingInfoCenter.m
//  BassBlog
//
//  Created by Evgeny Sivko on 23.02.14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBNowPlayingInfoCenter.h"

#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <UIImageView+AFNetworking.h>

#import "BBMix.h"

#import "BBUIUtils.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+ProportionalFill.h"


@interface BBNowPlayingInfoCenter ()

@property (nonatomic, strong) MPMediaItemArtwork *artwork;

@end

@implementation BBNowPlayingInfoCenter

- (void)setMix:(BBMix *)mix
{
    if (_mix == mix)
    {
        return;
    }
    
    _mix = mix;
    
    if (self.mix)
    {
        [self setImageWithURL:[NSURL URLWithString:self.mix.imageUrl] placeholderImage:[BBUIUtils defaultImage]];
    }
}

- (void)setPlaybackDuration:(NSTimeInterval)playbackDuration
{
    _playbackDuration = playbackDuration;
    
    [self updateInfo];
}

- (void)setElapsedTime:(NSTimeInterval)elapsedTime
{
    _elapsedTime = elapsedTime;
    
    [self updateInfo];
}

- (void)setImage:(UIImage *)image
{
    [self setArtworkImage:image];
}

- (void)setArtworkImage:(UIImage *)artworkImage
{
    _artwork = [[MPMediaItemArtwork alloc] initWithImage:artworkImage];

    [self updateInfo];
}

- (NSDictionary *)nowPlayingInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    if (self.artwork)
    {
        info[MPMediaItemPropertyArtwork] = self.artwork;
    }
    
    info[MPMediaItemPropertyTitle] = self.mix.name;
    info[MPMediaItemPropertyPlaybackDuration] = @(self.playbackDuration);
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.elapsedTime);
    info[MPNowPlayingInfoPropertyPlaybackRate] = @(1.0);
    
    return info;
}

- (void)updateInfo
{
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = [self nowPlayingInfo];
}

@end
