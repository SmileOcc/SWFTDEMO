//
//  YXProLevelUpReq.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXProLevelUpReq: YXJYBaseRequestModel {
  
    override func yx_requestUrl() -> String {
        return "/product-server/api/query-pro-auto-upgrade-popup-info/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXProLevelUpModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
       return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}
