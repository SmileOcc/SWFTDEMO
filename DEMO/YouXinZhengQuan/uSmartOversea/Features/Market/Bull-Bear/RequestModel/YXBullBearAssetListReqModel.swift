//
//  YXBullBearAssetListReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearAssetListReqModel: YXHZBaseRequestModel {
    @objc var type = ""
    @objc var sortType = 1
    @objc var sortDirection = 1
    
    override func yx_requestUrl() -> String {
        "/quotes-derivative-app/api/v1/asset/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
