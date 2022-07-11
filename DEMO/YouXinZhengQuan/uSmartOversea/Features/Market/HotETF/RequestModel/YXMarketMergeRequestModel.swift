//
//  YXMarketMergeRequestModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketRequestItem: YXModel {
    @objc var sorttype: Int = 1
    @objc var sortdirection: Int = 1
    @objc var pagedirection: Int = 0
    @objc var from: Int = 0
    @objc var count: Int = 0
    @objc var code: String = ""
    @objc var market: String = ""
    @objc var level: Int = 1
}

class YXMarketMergeRequestModel: YXHZBaseRequestModel {
    @objc var codelist: [YXMarketRequestItem] = []
    
    override func yx_requestMethod() -> YTKRequestMethod {
        .POST
    }
    
    override func yx_requestUrl() -> String {
        "quotes-dataservice-app/api/v2-2/rank"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXMarketMergeResponseModel.self
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["codelist": YXMarketRequestItem.self]
    }
}
