//
//  YXCommentNoDataAndTitleModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentNoDataAndTitleModel: YXViewModel {

}

//MARK:评论（0）
class YXCommentSectionTitleModel:YXModel {
    @objc var title:String = ""
}

extension YXCommentSectionTitleModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let model = object as? YXCommentSectionTitleModel else {
            return false
        }
        return title == model.title
    }
}


//MARK:快来抢沙发
class YXCommentDetailNoDataModel:YXModel {
    @objc var image:String = ""
    @objc var title:String = ""
    @objc var subTitle:String = ""
    
    @objc var post_id:String = ""
    @objc var post_type:String = ""
}

extension YXCommentDetailNoDataModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}


//MARK:评论（0）
class YXCommentSectionFooterTitleModel:YXModel {
    @objc var title:String = ""
}

extension YXCommentSectionFooterTitleModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let model = object as? YXCommentSectionFooterTitleModel else {
            return false
        }
        return title == model.title
    }
}
