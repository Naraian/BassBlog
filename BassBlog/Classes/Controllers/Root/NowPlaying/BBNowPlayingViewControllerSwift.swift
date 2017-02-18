    //
//  BBNowPlayingViewControllerSwift.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/3/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

import UIKit

protocol Row
{
    func cellID() -> String
    func height() -> CGFloat
    
    static func count() -> Int
}

extension Row
{
    func height() -> CGFloat
    {
        return 44
    }
}

open class BBNowPlayingViewControllerSwift : UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, BBNowPlayingControlsHeaderViewDelegate
{
    enum Section: Int
    {
        case titleTime = 0
        case controlsArtwork
        
        static let Count = controlsArtwork.rawValue + 1
        
        func row(atIndex row: Int) -> Row!
        {
            switch self
            {
                case .titleTime:        return SectionTitleTimeRow(rawValue: row)
                case .controlsArtwork:  return SectionControlsArtworkRow(rawValue: row)
            }
        }
        
        func numberOfRows() -> Int
        {
            switch self
            {
                case .titleTime:        return SectionTitleTimeRow.count()
                case .controlsArtwork:  return SectionControlsArtworkRow.count()
            }
        }
        
        func headerID() -> String
        {
            switch self
            {
                case .titleTime:        return Constant.defaultHeaderID
                case .controlsArtwork:  return "controlsHeaderID"
            }
        }
        
        func footerID() -> String
        {
            return "defaultFooterID"
        }
        
        func footerHeight() -> CGFloat
        {
            return 0
        }
    }
    
    enum SectionTitleTimeRow: Int, Row
    {
        case title = 0
        case time
        
        static func count() -> Int { return time.rawValue + 1 }
        
        func cellID() -> String
        {
            switch self
            {
                case .title: return "titleCellID"
                case .time:  return "timeCellID"
            }
        }
        
        func height() -> CGFloat
        {
            switch self
            {
                case .title: return 100
                case .time:  return 100
            }
        }
    }
    
    enum SectionControlsArtworkRow: Int, Row
    {
        case artwork = 0
        case trackList
        
        static func count() -> Int { return trackList.rawValue + 1 }
        
        func cellID() -> String
        {
            switch self
            {
                case .artwork:      return "artworkCellID"
                case .trackList:    return "trackListCellID"
            }
        }
        
        func height() -> CGFloat
        {
            switch self
            {
                case .artwork: return 176
                case .trackList : return 0
            }
        }
    }
    
    fileprivate struct Constant
    {
        static let defaultHeaderID = "defaultHeaderID"
//        static let circleDetailsHeaderOriginalHeight : CGFloat = 170
//        static let circleDetailsHeaderMinHeight : CGFloat = 0
        static let defaultHeaderHeight : CGFloat = 16
        static let controlsHeaderHeight : CGFloat = 44
    }

    @IBOutlet var collectionView : UICollectionView!
    
    var titleCell : BBNowPlayingTitleCollectionCell?
    var timeCell : BBNowPlayingTimeCollectionCell?
    var artworkCell : BBNowPlayingArtworkCollectionCell?
    var trackListCell : BBNowPlayingTrackListCollectionCell?
    
    var controlsHeader : BBNowPlayingControlsHeaderView?
    
    @IBOutlet var favoriteNotificationTopConstraint : NSLayoutConstraint!
    @IBOutlet var favoriteNotificationView : UIView!
    @IBOutlet var favoriteNotificationLabel : UILabel!
    
    var refreshTimer : Timer!
    
    var _dateFormatter : DateFormatter!
    
    func dateFormatter() -> DateFormatter
    {
        if (_dateFormatter == nil)
        {
            _dateFormatter = DateFormatter()
            _dateFormatter.dateStyle = DateFormatter.Style.none
            _dateFormatter.timeStyle = DateFormatter.Style.short
        }
        
        return _dateFormatter
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    open override func commonInit()
    {
        super.commonInit()

        self.title = "NOW PLAYING"
    }
    
    open override func updateTheme()
    {
        super.updateTheme()
        
        self.showNowPlayingBarButtonItem()
    }
    
    open override func startObserveNotifications()
    {
        self.add(#selector(BBNowPlayingViewControllerSwift.audioManagerDidStartPlayNotification), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStartPlay.rawValue)
        self.add(#selector(BBNowPlayingViewControllerSwift.audioManagerDidStopNotification(_:)), forNotificationWithName: NSNotification.Name.BBAudioManagerDidStop.rawValue)
        self.add(#selector(BBNowPlayingViewControllerSwift.audioManagerDidChangeMixNotification), forNotificationWithName: NSNotification.Name.BBAudioManagerDidChangeMix.rawValue)
    }
    
    func audioManagerDidStartPlayNotification()
    {
    }
    
    func audioManagerDidStopNotification(_ notification : Notification)
    {
    }
    
    func audioManagerDidChangeMixNotification()
    {
        self.updateTrackInfo(true)
    }
    
    func refreshTimerFired(_ aTimer : Timer)
    {
        self.refreshTimeInfo()
    }
    
    func refreshTimeInfo()
    {
        self.timeCell?.refresh()
        self.controlsHeader?.refresh()
    }
    
    func updateTrackInfo(_ animated : Bool)
    {
        UIView.transition(with: self.view, duration: animated ? 0.25 : 0.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations:
        {
            for visibleCell in self.collectionView.visibleCells
            {
                if let nowPlayingCell = visibleCell as? BBNowPlayingCollectionProtocol
                {
                    nowPlayingCell.refresh()
                }
            }
            
            self.controlsHeader?.refresh()
        },
        completion:
        {
            (finished: Bool) in
        })
    }
    
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.favoriteNotificationLabel!.font = BBFont.boldFontLike(self.favoriteNotificationLabel!.font)
        self.favoriteNotificationLabel!.text = NSLocalizedString("Mix Added to Favorites", comment: "").uppercased()
    }
    
    open override func viewWillAppear(_ animated : Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = true
    
        self.updateTrackInfo(false)
    
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BBNowPlayingViewControllerSwift.refreshTimerFired(_:)), userInfo: nil, repeats: true)
    }
    
    open override func viewDidDisappear(_ animated : Bool)
    {
        super.viewDidDisappear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = false
    
        self.refreshTimer.invalidate()
        self.refreshTimer = nil
    }
        
    func backBarButtonItemPressed()
    {
        self.navigationController?.popViewController(animated: true)
    }
  
// MARK: Layout management
    
    func updateHeaderLayout()
    {
//        let flowLayout = self.collectionView!.collectionViewLayout as! HCAResizableHeaderFlowLayout
//        flowLayout.originalHeaderHeight = Constant.circleDetailsHeaderOriginalHeight
//        flowLayout.minimalHeaderHeight = Constant.circleDetailsHeaderMinHeight
//        flowLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), Constant.defaultHeaderHeight)
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let section = Section(rawValue: indexPath.section)!
        
        guard (kind == UICollectionElementKindSectionHeader) else
        {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: section.footerID(), for: indexPath)
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: section.headerID(), for: indexPath)
        
        switch section
        {
            case .controlsArtwork:
                guard let controlsHeader = header as? BBNowPlayingControlsHeaderView else
                {
                    fatalError("unexpected cell type")
                }
                
                controlsHeader.delegate = self
                self.controlsHeader = controlsHeader

            default: ()
        }
        
        return header
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let section = Section(rawValue: indexPath.section)!
        let row = section.row(atIndex: indexPath.row)
        
        switch section
        {
            case .titleTime:
                if let titleTimeRow = row as? SectionTitleTimeRow
                {
                }
            
            case .controlsArtwork:
                if let controlsArtworkRow = row as? SectionControlsArtworkRow
                {
                    if (controlsArtworkRow == .trackList)
                    {
                        return CGSize(width: self.view.frame.width, height: self.view.frame.height - SectionControlsArtworkRow.artwork.height() - Constant.controlsHeaderHeight)
                    }
                }
            
            default: ()
        }
        
        return CGSize(width: self.view.frame.width, height: row!.height())
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
//        let flowLayout = self.collectionView!.collectionViewLayout as! HCAResizableHeaderFlowLayout
        
//        let referenceSize = flowLayout.headerReferenceSize
        
        let section = Section(rawValue: section)!
        
        switch section
        {
            case .titleTime:
                return CGSize(width: self.view.frame.width, height: 0)
            
            default: ()
        }
        
        return CGSize(width: self.view.frame.width, height: Constant.controlsHeaderHeight)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        let section = Section(rawValue: section)!
        
        return CGSize(width: self.view.bounds.width, height: section.footerHeight())
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return Section.Count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let section = Section(rawValue: section)!
        
        return section.numberOfRows()
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let section = Section(rawValue: indexPath.section)!
        let row = section.row(atIndex: indexPath.row)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: (row?.cellID())!, for: indexPath)
        
        switch section
        {
            case .titleTime:
                self.configureTitleTimeSectionCell(cell, forRow: row as! SectionTitleTimeRow)
            
            case .controlsArtwork:
                self.configureControlsArtworkSectionCell(cell, forRow: row as! SectionControlsArtworkRow)
        }
        
        if let nowPlayingCell = cell as? BBNowPlayingCollectionProtocol
        {
            nowPlayingCell.refresh()
        }
        
        return cell
    }
    
    fileprivate func configureTitleTimeSectionCell(_ cell: UICollectionViewCell, forRow row : SectionTitleTimeRow)
    {
        switch row
        {
            case .title:
                guard let titleCell = cell as? BBNowPlayingTitleCollectionCell else
                {
                    fatalError("unexpected cell type")
                }
            
                self.titleCell = titleCell
            
            case .time:
                guard let timeCell = cell as? BBNowPlayingTimeCollectionCell else
                {
                    fatalError("unexpected cell type")
                }
                
                self.timeCell = timeCell
        }
    }
    
    fileprivate func configureControlsArtworkSectionCell(_ cell: UICollectionViewCell, forRow row : SectionControlsArtworkRow)
    {
        switch row
        {
            case .artwork:
                guard let artworkCell = cell as? BBNowPlayingArtworkCollectionCell else
                {
                    fatalError("unexpected cell type")
                }
                
                self.artworkCell = artworkCell
            
            case .trackList:
                guard let trackListCell = cell as? BBNowPlayingTrackListCollectionCell else
                {
                    fatalError("unexpected cell type")
                }
                
                self.trackListCell = trackListCell
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let section = Section(rawValue: indexPath.section)!
        let _ = section.row(atIndex: indexPath.row)
        
//        switch section
//        {
//        case .HeaderOnly: () //No actions on cell selection here
//        case .Calendar: () //No actions on cell selection here
//        case .Participants: () //No actions on cell selection here
//        }
    }
    
// MARK: BBNowPlayingControlsHeaderViewDelegate
    
    func nowPlatingControlsHeaderView(_ headerView : BBNowPlayingControlsHeaderView, didFavoriteMix mix : BBMix)
    {
        self.favoriteNotificationTopConstraint!.constant = 0.0
        
        UIView.animate(withDuration: 0.2, animations:
        {
            self.view.layoutIfNeeded()
        },
        completion:
        {
            (finished: Bool) in
            
            if (finished)
            {
                self.favoriteNotificationTopConstraint!.constant = -self.topLayoutGuide.length - self.favoriteNotificationView!.bounds.size.height
                
                UIView.animate(withDuration: 0.2, delay: 1.0, options: UIViewAnimationOptions.layoutSubviews, animations:
                {
                    self.view.layoutIfNeeded()
                }, completion:nil)
            }
        })
    }
}
