//
//  YXNewsDetailUserVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit


class YXNewsDetailUserModel: NSObject {
    @objc var userModel: YXCreateUserModel?
    @objc var descText = ""
}

extension YXNewsDetailUserModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
       return isEqual(object)
    }
}


class YXNewsDetailUserVC: ListSectionController {

    override init() {
        super.init()
    }
    
    private var object: YXNewsDetailUserModel?

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        
        return CGSize(width: width, height: 70)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsDetailUserCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.model = object
        
        
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsDetailUserModel
    }


}
