//
//  BBNowPlayingViewController.m
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBNowPlayingViewController.h"

#import "BBRootViewController.h"
#import "BBAppDelegate.h"

#import "BBThemeManager.h"
#import "BBMix.h"

//#import "Player.h"
#import "BBAudioManager.h"

#import "BBUIUtils.h"
#import "BBFont.h"
#import "UIColor+HEX.h"

@interface BBNowPlayingViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation BBNowPlayingViewController

- (void)commonInit
{
    [super commonInit];
    
    [self showBackBarButtonItem];
    
    self.title = @"NOW PLAYING";
}

//static NSRegularExpression *tracksRegularExpression = nil;
//static NSRegularExpression *tracksDelimiterRegularExpression = nil;
//
//+ (void)setupTracksRegularExpressions
//{
//    if (!tracksRegularExpression)
//    {
//        NSError *__autoreleasing error = nil;
//        tracksRegularExpression =
//        [[NSRegularExpression alloc] initWithPattern:@"^\\d+\\W*\\d*\\W*"
//                                             options:NSRegularExpressionCaseInsensitive
//                                               error:&error];
//        if (error)
//        {
//            ERR(@"Couldn't create regular expression due (%@)", error);
//        }
//    }
//
//    if (!tracksDelimiterRegularExpression)
//    {
//        NSError *__autoreleasing error = nil;
//        tracksDelimiterRegularExpression =
//        [[NSRegularExpression alloc] initWithPattern:@"^\\W+"
//                                             options:NSRegularExpressionCaseInsensitive
//                                               error:&error];
//        if (error)
//        {
//            ERR(@"Couldn't create regular expression due (%@)", error);
//        }
//    }
//}


//    enumerateObjectsUsingBlock:^(NSString *track, NSUInteger trackIdx, BOOL *trackStop)
//    {
//        track =
//        [track stringByTrimmingCharactersInSet:
//         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//        NSRange range = NSMakeRange(0, track.length);
//
//        track =
//        [tracksRegularExpression stringByReplacingMatchesInString:track
//                                                          options:kNilOptions
//                                                            range:range
//                                                     withTemplate:@"$1"];
//
//        range = NSMakeRange(0, track.length);
//
//        if ([tracksDelimiterRegularExpression numberOfMatchesInString:track
//                                                              options:kNilOptions
//                                                                range:range])
//        {
//            return;
//        }
//
//        if (track.length)
//        {
//            [orderedSet addObject:track];
//        }
//    }];

#pragma mark - View

-(void)setImage:(NSString*) imageName toImageView:(UIImageView*)imageView
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    NSString *imageName1 = [@"controls/" stringByAppendingString:imageName];
    
    imageView.image  = [tm imageNamed:imageName1];
    //  [self.slider setMinimumTrackImage:[tm imageNamed:imageName] forState:UIControlStateNormal];
}

-(void) setImage:(NSString*) imageName toButton:(UIButton*)button
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    NSString *imageName1 = [@"controls/" stringByAppendingString:imageName];
    [button setImage:[tm imageNamed:imageName1] forState:UIControlStateNormal];
    
    if ([imageName isEqualToString:@"player_play"])
    {
        NSString *imageName2 = [@"controls/" stringByAppendingString:@"player_pause"];
        [button setImage:[tm imageNamed:imageName2] forState:UIControlStateSelected];
    }
    
    if ([imageName isEqualToString:@"add_to_favorites"])
    {
        NSString *imageName2 = [@"controls/" stringByAppendingString:@"add_to_favorites_selected"];
        [button setImage:[tm imageNamed:imageName2] forState:UIControlStateSelected];
    }
}


- (void)customizeSlider
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    NSString *imageName = @"other/slider_line_selected";
    NSString *imageName2 = @"other/slider_line_not_selected";
    NSString *imageName3 = @"other/slider_big_circle";
    
    [self.slider setMinimumTrackImage:[tm imageNamed:imageName] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[tm imageNamed:imageName2] forState:UIControlStateNormal];
    [self.slider setThumbImage:[tm imageNamed:imageName3] forState:UIControlStateNormal];
    [self.slider setThumbImage:[tm imageNamed:imageName3] forState:UIControlStateHighlighted];
}

-(void) customizeButtons
{
    [self setImage:@"player_next_mix" toButton:self.nextButton];
    [self setImage:@"player_previous_mix" toButton:self.prevButton];
    [self setImage:@"player_play" toButton:self.playButton];
    [self setImage:@"add_to_favorites" toButton:self.favoritesButton];
}

-(IBAction)playClick:(id)sender
{
    //  if ([BBAudioManager defaultManager].paused)
    [[BBAudioManager defaultManager] togglePlayPause];
}

-(IBAction)prevClick:(id)sender
{
    [[BBAudioManager defaultManager] playPrev];
}

-(IBAction)nextClick:(id)sender
{
    [[BBAudioManager defaultManager] playNext];
}

-(IBAction)favoritesClick:(id)sender
{
    BOOL wasFavorited = [BBAudioManager defaultManager].mix.favorite;
    self.favoritesButton.selected = wasFavorited;
    
    [BBAudioManager defaultManager].mix.favorite = !wasFavorited;
}

- (void)customizeTrackInfo
{
    BBMix *mix = [BBAudioManager defaultManager].mix;
    
    self.titleLabel.text = [mix.name uppercaseString];
    self.tagsLabel.text = [BBUIUtils tagsStringForMix:mix];
    
    [self setArtworkImage:nil];
    
    [self updateTrackInfo];
}

- (void)setArtworkImage:(UIImage *)artworkImage
{
    if (!artworkImage)
    {
        artworkImage = [BBUIUtils defaultImage];
    }
    
    self.artworkImageView.image = artworkImage;
}

- (void)refreshTimerFired:(NSTimer *)aTimer
{
    [self updateTrackInfo];
}

- (void)updateTrackInfo
{
    BBAudioManager *audioManager = [BBAudioManager defaultManager];
    
    self.currentTimeLabel.text = [self.class timeStringFromTime:audioManager.currentTime];
    self.remainingTimeLabel.text = [self.class timeStringFromTime:audioManager.currentTimeLeft];
    
    self.slider.value = audioManager.progress;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeSlider];
    [self customizeButtons];
    
    switch ([BBThemeManager defaultManager].theme)
    {
        default:
        {
            self.titleLabel.textColor = [UIColor colorWithHEX:0x333333FF];
            self.tagsLabel.textColor = [UIColor colorWithHEX:0x8A8A8AFF];
            
            self.currentTimeLabel.textColor = [UIColor blackColor];
            self.remainingTimeLabel.textColor = [UIColor blackColor];
            
            break;
        }
    }
    
    self.titleLabel.font = [BBFont boldFontLikeFont:self.titleLabel.font];
    self.tagsLabel.font = [BBFont fontLikeFont:self.tagsLabel.font];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self customizeTrackInfo];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(refreshTimerFired:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)showBackBarButtonItem
{
    //    NSString *title = NSLocalizedString(@"Back",
    //                                       @"Back bar button item title.");
    
    self.navigationItem.leftBarButtonItem =  [self barButtonItemWithImageName:@"back"
                                                                     selector:@selector(backBarButtonItemPressed)];
    
    
    /*  self.navigationItem.leftBarButtonItem =
     [[UIBarButtonItem alloc] initWithTitle:title
     style:UIBarButtonItemStyleBordered
     target:self
     action:@selector(backBarButtonItemPressed)];*/
}

-(IBAction)sliderTouchDown:(id)sender
{
    if (![BBAudioManager defaultManager].paused)
    {
        [[BBAudioManager defaultManager] togglePlayPause];
    }
    
    //  self.sliderTouched = YES;
}

-(IBAction)sliderTouchUp:(id)sender
{
    ///  if (self.sliderTouched)
    //  {
    //    [AudioPlayer pause];
    
    if ([BBAudioManager defaultManager].paused)
    {
        [[BBAudioManager defaultManager] togglePlayPause];
    }
    
    //  [AudioPlayer sliderChangedValueDidEnd:sender];
    //    [AudioPlayer sliderChangedValue:sender];
    //    [AudioPlayer play];
    //    [AudioPlayer playSongWithMix:self.mix];
    //  }
    
    //  self.sliderTouched = NO;
    
}

-(IBAction)sliderValueChanged:(UISlider *)slider
{
    [BBAudioManager defaultManager].progress = slider.value;
    
    [self updateTrackInfo];
}

#pragma mark - Actions

- (void)backBarButtonItemPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Date formatters

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return _dateFormatter;
}

+ (NSString *)timeStringFromTime:(CMTime)time
{
    NSUInteger dTotalSeconds = CMTimeGetSeconds(time);
    
    if (!CMTIME_IS_NUMERIC(time))
    {
        return nil;
    }
    
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    return [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
}

@end
