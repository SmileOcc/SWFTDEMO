//
//  YXMarketIPOAdRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Kelvin on 2019/3/15.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketIPOAdRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        return "/news-configserver/api/v1/query/recommend"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
}
