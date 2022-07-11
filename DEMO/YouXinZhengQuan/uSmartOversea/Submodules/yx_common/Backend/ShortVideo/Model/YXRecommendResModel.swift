//
//  YXRecommendResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXShortVideoRecommendResModel: YXModel {
    @objc var list : [YXShortVideoRecommendItem]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXShortVideoRecommendItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any]? {
        ["list": "items"]
    }
}

class YXShortVideoRecommendItem: YXModel {
    @objc var courseIdStr : String?
    @objc var lessonIdStr : String?
    @objc var verticalVideoInfo : String?
    @objc var videoIdStr : String?
    @objc var releaseName : String? //kol名称
    @objc var offset = 0
    @objc var version = 0
    @objc var videoTitle : String?
    @objc var videoDesc : String?
    @objc var avatar : String?
    @objc var releaseId : String?
    @objc var relatedType = 0 // 关联类型 0-无 1-课程 2-课时
    @objc var key : String?
    @objc var videoCover : String?
    @objc var videoType : Int = 0 //类型 0:竖版,1:横版
    
    
}
