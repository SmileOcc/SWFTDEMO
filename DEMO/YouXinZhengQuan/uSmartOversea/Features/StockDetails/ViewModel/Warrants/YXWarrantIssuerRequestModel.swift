//
//  YXWarrantissuerRequestModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/6/1.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

class YXWarrantIssuerRequestModel: YXHZBaseRequestModel {
    
    override func yx_requestUrl() -> String {
        "quotes-dataservice-app/api/v1/warrantissuer"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}
