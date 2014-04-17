//
//  BBNowPlayingViewController.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBViewController.h"


@class BBMix;

@interface BBNowPlayingViewController : BBViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *fullTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *favoritesButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UITextView *tracklistTextView;

-(IBAction)playClick:(id)sender;
-(IBAction)prevClick:(id)sender;
-(IBAction)nextClick:(id)sender;
-(IBAction)favoritesClick:(id)sender;

-(IBAction)sliderTouchDown:(id)sender;
-(IBAction)sliderTouchUp:(id)sender;

-(IBAction)sliderValueChanged:(UISlider *)slider;

@end
