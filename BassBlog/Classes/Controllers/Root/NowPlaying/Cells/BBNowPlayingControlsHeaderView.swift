//
//  BBNowPlayingControlsHeaderView.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 1/15/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

protocol BBNowPlayingControlsHeaderViewDelegate : NSObjectProtocol
{
    func nowPlatingControlsHeaderView(_ headerView : BBNowPlayingControlsHeaderView, didFavoriteMix mix : BBMix)
}

class BBNowPlayingControlsHeaderView: UICollectionReusableView, BBNowPlayingCollectionProtocol
{
    @IBOutlet var prevButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var favoritesButton : UIButton!
    
    weak var delegate : BBNowPlayingControlsHeaderViewDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let tm = BBThemeManager.default()
        
        self.prevButton!.setImage(tm?.imageNamed("player_previous_mix"), for: UIControlState())
        self.prevButton!.setImage(tm?.imageNamed("player_previous_mix_pressed"), for: UIControlState.highlighted)
        
        self.nextButton!.setImage(tm?.imageNamed("player_next_mix"), for: UIControlState())
        self.nextButton!.setImage(tm?.imageNamed("player_next_mix_pressed"), for: UIControlState.highlighted)
        
        self.playButton!.setImage(tm?.imageNamed("player_play"), for: UIControlState())
        self.playButton!.setImage(tm?.imageNamed("player_play_pressed"), for: UIControlState.highlighted)
        self.playButton!.setImage(tm?.imageNamed("player_pause"), for: UIControlState.selected)
        self.playButton!.setImage(tm?.imageNamed("player_pause_pressed"), for: [UIControlState.highlighted, UIControlState.selected])
        
        self.favoritesButton!.setImage(tm?.imageNamed("add_to_favorites"), for: UIControlState())
        self.favoritesButton!.setImage(tm?.imageNamed("add_to_favorites_selected"), for: UIControlState.selected)
    }
    
    func refresh()
    {
        let audioManager = BBAudioManager.default()
        let currentMix = audioManager?.mix
        
        self.playButton.isSelected = !(audioManager?.paused)!
        self.favoritesButton.isSelected = (currentMix?.favoriteDate != nil)
    }
    
    @IBAction func playClick(_ sender : AnyObject)
    {
        BBAudioManager.default().togglePlayPause()
    }
    
    @IBAction func prevClick(_ sender : AnyObject)
    {
        BBAudioManager.default().playPrev()
    }
    
    @IBAction func nextClick(_ sender : AnyObject)
    {
        BBAudioManager.default().playNext()
    }
    
    @IBAction func favoritesClick(_ sender : AnyObject)
    {
        let currentMix = BBAudioManager.default().mix
        let shouldFavorite = (currentMix?.favoriteDate == nil)
        
        if (shouldFavorite)
        {
            self.favoritesButton.isSelected = true
            BBAudioManager.default().mix.favoriteDate = Date()
            
            if let mixName = currentMix?.name
            {
                Flurry.logEvent("mix_favorited", withParameters: ["mix_name" : mixName])
            }
        }
        else
        {
            self.favoritesButton.isSelected = false
            BBAudioManager.default().mix.favoriteDate = nil
        }
        
        if (shouldFavorite)
        {
            self.delegate?.nowPlatingControlsHeaderView(self, didFavoriteMix: currentMix!)
        }
    }
}
