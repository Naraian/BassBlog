//
//  BBNowPlayingCollectionViewFlowLayout.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 4/25/16.
//  Copyright © 2016 BassBlog. All rights reserved.
//

import UIKit

class BBNowPlayingCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    fileprivate func itemWidth() -> CGFloat
    {
        return self.collectionView!.frame.width - self.sectionInset.left - self.sectionInset.right
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        guard let collectionView = self.collectionView else
        {
            return proposedContentOffset
        }
        
        let contentOffset : CGPoint
        
        if (velocity.y > 0)
        {
            // Scroll down
            contentOffset = CGPoint(x: 0, y: self.collectionViewContentSize.height - collectionView.frame.size.height)
        }
        else
        {
            // Scroll up
            contentOffset = CGPoint(x: 0, y: -collectionView.contentInset.top)
        }
        
        return contentOffset
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributesInRect = super.layoutAttributesForElements(in: rect) ?? [UICollectionViewLayoutAttributes]()
        
        var headers = [Int : UICollectionViewLayoutAttributes]()
        var lastCells = [Int : UICollectionViewLayoutAttributes]()
        
        // Looking for the attributes of headers, the first and the last cells for each of the section and for the footer view
        for attribute in attributesInRect
        {
            if (attribute.representedElementCategory == .cell)
            {
                // Get the bottom most cell of that section
                var isBottommost = true
                if let lastCellAttribute = lastCells[attribute.indexPath.section]
                {
                    isBottommost = (attribute.indexPath.row > lastCellAttribute.indexPath.row)
                }
                
                if (isBottommost)
                {
                    lastCells[attribute.indexPath.section] = attribute
                }
            }
            else if (attribute.representedElementKind == UICollectionElementKindSectionHeader)
            {
                headers[attribute.indexPath.section] = attribute
            }
        }
        
        // Update the section headers attributes
        
        for (section, _) in lastCells
        {
            let header : UICollectionViewLayoutAttributes?
            
            if let unwrappedHeader = headers[section]
            {
                attributesInRect.removeObject(unwrappedHeader)
                header = unwrappedHeader
            }
            else
            {
                header = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: section))
            }
            
            if let unwrappedHeader = header, !CGSize.zero.equalTo(unwrappedHeader.frame.size)
            {
                self.updateHeaderAttributes(unwrappedHeader, lastCellAttributes:lastCells[section])
                attributesInRect.append(unwrappedHeader)
            }
        }

        return attributesInRect
    }
    
    func updateHeaderAttributes(_ header : UICollectionViewLayoutAttributes, lastCellAttributes : UICollectionViewLayoutAttributes?)
    {
        guard let collectionView = self.collectionView else
        {
            return
        }
        
        header.zIndex = 1024
        header.transform3D = CATransform3DMakeTranslation(0, 0, 1024)
        header.isHidden = false
        
        var sectionMaxY = -header.frame.size.height
        
        if let unwrappedLastCellAttributes = lastCellAttributes
        {
            sectionMaxY += unwrappedLastCellAttributes.frame.maxY
        }
        
        var y = collectionView.bounds.maxY - collectionView.bounds.size.height + collectionView.contentInset.top
        y = min(max(y, header.frame.origin.y), sectionMaxY)
        
        header.frame = CGRect(x: header.frame.origin.x, y: y, width: header.frame.size.width, height: header.frame.size.height)
    }
}
