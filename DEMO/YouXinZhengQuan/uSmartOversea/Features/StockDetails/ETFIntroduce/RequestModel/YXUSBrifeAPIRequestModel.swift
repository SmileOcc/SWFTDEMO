//
//  YXUSBrifeAPIRequestModel.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


/// 查询成分股
class YXUSGetElementRequestModel: YXHZBaseRequestModel {
    @objc var start: Int = 0  //起始位置
    @objc var count: Int = 0  //数量
    @objc var uniqueSecuCode = "" //证券唯一编码
    
    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v1/getelement"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

/// 查询成分变动
class YXUSGetElementChangeRequestModel: YXHZBaseRequestModel {
    @objc var start: Int = 0  //起始位置
    @objc var count: Int = 0  //数量
    @objc var uniqueSecuCode = "" //证券唯一编码
    
    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v1/getelementchange"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

