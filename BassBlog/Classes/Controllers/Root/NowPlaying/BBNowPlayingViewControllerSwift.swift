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
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var tagsLabel : UILabel!
    
    @IBOutlet var slider : UISlider!
    @IBOutlet var currentTimeLabel : UILabel!
    @IBOutlet var remainingTimeLabel : UILabel!
    
    @IBOutlet var favoriteNotificationTopConstraint : NSLayoutConstraint!
    @IBOutlet var favoriteNotificationView : UIView!
    @IBOutlet var favoriteNotificationLabel : UILabel!
    
    @IBOutlet var prevButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var favoritesButton : UIButton!

    @IBOutlet var artworkImageView : UIImageView!
    
    lazy var dateFormatter : DateFormatter =
    {
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var refreshTimer : Timer?
    
    override func commonInit()
    {
        super.commonInit()

        self.title = "NOW PLAYING"
    }
    
    override func updateTheme()
    {
        super.updateTheme()
        
        self.showNowPlayingBarButtonItem()
    }
    
    override func startObserveNotifications()
    {
        self.add(#selector(audioManagerDidStartPlayNotification(_:)), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStartPlay)
        self.add(#selector(audioManagerDidStopNotification(_:)), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStop)
        self.add(#selector(audioManagerDidChangeMixNotification(_:)), forNotificationWithName: NSNotification.Name.BBAudioManagerDidChangeMix)
    }
    
    func audioManagerDidStartPlayNotification(_ notification : NSNotification)
    {
    }
    
    func audioManagerDidStopNotification(_ notification : NSNotification)
    {
    }
    
    func audioManagerDidChangeMixNotification(_ notification : NSNotification)
    {
        updateTrackInfo(animated: true)
    }
    
    func customizeSlider()
    {
        switch (BBThemeManager.default().theme)
        {
            default:
                self.slider!.minimumTrackTintColor = UIColor(hex: 0xF45D5DFF)
                self.slider!.maximumTrackTintColor = UIColor(hex: 0xCCCCCCFF)
        }

        let tm = BBThemeManager.default()
        
        let thumbImageNormalName = "slider"

        if let image = tm.imageNamed(thumbImageNormalName)
        {
            self.slider!.setThumbImage(image, for: .normal)
        }
    }
    
    func customizeButtons()
    {
        let tm = BBThemeManager.default()
        
        self.prevButton.setImage(tm.imageNamed("player_previous_mix"), for: .normal)
        self.prevButton.setImage(tm.imageNamed("player_previous_mix_pressed"), for: .highlighted)
        
        self.nextButton.setImage(tm.imageNamed("player_next_mix"), for: .normal)
        self.nextButton.setImage(tm.imageNamed("player_next_mix_pressed"), for: .highlighted)
        
        self.playButton.setImage(tm.imageNamed("player_play"), for: .normal)
        self.playButton.setImage(tm.imageNamed("player_play_pressed"), for: .highlighted)
        self.playButton.setImage(tm.imageNamed("player_pause"), for: .selected)
        self.playButton.setImage(tm.imageNamed("player_pause_pressed"), for: [.highlighted, .selected])
        
        self.favoritesButton.setImage(tm.imageNamed("add_to_favorites"), for: .normal)
        self.favoritesButton.setImage(tm.imageNamed("add_to_favorites_selected"), for: .selected)
    }

    @IBAction private func playClick(_ sender : AnyObject)
    {
        BBAudioManager.default().togglePlayPause()
    }
    
    @IBAction private func prevClick(_ sender : AnyObject)
    {
        BBAudioManager.default().playPrev()
    }
    
    @IBAction private func nextClick(_ sender : AnyObject)
    {
        BBAudioManager.default().playNext()
    }
    
    @IBAction private func favoritesClick(_ sender : AnyObject)
    {
        guard let currentMix = BBAudioManager.default().mix else
        {
            return
        }
        
        let shouldFavorite = (currentMix.favoriteDate == nil)

        if (shouldFavorite)
        {
            self.favoritesButton.isSelected = true
            currentMix.favoriteDate = Date()
            
            if (currentMix.name != nil)
            {
                Flurry.logEvent("mix_favorited", withParameters: ["mix_name" : currentMix.name])
            }
        }
        else
        {
            self.favoritesButton.isSelected = false
            currentMix.favoriteDate = nil
        }
        
        let selfVar = self
        
        if (shouldFavorite)
        {
            selfVar.favoriteNotificationTopConstraint!.constant = 0.0
            
            UIView.animate(withDuration: 0.2, animations:
            {
                selfVar.view.layoutIfNeeded()
            },
            completion:
            {
                (finished: Bool) in
                
                if (finished)
                {
                    selfVar.favoriteNotificationTopConstraint!.constant = -selfVar.favoriteNotificationView!.bounds.size.height
                    
                    UIView.animate(withDuration: 0.2, delay: 1.0, options: .layoutSubviews, animations:
                    {
                        selfVar.view.layoutIfNeeded()
                    }, completion:nil)
                }
            })
        }
    }
    
    @objc private func refreshTimerFired(_ timer : Timer)
    {
        refreshTimeInfo()
    }
    
    func refreshMainTimeInfo()
    {
        let audioManager = BBAudioManager.default()
//        let currentMix = audioManager.mix
        
        self.playButton.isSelected = !audioManager.paused
        
        self.currentTimeLabel.text = BBUIUtils.timeString(fromTime: audioManager.currentTime())
    }

    func refreshTimeInfo()
    {
        let audioManager = BBAudioManager.default()
//        let currentMix = audioManager.mix
        
        self.refreshMainTimeInfo()
        
        self.remainingTimeLabel.text = BBUIUtils.timeString(fromTime: audioManager.duration())
        
        if (self.slider != nil)
        {
            self.slider!.value = audioManager.progress
        }
    }
    
    func updateTrackInfo(animated : Bool)
    {
        UIView.transition(with: self.view, duration: animated ? 0.25 : 0.0, options: .transitionCrossDissolve, animations:
        {
            [weak self] in
            
            guard let strongSelf = self else
            {
                return
            }
            
            let audioManager = BBAudioManager.default()
            let currentMix = audioManager.mix
        
            strongSelf.titleLabel.text = currentMix?.name.uppercased()
            strongSelf.tagsLabel.text = BBUIUtils.tagsString(for: currentMix)
            
            strongSelf.favoritesButton.isSelected = (currentMix?.favoriteDate != nil)
        
            if let imageUrlString = currentMix?.imageUrl,
               let imageUrl = URL(string: imageUrlString)
            {
                strongSelf.artworkImageView.setImageWith(imageUrl, placeholderImage:BBUIUtils.defaultImage())
            }
            else
            {
                strongSelf.artworkImageView.image = BBUIUtils.defaultImage()
            }

            strongSelf.refreshTimeInfo()
        },
        completion:
        {
            (finished: Bool) in
        })
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.customizeSlider()
        self.customizeButtons()
    
        switch (BBThemeManager.default().theme)
        {
            default:
                self.titleLabel.textColor = UIColor(hex: 0x333333FF)
                self.tagsLabel.textColor = UIColor(hex: 0x8A8A8AFF)
                
                self.currentTimeLabel.textColor = UIColor.black
                self.remainingTimeLabel.textColor = UIColor.black
            
                self.favoriteNotificationLabel.textColor = UIColor.white
                self.favoriteNotificationView!.backgroundColor = UIColor(hex: 0xF45D5DFF)
        }
    
        self.titleLabel.font = BBFont.boldFontLike(self.titleLabel.font)
        self.tagsLabel.font = BBFont.fontLike(self.tagsLabel.font)
        
        self.favoriteNotificationLabel.font = BBFont.boldFontLike(self.favoriteNotificationLabel.font)
        self.favoriteNotificationLabel.text = NSLocalizedString("Mix Added to Favorites", comment: "").uppercased()
    }
    
    override func viewWillAppear(_ animated : Bool)
    {
        super.viewWillAppear(animated)
    
        self.updateTrackInfo(animated: false)
    
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshTimerFired(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated : Bool)
    {
        super.viewDidDisappear(animated)
    
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    func sliderTouchDown(sender : AnyObject)
    {
        if (!BBAudioManager.default().paused)
        {
            BBAudioManager.default().togglePlayPause()
        }
    
    //  self.sliderTouched = YES
    }
    
    func sliderTouchUp(sender : AnyObject)
    {
    ///  if (self.sliderTouched)
    //  {
    //    [AudioPlayer pause]
    
        if (BBAudioManager.default().paused)
        {
            BBAudioManager.default().togglePlayPause()
        }
    
    //  [AudioPlayer sliderChangedValueDidEnd:sender]
    //    [AudioPlayer sliderChangedValue:sender]
    //    [AudioPlayer play]
    //    [AudioPlayer playSongWithMix:self.mix]
    //  }
    
    //  self.sliderTouched = NO
    
    }
    
    func sliderValueChanged(slider : UISlider)
    {
        BBAudioManager.default().progress = slider.value
    
        self.refreshMainTimeInfo()
    }
    
    func backBarButtonItemPressed()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
