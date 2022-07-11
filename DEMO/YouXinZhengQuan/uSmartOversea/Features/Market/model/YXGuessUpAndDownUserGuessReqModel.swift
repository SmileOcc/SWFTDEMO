//
//  YXGuessUpAndDownUserGuessReqModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXGuessUpAndDownUserGuessReqModel: YXJYBaseRequestModel {
    @objc var market = "" // 0：港股，5：美股
    @objc var guessChange = ""
    @objc var code = ""
    
    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/guess-grf-stock/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXStockDetailGuessStockRequestModel: YXJYBaseRequestModel {

    @objc var market = ""
    @objc var code = ""

    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/get-grf-stock-info/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXGuessUpAndDowListReqModel: YXHZBaseRequestModel {
//    @objc var theme_id = 0
    @objc var offset = 0
    @objc var limit = 3 // 数量
    override func yx_requestUrl() -> String {
//        return "/activity-server/api/get-intraday-stock-infos/v1"
        return "/quotes-marketing/api/v1/app/guess-up-down/stock/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXGuessUpAndDownListResModel.self
    }
}

class YXGuessUpAndDownListResModel: YXResponseModel {
    @objc var list : [YXGuessUpAndDownListStockInfo] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXGuessUpAndDownListStockInfo.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "list": "data.list",
        ]
    }
    
}

class YXGuessUpAndDownListStockInfo: NSObject {
    @objc var market : String?
    @objc var secuCode : String? // 0：跌，1：涨
    @objc var stockName : String?
    @objc var notes : String?
    @objc var upCount : NSNumber?
    @objc var themeId : NSNumber?
    @objc var pctchng: NSNumber?
    @objc var netchng: NSNumber?
    @objc var latestPrice: NSNumber?
    @objc var priceBase: NSNumber?
    @objc var type1: NSNumber?
    @objc var type2: NSNumber?
    @objc var type3: NSNumber?
    //拼接数据
    @objc var downCount:NSNumber?
    @objc var guessChange:NSNumber?
    @objc var transDate: String?
}

class YXGuessStockInfosRequestModel: YXJYBaseRequestModel {

    @objc var stockCodes:[[String:Any]] = []

    override func yx_requestUrl() -> String {
        return "/activity-server-sg/api/get-grf-stock-info-list/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXGuessUpOrDownInfoLists.self
    }
}
