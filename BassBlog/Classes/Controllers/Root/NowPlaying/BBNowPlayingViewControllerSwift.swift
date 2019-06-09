//
//  BBNowPlayingViewControllerSwift.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/3/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

import UIKit

class BBNowPlayingViewControllerSwift: BBViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var tagsLabel: UILabel!

    @IBOutlet private var slider: UISlider!
    @IBOutlet private var currentTimeLabel: UILabel!
    @IBOutlet private var remainingTimeLabel: UILabel!

    @IBOutlet private var favoriteNotificationTopConstraint: NSLayoutConstraint!
    @IBOutlet private var favoriteNotificationView: UIView!
    @IBOutlet private var favoriteNotificationLabel: UILabel!

    @IBOutlet private var prevButton: UIButton!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var favoritesButton: UIButton!

    @IBOutlet private var artworkImageView: UIImageView!

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private var refreshTimer: Timer?

    override func commonInit() {
        super.commonInit()

        self.title = "NOW PLAYING"
    }

    override func updateTheme() {
        super.updateTheme()

        self.showNowPlayingBarButtonItem()
    }

    override func startObserveNotifications() {
        self.add(#selector(audioManagerDidStartPlayNotification), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStartPlay.rawValue)
        self.add(#selector(audioManagerDidStopNotification(_:)), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStop.rawValue)
        self.add(#selector(audioManagerDidChangeMixNotification), forNotificationWithName: NSNotification.Name.BBAudioManagerDidChangeMix.rawValue)
    }

    // MARK: Notiifcations
    @objc private func audioManagerDidStartPlayNotification() {
    }

    @objc private func audioManagerDidStopNotification(_ notification: NSNotification) {
    }

    @objc private func audioManagerDidChangeMixNotification() {
        updateTrackInfo(animated: true)
    }
    
    // MARK: Customize UI

    func customizeSlider() {
        switch (BBThemeManager.default().theme) {
            default:
                self.slider.minimumTrackTintColor = UIColor(hex: 0xF45D5DFF)
                self.slider.maximumTrackTintColor = UIColor(hex: 0xCCCCCCFF)
        }

        let tm = BBThemeManager.default()!
        let thumbImageNormalName = "controls/slider"

        if let image = tm.imageNamed(thumbImageNormalName) {
            self.slider.setThumbImage(image, for: .normal)
        }
    }

    func customizeButtons() {
        let tm = BBThemeManager.default()!

        self.prevButton.setImage(tm.imageNamed("controls/player_previous_mix"), for: .normal)
        self.prevButton.setImage(tm.imageNamed("controls/player_previous_mix_pressed"), for: .highlighted)

        self.nextButton.setImage(tm.imageNamed("controls/player_next_mix"), for: .normal)
        self.nextButton.setImage(tm.imageNamed("controls/player_next_mix_pressed"), for: .highlighted)

        self.playButton.setImage(tm.imageNamed("controls/player_play"), for: .normal)
        self.playButton.setImage(tm.imageNamed("controls/player_play_pressed"), for: .highlighted)
        self.playButton.setImage(tm.imageNamed("controls/player_pause"), for: .selected)
        self.playButton.setImage(tm.imageNamed("controls/player_pause_pressed"), for: [.highlighted, .selected])

        self.favoritesButton.setImage(tm.imageNamed("controls/add_to_favorites"), for: .normal)
        self.favoritesButton.setImage(tm.imageNamed("controls/add_to_favorites_selected"), for: .selected)
    }
    
    func refreshMainTimeInfo() {
        let audioManager = BBAudioManager.default()
        
        self.playButton.isSelected = audioManager.paused
        self.currentTimeLabel.text = BBUIUtils.timeString(fromTime: audioManager.currentTime())
    }

    func refreshTimeInfo() {
        let audioManager = BBAudioManager.default()

        self.refreshMainTimeInfo()

        self.remainingTimeLabel.text = BBUIUtils.timeString(fromTime: audioManager.duration())

        self.slider.value = audioManager.progress
    }

    func updateTrackInfo(animated: Bool) {
        UIView.transition(with: self.view, duration: animated ? 0.25 : 0.0, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let audioManager = BBAudioManager.default()
            let currentMix = audioManager.mix
        
            strongSelf.titleLabel.text = currentMix.name.uppercased()
            strongSelf.tagsLabel.text = BBUIUtils.tagsString(for: currentMix)
            strongSelf.favoritesButton.isSelected = (currentMix.favoriteDate != nil)
            
            if let imageURL = URL(string: currentMix.imageUrl) {
                strongSelf.artworkImageView.setImageWith(imageURL, placeholderImage: BBUIUtils.defaultImage())
            }
            
            strongSelf.refreshTimeInfo()
        },
        completion: { (finished: Bool) in
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customizeSlider()
        self.customizeButtons()

        switch (BBThemeManager.default().theme) {
            default:
                self.titleLabel.textColor = UIColor(hex: 0x333333FF)
                self.tagsLabel.textColor = UIColor(hex: 0x8A8A8AFF)

                self.currentTimeLabel.textColor = UIColor.black
                self.remainingTimeLabel.textColor = UIColor.black

                self.favoriteNotificationLabel.textColor = UIColor.white
                self.favoriteNotificationView.backgroundColor = UIColor(hex: 0xF45D5DFF)
        }

        self.titleLabel.font = BBFont.boldFontLike(self.titleLabel.font)
        self.tagsLabel.font = BBFont.fontLike(self.tagsLabel.font)

        self.favoriteNotificationLabel.font = BBFont.boldFontLike(self.favoriteNotificationLabel.font)
        self.favoriteNotificationLabel.text = NSLocalizedString("Mix Added to Favorites", comment: "").uppercased()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateTrackInfo(animated: false)

        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] (timer) in
            self?.refreshTimeInfo()
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    // MARK: IBActions
    
    @IBAction private func playClick() {
        BBAudioManager.default().togglePlayPause()
    }
    
    @IBAction private func prevClick() {
        BBAudioManager.default().playPrev()
    }
    
    @IBAction private func nextClick() {
        BBAudioManager.default().playNext()
    }
    
    @IBAction private func favoritesClick() {
        let audioManager = BBAudioManager.default()
        let currentMix = audioManager.mix
        let shouldFavorite = (currentMix.favoriteDate == nil)
        
        if (shouldFavorite) {
            self.favoritesButton.isSelected = true
            audioManager.mix.favoriteDate = Date()
            
            if let mixName = currentMix.name {
                Flurry.logEvent("mix_favorited", withParameters: ["mix_name" : mixName])
            }
        } else {
            self.favoritesButton.isSelected = false
            audioManager.mix.favoriteDate = nil
        }
        
        if (shouldFavorite) {
            self.favoriteNotificationTopConstraint.constant = 0.0

            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            },
            completion: { (finished: Bool) in
                guard (finished) else {
                    return
                }

                self.favoriteNotificationTopConstraint.constant = -self.favoriteNotificationView.bounds.size.height

                UIView.animate(withDuration: 0.2, delay: 1.0, options: .layoutSubviews, animations: {
                    self.view.layoutIfNeeded()
                }, completion:nil)
            })
        }
    }

    @IBAction private func sliderTouchDown() {
        let audioManager = BBAudioManager.default()
        
        if (!audioManager.paused) {
            audioManager.togglePlayPause()
        }

        //  self.sliderTouched = YES
    }

    @IBAction private func sliderTouchUp() {
        let audioManager = BBAudioManager.default()
        
        ///  if (self.sliderTouched)
        //  {
        //    [AudioPlayer pause]

        if (audioManager.paused) {
            audioManager.togglePlayPause()
        }

        //  [AudioPlayer sliderChangedValueDidEnd:sender]
        //    [AudioPlayer sliderChangedValue:sender]
        //    [AudioPlayer play]
        //    [AudioPlayer playSongWithMix:self.mix]
        //  }

        //  self.sliderTouched = NO
    }

    @IBAction private func sliderValueChanged() {
        let audioManager = BBAudioManager.default()
        
        audioManager.progress = slider.value

        self.refreshMainTimeInfo()
    }
}
