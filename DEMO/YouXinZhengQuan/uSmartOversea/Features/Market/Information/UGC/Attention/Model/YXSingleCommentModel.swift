//
//  YXSingleCommentModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSingleCommentModel: YXResponseModel {
    
    @objc var comment:YXCommentDetailCommentModel?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "comment": "data.comment",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "comment": YXCommentDetailCommentModel.self,
        ]
    }
}
