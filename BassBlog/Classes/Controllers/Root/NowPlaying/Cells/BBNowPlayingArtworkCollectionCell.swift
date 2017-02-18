//
//  BBNowPlayingArtworkCollectionCell.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 1/15/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

class BBNowPlayingArtworkCollectionCell: UICollectionViewCell, BBNowPlayingCollectionProtocol
{
    @IBOutlet var artworkImageView : UIImageView!
    
    func refresh()
    {
        let audioManager = BBAudioManager.default()
        let currentMix = audioManager?.mix
        
        self.artworkImageView.setImageWith(URL(string: (currentMix?.imageUrl)!)!, placeholderImage:BBUIUtils.defaultImage())
    }
}
