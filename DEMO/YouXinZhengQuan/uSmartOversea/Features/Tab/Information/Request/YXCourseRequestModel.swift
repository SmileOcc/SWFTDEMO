//
//  YXCourseRequest.swift
//  uSmartOversea
//
//  Created by 井超 on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNewCourseRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        return "/zt-video-center-api-server/api/v1/video-center/get-icon-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
    
//    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
//        return [:];
//    }
}

class YXNewCourseRecommedListRequestModel: YXHZBaseRequestModel {
    
    @objc var offset = "0"
    @objc var limit = "2"
    override func yx_requestUrl() -> String {
        return "/zt-video-center-api-server/api/v1/video-center/get-hot-video-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
    

}



class YXCourseRequestModel: YXHZBaseRequestModel {
    
    @objc var pagesize = 30
    @objc var offset = 0
    @objc var course_classify_id = ""

    override func yx_requestUrl() -> String {
        return "/news-videoserver/api/v1/query/course_list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}


// 专辑列表
class YXTopicCategoryListRequestModel: YXHZBaseRequestModel {
        
    @objc var page = [String:Any]()
    override func yx_requestUrl() -> String {
        return "/zt-video-center-api-server/api/v1/video-center/get-all-special-topic-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }

}


class YXTopicCategoryListDetailRequestModel: YXHZBaseRequestModel {
    
    @objc var page = ["limit": 6, "offset": 0]
    @objc var special_topic_ids = [[String:Any]]()
    
    override func yx_requestUrl() -> String {
        return "/zt-video-center-api-server/api/v1/video-center/batch-get-special-topic-detail-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }

}
