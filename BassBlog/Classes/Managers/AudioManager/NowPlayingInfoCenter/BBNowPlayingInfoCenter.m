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

#import "BBMix.h"

#import "BBUIUtils.h"


@interface BBNowPlayingInfoCenter ()

@property (nonatomic, strong) MPMediaItemArtwork *artwork;

@end

@implementation BBNowPlayingInfoCenter

- (void)setMix:(BBMix *)mix {
    
    if (_mix == mix) {
        return;
    }
    
    _mix = mix;
    
    _artwork = nil;
    if (self.mix) {
        
#warning TODO: start artwork load here...
    }
    
    [self setArtworkImage:[BBUIUtils defaultImage]];
}

- (void)setArtworkImage:(UIImage *)artworkImage {
    
    if (_artwork) {
        return;
    }
    
    _artwork = [[MPMediaItemArtwork alloc] initWithImage:artworkImage];
    
    [self updateInfo];
}

- (NSDictionary *)nowPlayingInfo {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    info[MPMediaItemPropertyTitle] = self.mix.name;
    
    if (self.artwork) {
        info[MPMediaItemPropertyArtwork] = self.artwork;
    }
    
    return info;
}

- (void)updateInfo {
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = [self nowPlayingInfo];
}

@end
