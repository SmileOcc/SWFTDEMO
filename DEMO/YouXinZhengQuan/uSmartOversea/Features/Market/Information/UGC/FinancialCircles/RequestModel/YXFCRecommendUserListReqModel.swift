//
//  YXFCRecommendUserListReqModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCRecommendUserListReqModel: YXHZBaseRequestModel {
    @objc var limit: Int = 4
    @objc var query_token: String = ""
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/get-recommend-user-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXFCHKRecommendUserListReqModel: YXHZBaseRequestModel {
    @objc var limit: Int = 12
    @objc var query_token: String = ""
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/get-recommend-user-list-hk"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
