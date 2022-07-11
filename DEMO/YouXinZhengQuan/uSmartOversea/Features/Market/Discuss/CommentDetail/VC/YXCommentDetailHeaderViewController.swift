//
//  YXCommentDetailHeaderViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXCommentDetailHeaderViewController: ListSectionController {
    
    private var postData: YXCommentDetailHeaderModel?
    
    override func sizeForItem(at index: Int) -> CGSize {
        let height = calcurateCellHeight(atIndex: index)
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentDetailHeaderCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.model = postData
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        postData = object as? YXCommentDetailHeaderModel
    }
    
    //MARK: 算高度
    private func calcurateCellHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let postModel = postData, let layout = postModel.postHeaderLayout {
            height = height + layout.userHeight
            if let contentRect = layout.contentlayout?.textBoundingRect {
                height = height + contentRect.maxY + 2
            }
            if let replyRect = layout.replayLayout?.textBoundingRect {
                height = height + replyRect.maxY + 2
            }
            height = height + layout.imageHeight + layout.toolBarHeight
            
        }
        return height
    }
    
}
