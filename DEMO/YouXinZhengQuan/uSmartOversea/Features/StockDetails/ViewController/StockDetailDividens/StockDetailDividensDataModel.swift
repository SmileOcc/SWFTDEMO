//
//  StockDetailDividensDataModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation



class StockDetailDividensRequestModel: YXHZBaseRequestModel {
    @objc var stock: String = ""
    
    override func yx_requestUrl() -> String {
        "quotes-basic-service/api/v2/dividend-rate"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        StockDetailDividensResponse.self
    }
}


class StockDetailDividensResponse: YXResponseModel {

    @objc var list:[StockDetailDividensYearModel] = []
    @objc var date: String = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.list","date": "data.date"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": StockDetailDividensYearModel.self]
    }
    
}


class StockDetailDividensYearModel: NSObject {
    @objc var date: String = ""
    @objc var div_amount:NSNumber?
    @objc var div_yield: NSNumber?
    @objc var is_exp: Int = 0  //0-实施 1-预案
    @objc var month: [StockDetailDividensDataModel] = []
    @objc var day: [StockDetailDividensDataModel] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["month": StockDetailDividensDataModel.self, "day": StockDetailDividensDataModel.self]
    }
    
}

class StockDetailDividensDataModel: NSObject {
    @objc var date: String = ""
    @objc var div_amount: NSNumber?
    @objc var div_yield: NSNumber?
    @objc var is_exp: Int = 0  //0-实施 1-预案
    
    var stateStr:String {
        if is_exp == 0 {
            return YXLanguageUtility.kLang(key: "stock_detail_dividends_confirmed")
        } else {
            return YXLanguageUtility.kLang(key: "stock_detail_dividends_expected")
        }
    }
    
    var monthNum:Int64 {
        let dateModel = YXDateToolUtility.dateTime(withTime: date)
        return dateModel.month.int64Value
    }
}
