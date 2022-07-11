//
//  YXUGCNoAttentionSectionController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXUGCNoAttentionSectionController: ListSectionController {
    private var model: YXUGCNoAttensionUserModel?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height:CGFloat = cacurateCellHeight()
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNoAttensionedCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.titleLabel.text = model?.title ?? ""
     
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? YXUGCNoAttensionUserModel
    }
    
    func cacurateCellHeight() -> CGFloat {
       return 300
    }
    
}
