//
//  BBNowPlayingViewControllerSwift.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/3/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

import UIKit

class BBNowPlayingViewControllerSwift : BBViewController
{
    @IBOutlet var titleLabel : UILabel;
    @IBOutlet var tagsLabel : UILabel;
    
    @IBOutlet var progressView : BBProgressView;
    @IBOutlet var slider : UISlider;
    @IBOutlet var currentTimeLabel : UILabel;
    @IBOutlet var remainingTimeLabel : UILabel;
    
    @IBOutlet var prevButton : UIButton;
    @IBOutlet var nextButton : UIButton;
    @IBOutlet var playButton : UIButton;
    @IBOutlet var favoritesButton : UIButton;

    @IBOutlet var artworkImageView : UIImageView;
    
    var _dateFormatter : NSDateFormatter!;
    
    func dateFormatter() -> NSDateFormatter
    {
        if (!_dateFormatter)
        {
            _dateFormatter = NSDateFormatter();
            _dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle;
            _dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle;
        }
        
        return _dateFormatter;
    }
    
    var refreshTimer : NSTimer!;
    
    override func commonInit()
    {
        super.commonInit();
        self.showBackBarButtonItem();

        self.title = "NOW PLAYING";
    }
    
    override func startObserveNotifications()
    {
        self.addSelector("audioManagerDidStartPlayNotification", forNotificationWithName: BBAudioManagerDidStartPlayNotification);
        self.addSelector("audioManagerDidStopNotification:", forNotificationWithName: BBAudioManagerDidStopNotification);
        self.addSelector("audioManagerDidChangeMixNotification", forNotificationWithName: BBAudioManagerDidChangeMixNotification);
    }
    
    func audioManagerDidStartPlayNotification()
    {
    }
    
    func audioManagerDidStopNotification(notification : NSNotification)
    {
    }
    
    func audioManagerDidChangeMixNotification()
    {
        updateTrackInfo(true);
    }
    
    func customizeSlider()
    {
        switch (BBThemeManager.defaultManager().theme)
        {
            default:
                self.slider.minimumTrackTintColor = UIColor(HEX: 0xF45D5DFF);
                self.slider.maximumTrackTintColor = UIColor(HEX: 0x666666FF);
        }

        let tm = BBThemeManager.defaultManager();
        
        let thumbImageNormalName = "controls/slider";
        let thumbImagePressedName = "controls/slider_pressed";

        if let image = tm.imageNamed(thumbImageNormalName)
        {
            self.slider.setThumbImage(image, forState: UIControlState.Normal);
        }

        if let image = tm.imageNamed(thumbImagePressedName)
        {
            self.slider.setThumbImage(image, forState: UIControlState.Highlighted);
        }
    }
    
    func customizeButtons()
    {
        let tm = BBThemeManager.defaultManager();
        
        self.prevButton.setImage(tm.imageNamed("controls/player_previous_mix"), forState: UIControlState.Normal);
        self.prevButton.setImage(tm.imageNamed("controls/player_previous_mix_pressed"), forState: UIControlState.Highlighted);
        
        self.nextButton.setImage(tm.imageNamed("controls/player_next_mix"), forState: UIControlState.Normal);
        self.nextButton.setImage(tm.imageNamed("controls/player_next_mix_pressed"), forState: UIControlState.Highlighted);
        
        self.playButton.setImage(tm.imageNamed("controls/player_play"), forState: UIControlState.Normal);
        self.playButton.setImage(tm.imageNamed("controls/player_play_pressed"), forState: UIControlState.Highlighted);
        self.playButton.setImage(tm.imageNamed("controls/player_pause"), forState: UIControlState.Selected);
        self.playButton.setImage(tm.imageNamed("controls/player_pause_pressed"), forState: UIControlState.Highlighted | UIControlState.Selected);
        
        self.favoritesButton.setImage(tm.imageNamed("controls/add_to_favorites"), forState: UIControlState.Normal);
        self.favoritesButton.setImage(tm.imageNamed("controls/add_to_favorites_selected"), forState: UIControlState.Selected);
    }

    func playClick(sender : AnyObject)
    {
        BBAudioManager.defaultManager().paused = false;
    }
    
    func prevClick(sender : AnyObject)
    {
        BBAudioManager.defaultManager().playPrev();
    }
    
    func nextClick(sender : AnyObject)
    {
        BBAudioManager.defaultManager().playNext();
    }
    
    func favoritesClick(sender : AnyObject)
    {
        let shouldFavorite = !BBAudioManager.defaultManager().mix.favorite;

        self.favoritesButton.selected = shouldFavorite;
    
        BBAudioManager.defaultManager().mix.favorite = shouldFavorite;
    }
    
    func refreshTimerFired(aTimer : NSTimer)
    {
        refreshTimeInfo();
    }

    func refreshTimeInfo()
    {
        let audioManager = BBAudioManager.defaultManager();
        let currentMix = audioManager.mix;

        self.currentTimeLabel.text = BBUIUtils.timeStringFromTime(audioManager.currentTime());
        self.remainingTimeLabel.text = BBUIUtils.timeStringFromTime(audioManager.currentTimeLeft());
        
        if (self.slider)
        {
            self.slider.value = audioManager.progress;
        }

        let trackDuration = audioManager.duration() as NSTimeInterval;
        let timeRanges = audioManager.playerItem.loadedTimeRanges as NSValue[];
        var scaledTimeRanges : Array = [];

        for timeRangeValue in timeRanges
        {
            let timeRange = timeRangeValue.CMTimeRangeValue();

            let startSeconds = CMTimeGetSeconds(timeRange.start) as NSTimeInterval;
            let durationSeconds = CMTimeGetSeconds(timeRange.duration) as NSTimeInterval;

            let start = startSeconds/trackDuration;
            let duration = durationSeconds/trackDuration;

            let bbRange = BBRange(location: start, length: duration);

            scaledTimeRanges += bbRange;
        }

        self.progressView.progressRanges = scaledTimeRanges;
    }
    
    func updateTrackInfo(animated : Bool)
    {
        UIView.transitionWithView(self.view, duration: animated ? 0.25 : 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations:
        {
            [weak self] in
            
            let audioManager = BBAudioManager.defaultManager();
            let currentMix = audioManager.mix;
        
            self!.titleLabel.text = currentMix.name.uppercaseString;
            self!.tagsLabel.text = BBUIUtils.tagsStringForMix(currentMix);
            
            self!.favoritesButton.selected = currentMix.favorite;
        
            self!.artworkImageView.setImageWithURL(NSURL.URLWithString(currentMix.imageUrl), placeholderImage:BBUIUtils.defaultImage());

            self!.refreshTimeInfo();
        },
        completion:
        {
            (finished: Bool) in
                
        });
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
    
        self.customizeSlider();
        self.customizeButtons();
    
        switch (BBThemeManager.defaultManager().theme)
        {
            default:
                self.titleLabel.textColor = UIColor(HEX: 0x333333FF);
                self.tagsLabel.textColor = UIColor(HEX: 0x8A8A8AFF);
                
                self.currentTimeLabel.textColor = UIColor.blackColor();
                self.remainingTimeLabel.textColor = UIColor.blackColor();
        }
    
        self.titleLabel.font = BBFont.boldFontLikeFont(self.titleLabel.font);
        self.tagsLabel.font = BBFont.fontLikeFont(self.tagsLabel.font);
    }
    
    override func viewWillAppear(animated : Bool)
    {
        super.viewWillAppear(animated);
    
        self.updateTrackInfo(false);
    
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshTimerFired:", userInfo: nil, repeats: true);
    }
    
    override func viewDidDisappear(animated : Bool)
    {
        super.viewDidDisappear(animated);
    
        self.refreshTimer.invalidate();
        self.refreshTimer = nil;
    }
    
    func showBackBarButtonItem()
    {
        self.navigationItem.leftBarButtonItem = self.barButtonItemWithImageName("back", selector: "backBarButtonItemPressed");
    }
    
    func sliderTouchDown(sender : AnyObject)
    {
        if (!BBAudioManager.defaultManager().paused)
        {
            BBAudioManager.defaultManager().togglePlayPause();
        }
    
    //  self.sliderTouched = YES;
    }
    
    func sliderTouchUp(sender : AnyObject)
    {
    ///  if (self.sliderTouched)
    //  {
    //    [AudioPlayer pause];
    
        if (BBAudioManager.defaultManager().paused)
        {
            BBAudioManager.defaultManager().togglePlayPause();
        }
    
    //  [AudioPlayer sliderChangedValueDidEnd:sender];
    //    [AudioPlayer sliderChangedValue:sender];
    //    [AudioPlayer play];
    //    [AudioPlayer playSongWithMix:self.mix];
    //  }
    
    //  self.sliderTouched = NO;
    
    }
    
    func sliderValueChanged(slider : UISlider)
    {
        BBAudioManager.defaultManager().progress = slider.value;
    
        self.refreshTimeInfo();
    }
    
    func backBarButtonItemPressed()
    {
        self.navigationController.popViewControllerAnimated(true);
    }
}
