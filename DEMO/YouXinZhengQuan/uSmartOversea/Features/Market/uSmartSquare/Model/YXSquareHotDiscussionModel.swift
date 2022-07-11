//
//  YXSquareHotDiscussionModel.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

class YXHotDiscussionListModel: NSObject {
    @objc var list: [YXHotDiscussionModel] = []
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXHotDiscussionModel.self]
    }
    
    @objc var total = 0
}


class YXHotDiscussionModel: NSObject {
    @objc var content: String = ""
    @objc var post_id: String = ""
    @objc var pictures: [String] = []
}

extension YXHotDiscussionListModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

