//
//  YXSpecialUnSubscribeResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSpecialKOLListResModel: YXModel {
    @objc var items : [YXSpecialKOLItem] = []
    @objc var pageCount : Int = 0
    @objc var pageNum : Int = 0
    @objc var pageSize : Int = 0
    @objc var total : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["items": YXSpecialKOLItem.self]
    }
}

class YXSpecialKOLItem : YXModel {

    @objc var nick : String?
    @objc var personalProfile : String?
    @objc var photoUrl : String?
    @objc var subscriptId : String?
    @objc var isFollowed : Bool = false

    @objc var tags : [YXKOLTagResModel]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["tags": YXKOLTagResModel.self]
    }
}
