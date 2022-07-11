//
//  STLCollectionViewLeftAlignedLayout.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/19.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

@objc enum STLAlignedLayoutType: Int {
    case HorizontalLeft = 0
    case HorizontalRight = 1
    case WaterLeft = 2
    case WaterRight = 3
}

extension UICollectionViewLayoutAttributes {
    func alignSectionInset(sectionInset: UIEdgeInsets, layoutType: STLAlignedLayoutType) {
        if layoutType == .HorizontalLeft {
            
        } else if(layoutType == .HorizontalRight) {
            
            
        } else if(layoutType == .WaterLeft) {
            
            var frame = self.frame
            frame.origin.x = sectionInset.left
            self.frame = frame
            
        } else if(layoutType == .WaterRight) {
            
            var frame = self.frame
            frame.origin.x = .screenWidth - frame.size.width - sectionInset.right
            self.frame = frame
        }
        
    }

}


@objc class STLCollectionViewLeftAlignedLayout: UICollectionViewFlowLayout {

    @objc var alignedLayoutType : STLAlignedLayoutType = .HorizontalLeft
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originalAttributes:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? []
        
        var updateAttributes:[UICollectionViewLayoutAttributes] = NSMutableArray.init(array: originalAttributes) as! [UICollectionViewLayoutAttributes]
        
        for attributes in updateAttributes {
            if (attributes.representedElementKind != nil) {
                let index = updateAttributes.firstIndex(of: attributes)
                updateAttributes[index ?? 0] = layoutAttributesForItemAtIndexPath(indexPath: attributes.indexPath as NSIndexPath)
            }
        }
        return updateAttributes
    }
    
    func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        
        let currentItemAttributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: indexPath as IndexPath)?.copy() as! UICollectionViewLayoutAttributes
        let sectionInset = evaluatedSectionInsetForItemAtIndex(index: indexPath.section)
        
        let isFirstItemInSection = indexPath.item == 0
        
        if isFirstItemInSection {
            currentItemAttributes.alignSectionInset(sectionInset: sectionInset, layoutType: self.alignedLayoutType)
            return currentItemAttributes
        }
        
        let previousIndexPath = NSIndexPath.init(item: indexPath.item-1, section: indexPath.section)
        let previousFrame = layoutAttributesForItemAtIndexPath(indexPath: previousIndexPath).frame
        let previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width
        
        
        if self.alignedLayoutType == .WaterRight || self.alignedLayoutType == .WaterLeft {
            let layoutWidth = self.collectionView!.frame.width -  sectionInset.left - sectionInset.right
            let currentFrame = currentItemAttributes.frame
            
            let strecthedCurrentFrame  = CGRect(x: sectionInset.left, y: currentFrame.origin.y, width: layoutWidth, height: currentFrame.size.height)
            let isFirstItemInRow = !strecthedCurrentFrame.contains(currentFrame)
            if isFirstItemInRow {
                
                currentItemAttributes.alignSectionInset(sectionInset: sectionInset, layoutType: self.alignedLayoutType)
                return currentItemAttributes
            }
        }
        
        var frame = currentItemAttributes.frame
        if self.alignedLayoutType == .HorizontalRight || self.alignedLayoutType == .WaterRight {
            frame.origin.x = previousFrameRightPoint - previousFrame.size.width - frame.size.width - evaluatedMinimunInteritemSpacingForSectionAtIndex(index: indexPath.section)
        } else {
            frame.origin.x = previousFrameRightPoint + evaluatedMinimunInteritemSpacingForSectionAtIndex(index: indexPath.section)
        }
        currentItemAttributes.frame = frame
        return currentItemAttributes
    }
    
    func evaluatedMinimunInteritemSpacingForSectionAtIndex(index: NSInteger) -> CGFloat {
        if self.collectionView != nil && self.collectionView!.delegate != nil {
            
            let layoutDelegate: UICollectionViewDelegateFlowLayout = self.collectionView?.delegate as! UICollectionViewDelegateFlowLayout
            
            if layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) {
                
                return layoutDelegate.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index)
            }
            
        }
        return self.minimumInteritemSpacing
    }
    
    func evaluatedSectionInsetForItemAtIndex(index:NSInteger) -> UIEdgeInsets {
        if self.collectionView != nil  && self.collectionView!.delegate != nil {
            let layoutDelegate: UICollectionViewDelegateFlowLayout = self.collectionView?.delegate as! UICollectionViewDelegateFlowLayout
            if layoutDelegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) {
                return layoutDelegate.collectionView!(self.collectionView!, layout: self, insetForSectionAt: index)
            }
        }
        return self.sectionInset
    }
    
}


