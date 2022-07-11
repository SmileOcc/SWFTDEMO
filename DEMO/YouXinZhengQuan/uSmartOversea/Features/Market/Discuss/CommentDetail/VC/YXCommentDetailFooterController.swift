//
//  YXCommentDetailFooterController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXCommentDetailFooterController: ListSectionController {
    private var model: YXCommentSectionFooterTitleModel?
    
    typealias ShowMoreBlock = () -> Void
    @objc var showMoreCommentBlock: ShowMoreBlock?
    
    override func sizeForItem(at index: Int) -> CGSize {
      
        return CGSize(width: collectionContext!.containerSize.width, height: 69)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentLoadMoreCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
    
        cell.showMoreCommentBlock = { [weak self] in
            guard let `self` = self else { return }
            self.showMoreCommentBlock?()
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? YXCommentSectionFooterTitleModel
    }
}
