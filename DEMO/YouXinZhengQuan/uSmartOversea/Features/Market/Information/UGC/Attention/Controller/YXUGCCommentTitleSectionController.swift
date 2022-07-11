//
//  YXUGCCommentTitleSectionController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXUGCCommentTitleSectionController: ListSectionController {
    
    private var model: YXCommentSectionTitleModel?
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 66)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentTitleSectionCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.titleLabel.text = model?.title ?? ""
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? YXCommentSectionTitleModel
    }

}
