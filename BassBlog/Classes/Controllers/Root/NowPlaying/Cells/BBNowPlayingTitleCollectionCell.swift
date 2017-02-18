//
//  BBNowPlayingTitleCollectionCell.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 1/15/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

protocol BBNowPlayingCollectionProtocol
{
    func refresh()
}

class BBNowPlayingTitleCollectionCell: UICollectionViewCell, BBNowPlayingCollectionProtocol
{
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var tagsLabel : UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        switch (BBThemeManager.default().theme)
        {
            default:
                self.titleLabel!.textColor = UIColor(hex: 0x333333FF)
                self.tagsLabel!.textColor = UIColor(hex: 0x8A8A8AFF)
        }
        
        self.titleLabel!.font = BBFont.boldFontLike(self.titleLabel!.font)
        self.tagsLabel!.font = BBFont.fontLike(self.tagsLabel!.font)

    }
    
    func refresh()
    {
        let audioManager = BBAudioManager.default()
        let currentMix = audioManager?.mix
        
        self.titleLabel.text = currentMix?.name.uppercased()
        self.tagsLabel.text = BBUIUtils.tagsString(for: currentMix)
    }
}
