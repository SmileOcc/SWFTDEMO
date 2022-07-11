//
//  YXCommentDetailNoDataSectionController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXCommentDetailNoDataSectionController: ListSectionController {
    private var nodataModel: YXCommentDetailNoDataModel?
    
    @objc var refreshDataBlock:(() -> Void)?
    
    override func sizeForItem(at index: Int) -> CGSize {
      
        return CGSize(width: collectionContext!.containerSize.width, height:350)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentDetailNoDataCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.refreshBlock = { [weak self] in
            guard let `self` = self else { return }
            self.commentHandel()
        }
        
        cell.model = nodataModel
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        nodataModel = object as? YXCommentDetailNoDataModel
    }
    
    func commentHandel() {
        guard let model = nodataModel else {
            return
        }
        
        if YXUserManager.isLogin() == false {
            YXToolUtility.handleBusinessWithLogin{
                
            }
            return
        }
      
        let dic:[String:String] = ["post_id":model.post_id, "post_type":model.post_type]
        
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            let commentViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
            commentViewModel.isReply = false
            commentViewModel.successBlock = { [weak self] _ in
                guard let `self` = self else { return }
                
                self.refreshDataBlock?()
            }
            
            let commentVC = YXCommentViewController.init(viewModel: commentViewModel)
            YXToolUtility.alertNoFullScreen(commentVC)
        }
    }
   
}
