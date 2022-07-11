//
//  YXLiveShowStockRequest.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/11.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

class YXLiveShowStockRequestModel: YXHZBaseRequestModel {
    
    @objc var show_stocks_id = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-liveshow-api/api/v1/get-showstocks-list"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXLiveShowStockResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

class YXLiveShowStockResponseModel: YXResponseModel {
    @objc var stockIdList: [String]?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["stockIdList": "data.show_stocks.stock_id_list"];
    }
    
}
