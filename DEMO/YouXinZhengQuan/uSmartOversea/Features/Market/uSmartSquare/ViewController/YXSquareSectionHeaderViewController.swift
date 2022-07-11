//
//  YXSquareSectionHeaderViewController.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit


class YXSquareHotCommentSectionCell: YXSquareSectionCell {
    
}

class YXSquareSectionHeaderViewController: ListSectionController {
    
    private var object: YXSquareSection?

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        return CGSize(width: width, height: 55)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXSquareHotCommentSectionCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.model = self.object
        cell.arrowImgaeView.isHidden = true
        cell.hLineView.isHidden = false
        return cell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? YXSquareSection
    }
    
}
