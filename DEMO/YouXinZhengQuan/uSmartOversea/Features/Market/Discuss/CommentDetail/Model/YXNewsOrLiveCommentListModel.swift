//
//  YXNewsOrLiveCommentListModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsOrLiveCommentListModel: YXResponseModel {
    @objc var list: [YXCommentDetailCommentModel] = []
    @objc var total:Int = 0
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list",
            "total": "data.total"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXCommentDetailCommentModel.self,
        ]
    }
}
