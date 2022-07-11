//
//  YXCollectRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXCollectRequestModel: YXHZBaseRequestModel {
    @objc var newsids = ""
    @objc var collectflag = false
    
    override func yx_requestUrl() -> String {
        return "/news-msgdisplay/api/v1/collect"
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

class YXAritckcCollectRequestModel: YXHZBaseRequestModel {
    @objc var cid = [""]
    // 收藏动作(1=收藏 2=取消收藏)
    @objc var collect_type: Int = 1
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/collect-article"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXVideoAddCollectRequestModel: YXHZBaseRequestModel {
    /// 收藏类型 3：直播回放 5：课程
    @objc var collection_type = 3
    @objc var id = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/add-user-collection"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXVideoCancelCollectRequestModel: YXHZBaseRequestModel {
    /// 收藏类型 3：直播回放 5：课程
    @objc var collection_type = 3
    @objc var id = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/cancel-user-collection"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


