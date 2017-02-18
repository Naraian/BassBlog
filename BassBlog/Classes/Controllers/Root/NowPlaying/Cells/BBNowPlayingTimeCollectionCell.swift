//
//  BBNowPlayingTimeCollectionCell.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 1/15/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

class BBNowPlayingTimeCollectionCell: UICollectionViewCell, BBNowPlayingCollectionProtocol
{
    @IBOutlet var slider : UISlider!
    @IBOutlet var currentTimeLabel : UILabel!
    @IBOutlet var remainingTimeLabel : UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        switch (BBThemeManager.default().theme)
        {
            default:
                self.slider!.minimumTrackTintColor = UIColor(hex: 0xF45D5DFF)
                self.slider!.maximumTrackTintColor = UIColor(hex: 0xCCCCCCFF)
                self.currentTimeLabel!.textColor = UIColor.black
                self.remainingTimeLabel!.textColor = UIColor.black
        }
        
        if let image = BBThemeManager.default().imageNamed("slider")
        {
            self.slider!.setThumbImage(image, for: UIControlState())
        }
    }
    
    func refresh()
    {
        let audioManager = BBAudioManager.default()
        self.currentTimeLabel.text = BBUIUtils.timeString(fromTime: (audioManager?.currentTime())!)
        self.remainingTimeLabel.text = BBUIUtils.timeString(fromTime: (audioManager?.duration())!)
        self.slider.value = (audioManager?.progress)!
    }

    @IBAction func sliderTouchDown(_ sender : AnyObject)
    {
        if (!BBAudioManager.default().paused)
        {
            BBAudioManager.default().togglePlayPause()
        }
    }
    
    @IBAction func sliderTouchUp(_ sender : AnyObject)
    {
        if (BBAudioManager.default().paused)
        {
            BBAudioManager.default().togglePlayPause()
        }
    }
    
    @IBAction func sliderValueChanged(_ slider : UISlider)
    {
        BBAudioManager.default().progress = slider.value
        
        self.refresh()
    }
}
