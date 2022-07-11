//
//  YXRecommendResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

// http://edu-uat.niubibi.com/teach-server/doc/doc.html

class YXSpecialArticleResModel: YXModel {
    @objc var items : [YXSpecialArticleItem] = []
    @objc var pageCount : Int = 0
    @objc var pageNum : Int = 0
    @objc var pageSize : Int = 0
    @objc var total : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["items": YXSpecialArticleItem.self]
    }
}

class YXSpecialArticleItem : YXModel {
    @objc var tags : [YXKOLTagResModel]?
    @objc var authorId : String?
    @objc var collectFlag : Bool = false
    @objc var collectionCount : String?
    @objc var commentCount : String?
    @objc var createTime : String?
    @objc var nick : String?
    @objc var personalProfile : String?
    @objc var photoUrl : String?
    @objc var postContentSummary : String?
    @objc var postId : String?
    @objc var postTitle : String?
    @objc var postType : String? // 文章类型 1免费 2 收费
    @objc var postCover : String?
    @objc var baseCreateTime : String?

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["tags": YXKOLTagResModel.self]
    }
}

class YXKOLTagResModel: YXModel {
    @objc var id : String?
    @objc var name : String?
}
