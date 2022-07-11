//
//  YXIsCollectRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXIsCollectRequestModel: YXHZBaseRequestModel {
    @objc var newsid = ""
    
    override func yx_requestUrl() -> String {
        return "/news-msgdisplay/api/v1/judgecollect"
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

class YXArticleIsCollectRequestModel: YXHZBaseRequestModel {
    @objc var cid = [String]()
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/collect-article-status-list"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }

}

class YXVideoIsCollectRequestModel: YXHZBaseRequestModel {
    /// 收藏类型 3：直播回放 5：课程
    @objc var collection_type = 3
    @objc var id = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-user-collection"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }

}

