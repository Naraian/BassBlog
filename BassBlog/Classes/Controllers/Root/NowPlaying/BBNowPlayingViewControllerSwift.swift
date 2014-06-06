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
    }
    
    func audioManagerDidStartPlayNotification()
    {
//warning TOOD 15/05/2014
    //    [self updateNowPlayingCellAndSelectRow:YES];
    }
    
    func audioManagerDidStopNotification(notification : NSNotification)
    {
//warning TOOD 15/05/2014
    //    BBAudioManagerStopReason reason =
    //    [notification.userInfo[BBAudioManagerStopReasonKey] integerValue];
    //
    //    [self updateNowPlayingCellAndSelectRow:reason != BBAudioManagerWillChangeMix];
    }
    
    func setImage(imageName : NSString, toImageView imageView : UIImageView)
    {
        let tm = BBThemeManager.defaultManager();
    
        let imageName1 = "controls/" + imageName;
    
        imageView.image  = tm.imageNamed(imageName1);
    //  [self.slider setMinimumTrackImage:[tm imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    func setImage(imageName : NSString, toButton button : UIButton)
    {
        let tm = BBThemeManager.defaultManager();
        
        let imageNameNormal = "controls/" + imageName;
        let normalImage = tm.imageNamed(imageNameNormal);
        
        let imageNameHighlighted = imageNameNormal + "_pressed";
        var highlightedImage = tm.imageNamed(imageNameHighlighted);
        
        if (imageName == "player_play")
        {
            let imageName2Normal = "controls/player_pause";
            button.setImage(tm.imageNamed(imageName2Normal), forState: UIControlState.Selected);
        
            let imageName2Highlighted = imageName2Normal + "_pressed";
            button.setImage(tm.imageNamed(imageName2Highlighted), forState: UIControlState.Selected | UIControlState.Highlighted);
        }
        else if (imageName == "add_to_favorites")
        {
            let selectedAddition = "_selected";
            let imageName2 = imageName + selectedAddition;
            
            let selectedImage = tm.imageNamed(imageName2);
            button.setImage(selectedImage, forState: UIControlState.Selected);
            highlightedImage = selectedImage;
        }
        
        button.setImage(normalImage, forState: UIControlState.Normal);
        button.setImage(highlightedImage, forState: UIControlState.Highlighted);        
    }
    
    func customizeSlider()
    {
        let tm = BBThemeManager.defaultManager();
        
        let imageName1 = "other/slider_line_selected";
        let imageName2 = "other/slider_line_not_selected";
        let imageName3 = "other/slider_big_circle";

        if let image1 = tm.imageNamed(imageName1)
        {
            self.slider.setMinimumTrackImage(image1, forState: UIControlState.Normal);
        }
        
        if let image2 = tm.imageNamed(imageName2)
        {
            self.slider.setMaximumTrackImage(image2, forState: UIControlState.Normal);
        }
        
        if let image3 = tm.imageNamed(imageName3)
        {
            self.slider.setThumbImage(image3, forState: UIControlState.Normal);
        }
    }
    
    func customizeButtons()
    {
        self.setImage("player_next_mix", toButton: self.nextButton);
        self.setImage("player_previous_mix", toButton: self.prevButton);
        self.setImage("player_play", toButton: self.playButton);
        self.setImage("add_to_favorites", toButton: self.favoritesButton);
    }

    func playClick(sender : AnyObject)
    {
    //  if ([BBAudioManager defaultManager].paused)
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
        let wasFavorited = BBAudioManager.defaultManager().mix.favorite;

        self.favoritesButton.selected = wasFavorited;
    
        BBAudioManager.defaultManager().mix.favorite = !wasFavorited;
    }
    
    func customizeTrackInfo()
    {
        let mix = BBAudioManager.defaultManager().mix;
    
        self.titleLabel.text = mix.name.uppercaseString;
        self.tagsLabel.text = BBUIUtils.tagsStringForMix(mix);
    
        setArtworkImage(nil);
    
        updateTrackInfo();
    }
    
    func setArtworkImage(var artworkImage : UIImage!)
    {
        if (!artworkImage)
        {
            artworkImage = BBUIUtils.defaultImage();
        }
    
        self.artworkImageView.image = artworkImage;
    }
    
    func refreshTimerFired(aTimer : NSTimer)
    {
        updateTrackInfo();
    }
    
    func updateTrackInfo()
    {
        let audioManager = BBAudioManager.defaultManager();
        
        println(audioManager);
    
        self.currentTimeLabel.text = self.dynamicType.timeStringFromTime(audioManager.currentTime());
        self.remainingTimeLabel.text = self.dynamicType.timeStringFromTime(audioManager.currentTimeLeft());
        
        println(audioManager!.progress);
    
        if (self.slider)
        {
            self.slider.value = audioManager.progress;
        }
    }
    
    class func timeStringFromTime(time : CMTime) -> NSString?
    {
        let dTotalSeconds = CMTimeGetSeconds(time);
    
        if (!BBCommonUtils.isCMTimeNumberic(time))
        {
            return nil;
        }
    
        let dHours = Int(floor(dTotalSeconds / 3600));
        let dMinutes = Int(floor(dTotalSeconds % 3600 / 60));
        let dSeconds = Int(floor(dTotalSeconds % 3600 % 60));
    
        return "\(dHours):\(dMinutes):\(dSeconds)";
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
    
        self.customizeTrackInfo();
    
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
        self.navigationItem.leftBarButtonItem =  self.barButtonItemWithImageName("back", selector: "backBarButtonItemPressed");
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
    
        self.updateTrackInfo();
    }
    
    func backBarButtonItemPressed()
    {
        self.navigationController.popViewControllerAnimated(true);
    }
}
