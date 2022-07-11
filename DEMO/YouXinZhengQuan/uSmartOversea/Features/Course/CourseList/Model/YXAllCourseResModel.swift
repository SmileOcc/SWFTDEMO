//
//  YXAllCourseResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAllCourseResModel: YXModel {
    @objc var list : [YXCourseItem]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXCourseItem.self]
    }
}

class YXCourseItem: YXModel {
    @objc var categoryId : String?
    @objc var categoryIdStr : String?
    @objc var categoryLevel : Int = 0
    @objc var categoryName : String?
    @objc var categoryOrder : Int = 0
    @objc var createTime : String?
    @objc var creater : String?
    @objc var list : [YXCourseItem]?
    @objc var primaryId : String?
    @objc var primaryIdStr : String?
    @objc var updateTime : String?
    @objc var updater : String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXCourseItem.self]
    }
}
