//
//  YXUGCAttentionCommentListModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCAttentionCommentListModel: YXResponseModel {
    @objc var list:[YXUGCAttentionCommentListItemModel] = []
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXUGCAttentionCommentListItemModel.self,
        ]
    }
}


class YXUGCAttentionCommentListItemModel:YXModel {
    @objc var comment_count:UInt64 = 0
    @objc var comment_list:[YXSquareStockPostListCommentModel] = []
    @objc var post_id:String = ""
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "comment_list": YXSquareStockPostListCommentModel.self,
        ]
    }
}


//MARK:post 单个评论模型
class YXUGCSingleCommentListCommentModel: YXResponseModel {
    @objc var post:YXUGCAttentionCommentListItemModel?
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "post": "data.post",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "post": YXUGCAttentionCommentListItemModel.self,
        ]
    }
}
