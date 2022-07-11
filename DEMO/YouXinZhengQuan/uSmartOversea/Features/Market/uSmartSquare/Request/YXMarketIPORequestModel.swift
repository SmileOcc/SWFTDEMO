//
//  YXMarketIPORequestModel.swift
//  YouXinZhengQuan
//
//  Created by Kelvin on 2019/3/15.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketIPORequestModel: YXJYBaseRequestModel {
    @objc var exchangeType = 0
    override func yx_requestUrl() -> String {
        return "/jy-ipo-server/api/ipo-todycount/v3"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}
