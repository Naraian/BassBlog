//
//  BBAllMixesTableViewCell.swift
//  BassBlog
//
//  Created by M Ivaniushchenko on 6/9/19.
//  Copyright © 2019 BassBlog. All rights reserved.
//

import Foundation
import MarqueeLabel

@objc(BBAllMixesTableViewCell)
class BBAllMixesTableViewCell: BBMixesTableViewCell {
    @IBOutlet private var scrollingLabel: MarqueeLabel!
    
    override var label: UILabel! {
        get { return self.scrollingLabel }
        set {}
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollingLabel.trailingBuffer = 30.0
        self.scrollingLabel.animationDelay = 1.0
        self.scrollingLabel.speed = .rate(30.0)
        self.scrollingLabel.textAlignment = .left
        self.scrollingLabel.type = .continuous
        self.scrollingLabel.holdScrolling = false
    }
    
    override var paused: Bool {
        didSet {
            self.scrollingLabel.labelize = self.paused
        }
    }
}
