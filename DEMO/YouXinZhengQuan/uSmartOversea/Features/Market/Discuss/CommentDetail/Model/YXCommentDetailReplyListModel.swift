//
//  YXCommentDetailReplyListModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailReplyListModel: YXResponseModel {
    @objc var list: [YXCommentDetailListReplyModel] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXCommentDetailListReplyModel.self,
        ]
    }
}
