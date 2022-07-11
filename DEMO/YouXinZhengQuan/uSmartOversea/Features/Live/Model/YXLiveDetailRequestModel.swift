//
//  YXLiveDetailRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveDetailRequestModel: YXHZBaseRequestModel {

    @objc var id = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-liveshow-detail"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXPauseLiveListRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-paused-liveshow-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXLiveLikeCountRequestModel: YXHZBaseRequestModel {
    
    @objc var list = [["": ""]]
    override func yx_requestUrl() -> String {
        return "/like-server/api/v1/get-unlimited-thumb-up-count-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXUpdateLiveLikeCountRequestModel: YXHZBaseRequestModel {
    
    @objc var biz = ["": ""]
    @objc var count: Int64 = 0
    override func yx_requestUrl() -> String {
        return "/like-server/api/v1/unlimited-thumb-up-op"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXLiveBriefDetailRequestModel: YXHZBaseRequestModel {

    @objc var id = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-liveshow-brief"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXLiveUpdateStatusRequestModel: YXHZBaseRequestModel {

    @objc var id = 0
    @objc var status = 4
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/update-liveshow-status"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXAnchorDemandShowListRequestModel: YXHZBaseRequestModel {

    @objc var anchor_id = 0
    @objc var status = 0
    @objc var offset = 0
    @objc var limit = 10
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-anchordemandshow-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXLiveHasConcernRequestModel: YXHZBaseRequestModel {

    @objc var target_uid = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-friend-server/api/v1/friend-server/has-concern"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


class YXLiveConcernRequestModel: YXHZBaseRequestModel {

    // 业务类型 1:主播关注（弱类型） 3：话题
    @objc var biz_type = 1
    // 1:关注 2:取消关注
    @objc var focus_status = 1
    // 关注目标
    @objc var target_uid = ""
    // 用户id
    @objc var uid = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-friend-server/api/v1/friend-server/concern"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXLiveGetUserRightRequestModel: YXHZBaseRequestModel {

    // 2:直播/预告 3:点播
    @objc var show_type = 2
    @objc var id = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-user-right"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
