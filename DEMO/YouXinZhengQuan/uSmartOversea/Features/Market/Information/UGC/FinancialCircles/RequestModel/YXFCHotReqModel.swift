//
//  YXFCHotReqModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCHotReqModel: YXHZBaseRequestModel {
    @objc var page_size: Int = 20
    @objc var query_token: String = ""
    @objc var person_uid: String = ""
    @objc var flowType: Int = 0 // 0 图文 1 视频 2 个人主页
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func yx_requestUrl() -> String {
        if flowType == 0 {
            return "/feed-apiserver/api/v1/query-hot-article-list"
        }else if flowType == 1 {
            return "/feed-apiserver/api/v1/query-hot-video-list"
        }else if flowType == 2 {
            return "/feed-apiserver/api/v1/query-person-feed-list"
        }else {
            return ""
        }
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXNewHotReqModel: YXHZBaseRequestModel {
    @objc var page_size: Int = 20
    @objc var query_token: String = ""
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v2/query-hot-feed-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUGCFeedAttentionPostListModel.self
    }
}
