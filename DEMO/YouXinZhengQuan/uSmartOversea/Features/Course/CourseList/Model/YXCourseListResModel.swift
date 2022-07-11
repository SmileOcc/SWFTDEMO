//
//  YXCourseListResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCourseListResModel: YXModel {
    @objc var list : [YXCourseListItem]!
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXCourseListItem.self]
    }
}

class YXCourseListItem: YXModel {
    @objc var courseCover : String?
    @objc var courseDesc : String?
    @objc var courseLabel: String? //课程标签
    @objc var courseId : String?
    @objc var courseName : String?
    @objc var courseOrder : String?
    @objc var coursePaidFlag : Bool = false // 用户付费标识 0、未付费 1、已付费
    @objc var coursePaidType = 0 // 课程付费类型 0、免费 1、付费
    @objc var coursePrice : String?
    @objc var courseSubtitle : String?
    @objc var currencySymbol : String?
    @objc var studyProgress: Float = 0
    
}
