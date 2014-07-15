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
    
    @IBOutlet var slider : UISlider;
    @IBOutlet var currentTimeLabel : UILabel;
    @IBOutlet var remainingTimeLabel : UILabel;
    
    @IBOutlet var favoriteNotificationTopConstraint : NSLayoutConstraint;
    @IBOutlet var favoriteNotificationView : UIView;
    @IBOutlet var favoriteNotificationLabel : UILabel;
    
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

        self.title = "NOW PLAYING";
    }
    
    override func updateTheme()
    {
        super.updateTheme();
        
        self.showNowPlayingBarButtonItem();
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
                self.slider.maximumTrackTintColor = UIColor(HEX: 0xCCCCCCFF);
        }

        let tm = BBThemeManager.defaultManager();
        
        let thumbImageNormalName = "controls/slider";

        if let image = tm.imageNamed(thumbImageNormalName)
        {
            self.slider.setThumbImage(image, forState: UIControlState.Normal);
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
        BBAudioManager.defaultManager().togglePlayPause();
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
        let shouldFavorite = (BBAudioManager.defaultManager().mix.favoriteDate == nil);

        if (shouldFavorite)
        {
            self.favoritesButton.selected = true;
            BBAudioManager.defaultManager().mix.favoriteDate = NSDate.date();
        }
        else
        {
            self.favoritesButton.selected = false;
            BBAudioManager.defaultManager().mix.favoriteDate = nil;
        }
        
        let selfVar = self;
        
        if (shouldFavorite)
        {
            selfVar.favoriteNotificationTopConstraint.constant = 0.0;
            
            UIView.animateWithDuration(0.2, animations:
            {
                selfVar.view.layoutIfNeeded();
            },
            completion:
            {
                (finished: Bool) in
                
                if (finished)
                {
                    selfVar.favoriteNotificationTopConstraint.constant = -selfVar.favoriteNotificationView.bounds.size.height;
                    
                    UIView.animateWithDuration(0.2, delay: 1.0, options: UIViewAnimationOptions.LayoutSubviews, animations:
                    {
                        selfVar.view.layoutIfNeeded();
                    }, completion:nil);
                }
            });
        }
    }
    
    func refreshTimerFired(aTimer : NSTimer)
    {
        refreshTimeInfo();
    }
    
    func refreshMainTimeInfo()
    {
        let audioManager = BBAudioManager.defaultManager();
        let currentMix = audioManager.mix;
        
        self.playButton.selected = !audioManager.paused;
        
        self.currentTimeLabel.text = BBUIUtils.timeStringFromTime(audioManager.currentTime());
    }

    func refreshTimeInfo()
    {
        let audioManager = BBAudioManager.defaultManager();
        let currentMix = audioManager.mix;
        
        self.refreshMainTimeInfo();
        
        self.remainingTimeLabel.text = BBUIUtils.timeStringFromTime(audioManager.duration());
        
        if (self.slider)
        {
            self.slider.value = audioManager.progress;
        }
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
            
            self!.favoritesButton.selected = (currentMix.favoriteDate != nil);
        
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
            
                self.favoriteNotificationLabel.textColor = UIColor.whiteColor();
                self.favoriteNotificationView.backgroundColor = UIColor(HEX: 0xF45D5DFF);
        }
    
        self.titleLabel.font = BBFont.boldFontLikeFont(self.titleLabel.font);
        self.tagsLabel.font = BBFont.fontLikeFont(self.tagsLabel.font);
        
        self.favoriteNotificationLabel.font = BBFont.boldFontLikeFont(self.favoriteNotificationLabel.font);
        self.favoriteNotificationLabel.text = NSLocalizedString("Mix Added to Favorites", comment: "").uppercaseString;
    }
    
    override func viewWillAppear(animated : Bool)
    {
        super.viewWillAppear(animated);
    
        self.updateTrackInfo(false);
    
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "refreshTimerFired:", userInfo: nil, repeats: true);
    }
    
    override func viewDidDisappear(animated : Bool)
    {
        super.viewDidDisappear(animated);
    
        self.refreshTimer.invalidate();
        self.refreshTimer = nil;
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
    
        self.refreshMainTimeInfo();
    }
    
    func backBarButtonItemPressed()
    {
        self.navigationController.popViewControllerAnimated(true);
    }
}
