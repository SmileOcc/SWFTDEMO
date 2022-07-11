//
//  YXUserAttentionFunsAPI.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//获取评论列表(关注界面中用)
class YXQueryFunsListReq: YXHZBaseRequestModel {
    @objc var target_uid:String = ""
    @objc var limit:Int = 0
    @objc var offset:Int = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-friend-server/api/v1/friend-server/get-fans-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUserAttentionModel.self
    }
}

//获取评论列表(关注界面中用)
class YXQueryConcernListReq: YXHZBaseRequestModel {
    @objc var target_uid:String = ""
    @objc var limit:Int = 0
    @objc var offset:Int = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-friend-server/api/v2/friend-server/get-concern-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUserAttentionModel.self
    }
}
