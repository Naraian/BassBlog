//
//  BBNowPlayingTrackListCollectionCell.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 1/15/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

class BBNowPlayingTrackListCollectionCell: UICollectionViewCell, BBNowPlayingCollectionProtocol
{
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var tagsLabel : UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
//        switch (BBThemeManager.defaultManager().theme)
//        {
//            default:
//                self.titleLabel!.textColor = UIColor(HEX: 0x333333FF)
//                self.tagsLabel!.textColor = UIColor(HEX: 0x8A8A8AFF)
//        }
//        
//        self.titleLabel!.font = BBFont.boldFontLikeFont(self.titleLabel!.font)
//        self.tagsLabel!.font = BBFont.fontLikeFont(self.tagsLabel!.font)

    }
    
    func refresh()
    {
//        let audioManager = BBAudioManager.defaultManager()
//        let currentMix = audioManager.mix
//        
//        self.titleLabel.text = currentMix.name.uppercaseString
//        self.tagsLabel.text = BBUIUtils.tagsStringForMix(currentMix)
    }
}
