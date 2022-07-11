//
//  YXUGCRecommandUserSectionController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXUGCRecommandUserSectionController: ListSectionController {
    
    @objc var changeRecommandUserBlock:(() -> Void)?

    private var model: YXUGCRecommandUserListModel?
    
    override func sizeForItem(at index: Int) -> CGSize {
     
        return CGSize(width: collectionContext!.containerSize.width, height: 350)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXUGCRecommandUserCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.changeBlock = { [weak self] in
            guard let `self` = self else { return }
            self.changeRecommandUserBlock?()
        }
        cell.isWhiteStyle = true
        cell.model = model
       
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        model = object as? YXUGCRecommandUserListModel
    }
}
