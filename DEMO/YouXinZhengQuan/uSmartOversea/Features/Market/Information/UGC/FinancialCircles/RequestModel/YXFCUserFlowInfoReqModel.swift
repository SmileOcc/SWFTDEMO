//
//  YXFCUserFlowInfoReqModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCUserFlowInfoReqModel: YXHZBaseRequestModel {
    @objc var person_uid = ""
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/query-person-info"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
