//
//  YXCommentListResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentListResModel: YXModel {
    @objc var pageCount : Int = 0
    @objc var pageNum : Int = 1
    @objc var pageSize : Int = 20
    @objc var total : Int = 0
    @objc var items : [YXCourseCommentItem] = []
    @objc var code : YXResponseStatusCode = .success
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["items": YXCourseCommentItem.self]
    }
}

class YXCourseCommentItem: YXModel {
    @objc var commentId : String?
    @objc var delFlag : Bool = false
    @objc var discuss : String?
    @objc var discussDate : String?
    @objc var nick : String?
    @objc var photoUrl : String?
    @objc var uid : String?
}
