//
//  YXDividendsDataModel.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

class YXDividendsYearsRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        "/quotes-basic-service/api/v2/dividend-rank-years"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXDividendsYearsResponse.self
    }
}


class YXDividendsYearsResponse: YXResponseModel {

    @objc var date: String = ""
    @objc var list:[YXDividendsYears] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.list","date": "data.date"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXDividendsYears.self]
    }
    
}

class YXDividendsYears: NSObject {
    @objc var rankCode: String = ""
    @objc var year: String = ""

}
