//
//  YXNewsTitleVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit


class YXNewsTitleModel: NSObject {
    @objc var content = ""
    @objc var fontSize: CGFloat = 18
    @objc init(content: String, fontSize: CGFloat) {
        super.init()
        self.content = content
        self.fontSize = fontSize
    }
}

extension YXNewsTitleModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
        guard self !== object else { return true }
        guard let object = object as? YXNewsTitleModel else { return false }
        
        return content == object.content && fontSize == object.fontSize
    }
}


class YXNewsTitleVC: ListSectionController {

    override init() {
        super.init()
    }
    
    private var object: YXNewsTitleModel?

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        
        if let content = object?.content, content.count > 0, let fontSize = object?.fontSize {
            let size = YXToolUtility.getStringSize(with: content, andFont: UIFont.systemFont(ofSize: fontSize, weight: .medium), andlimitWidth: Float(YXConstant.screenWidth) - 32, andLineSpace: 5)
            return CGSize(width: width, height: size.height + 10)
        } else {
            return CGSize(width: width, height: 0.01)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsTitleCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.model = object
        
        
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsTitleModel
    }

}
