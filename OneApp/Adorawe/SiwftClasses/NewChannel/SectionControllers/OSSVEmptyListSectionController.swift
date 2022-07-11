//
//  OSSVEmptyListSectionController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit

class OSSVEmptyListSectionController:ListSectionController{
    
    override func numberOfItems() -> Int {
        0
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return collectionContext!.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index)
    }
}
