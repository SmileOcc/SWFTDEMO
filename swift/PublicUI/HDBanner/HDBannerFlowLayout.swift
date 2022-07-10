//
//  HDBannerFlowLayout.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/25.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class HDBannerFlowLayout: UICollectionViewFlowLayout {
    public var isZoom:Bool?;
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        // 1.获取cell对应的attributes对象
        let superAttr = super.layoutAttributesForElements(in: rect)!;
        let arrayAttr = NSArray(array: superAttr, copyItems: true)
        
        if isZoom == false {
            return (arrayAttr as! [UICollectionViewLayoutAttributes]);
        }
        
        // 2.计算整体的中心点的x值
        let centerX = (self.collectionView?.contentOffset.x)! + self.collectionView!.width * 0.5;
        
        // 3.修改一下attributes对象
        for i in 0 ..< arrayAttr.count {
            let attr = arrayAttr[i] as! UICollectionViewLayoutAttributes;
            // 3.1 计算每个cell的中心点距离
            let distance:CGFloat = abs(attr.center.x - centerX);
            // 3.2 距离越大，缩放比越小，距离越小，缩放比越大
            let factor:CGFloat = 0.001;
            let scale = 0.9 / (1 + distance * factor);
            attr.transform = CGAffineTransform(scaleX: scale, y: scale);
        }
        
        return (arrayAttr as! [UICollectionViewLayoutAttributes]);
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true;
    }
}
