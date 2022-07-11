//
//  YXUSFractionStatusRequestModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/22.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXUSFractionStatusRequestModel: YXJYBaseRequestModel {

    override func yx_requestUrl() -> String {
       "/user-account-server-sg/api/get-fractional-shares-account-status/v1"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXUSFractionStatusResponse.self
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type":"application/x-www-form-urlencoded"]
    }

}

class YXUSFractionStatusResponse: YXResponseModel {

    @objc var openedAccount: Bool = false
    @objc var idFullName: String = ""

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["openedAccount": "data.openedAccount",
         "idFullName":"data.idFullName"];
    }

}
