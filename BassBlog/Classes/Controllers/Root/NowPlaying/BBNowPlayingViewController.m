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
#import "NSObject+Notification.h"

@interface BBNowPlayingViewController ()

@property (nonatomic, strong) NSMutableArray *spectrumViewsArray;
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

- (void)startObserveNotifications {
    
    [super startObserveNotifications];
    
    [self addSelector:@selector(audioManagerDidStartPlayNotification)
    forNotificationWithName:BBAudioManagerDidStartPlayNotification];
    
    [self addSelector:@selector(audioManagerDidStopNotification:)
    forNotificationWithName:BBAudioManagerDidStopNotification];
    
    [self addSelector:@selector(audioManagerDidChangeSpectrumData:) forNotificationWithName:BBAudioManagerDidChangeSpectrumData];
}

- (void)audioManagerDidStartPlayNotification {
#warning TOOD 15/05/2014
//    [self updateNowPlayingCellAndSelectRow:YES];
}

- (void)audioManagerDidStopNotification:(NSNotification *)notification {
#warning TOOD 15/05/2014
//    BBAudioManagerStopReason reason =
//    [notification.userInfo[BBAudioManagerStopReasonKey] integerValue];
//    
//    [self updateNowPlayingCellAndSelectRow:reason != BBAudioManagerWillChangeMix];
}


- (void)audioManagerDidChangeSpectrumData:(NSNotification *)notification
{
    NSArray *spectrumData = [BBAudioManager defaultManager].spectrumData;
    int count = MIN(20.f, spectrumData.count);
    
    if (!self.spectrumViewsArray)
    {
        self.spectrumViewsArray = [NSMutableArray new];
        
        CGFloat x = 0;
        CGFloat width = 320.f / count;
        
        for (int i = 0; i < 20; i++)
        {
            CGRect rect = CGRectMake(x, 0.f, width, 0.f);
            
            UIView *view = [[UIView alloc] initWithFrame:rect];
            view.backgroundColor = [UIColor redColor];
            [self.artworkImageView addSubview:view];
            [self.spectrumViewsArray addObject:view];
            
            x += width;
        }
    }
    
    for (int i = 0; i < count; i++)
    {
        UIView *view = self.spectrumViewsArray[i];
        CGRect frame = view.frame;
        
        NSNumber *value = spectrumData[i];
        CGFloat floatValue = fabs(value.floatValue);
        
        frame.size.height = 1000000.f * floatValue;
        
        view.frame = frame;
    }
}

#pragma mark - View

-(void)setImage:(NSString*) imageName toImageView:(UIImageView*)imageView
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    NSString *imageName1 = [@"controls/" stringByAppendingString:imageName];
    
    imageView.image  = [tm imageNamed:imageName1];
    //  [self.slider setMinimumTrackImage:[tm imageNamed:imageName] forState:UIControlStateNormal];
}

-(void)setImage:(NSString*)imageName toButton:(UIButton*)button
{
    BBThemeManager *tm = [BBThemeManager defaultManager];
    
    NSString *imageNameNormal = [@"controls/" stringByAppendingString:imageName];
    UIImage *normalImage = [tm imageNamed:imageNameNormal];
    
    NSString *imageNameHighlighted = [imageNameNormal stringByAppendingString:@"_pressed"];
    UIImage *highlightedImage = [tm imageNamed:imageNameHighlighted];
    
    if ([imageName isEqualToString:@"player_play"])
    {
        NSString *imageName2Normal = [@"controls/" stringByAppendingString:@"player_pause"];
        [button setImage:[tm imageNamed:imageName2Normal] forState:UIControlStateSelected];
        
        NSString *imageName2Highlighted = [imageName2Normal stringByAppendingString:@"_pressed"];
        [button setImage:[tm imageNamed:imageName2Highlighted] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    
    if ([imageName isEqualToString:@"add_to_favorites"])
    {
        NSString *imageName2 = [imageName stringByAppendingString:@"_selected"];
        
        UIImage *selectedImage = [tm imageNamed:imageName2];
        [button setImage:selectedImage forState:UIControlStateSelected];
        highlightedImage = selectedImage;
    }
         
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
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
    
//    self.currentTimeLabel.text = [self.class timeStringFromTime:audioManager.currentTime];
//    self.remainingTimeLabel.text = [self.class timeStringFromTime:audioManager.currentTimeLeft];
    
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
    self.navigationItem.leftBarButtonItem =  [self barButtonItemWithImageName:@"back"
                                                                     selector:@selector(backBarButtonItemPressed)];
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

@end
