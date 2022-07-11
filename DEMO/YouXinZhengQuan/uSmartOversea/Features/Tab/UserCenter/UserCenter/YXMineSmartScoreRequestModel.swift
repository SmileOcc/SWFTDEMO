//
//  YXMineSmartScoreRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/12/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMineSmartScoreRequestModel: YXJYBaseRequestModel {


    override func yx_requestUrl() -> String {
        return "/customer-relationship-server/api/get-user-uSmart-points/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
