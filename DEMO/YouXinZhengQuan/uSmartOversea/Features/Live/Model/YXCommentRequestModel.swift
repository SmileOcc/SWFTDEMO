//
//  YXCommentRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/9/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentRequestModel: YXHZBaseRequestModel {
    @objc var content: String? = ""
    @objc var post_id: String? = ""
    @objc var unique_id: String? = ""
    @objc var version: Int = 0
    @objc var ext_type: Int = 0

    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/create-update-comment-info"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}

class YXGetUniqueIdRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/get-unique-id"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}

class YXCommentDetailRequestModel: YXHZBaseRequestModel {
    
    @objc var post_id: String? = ""
    @objc var comment_sort_id: String = "0"  //拉取最新数据：0 其他：id
    @objc var comment_sort_direct : Int = 0 //拉取新数据：0 拉取老数据：1
    @objc var comment_sort_desc: Int = 0 //拉取新数据：0 拉取老数据：1
    @objc var comment_limit : Int = 10
    
    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/get-comment-detail"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXCommentDetailResponseModel.self
    }
}

class YXNewCommentDetailRequestModel: YXHZBaseRequestModel {
    
    ///直播id
    @objc var liveshow_id: String? = ""
    
    ///0=向前、1=向后
    @objc var direction : Int = 0
    
    @objc var limit : Int = 10
    
    ///主播认证用户id
    @objc var live_user_auth_uid: String? = ""
    
    ///主播登录用户id
    @objc var live_user_uid: String? = ""
    
    ///只看主播
    @objc var live_user_only: Bool = false
    
    ///token，接口返回，没有为空
    @objc var query_token: String?
    
    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/get-liveshow-comment"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXNewCommentDetailResponseModel.self
    }
}

class YXLiveCreateMessageRequestModel: YXHZBaseRequestModel {
    
    ///直播id
    @objc var liveshow_id: String? = ""
    
    ///1=进入直播间、2=关注直播间、3=分享直播间
    @objc var msg_type: Int = 1
    
    override func yx_requestUrl() -> String {
        "/zt-hot-stock-server/api/v1/hot-stock/create-liveshow-msg"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
