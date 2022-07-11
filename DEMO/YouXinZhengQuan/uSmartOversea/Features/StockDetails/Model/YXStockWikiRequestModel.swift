//
//  YXStockWikiRequestModel.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStockWikiRequestModel: YXHZBaseRequestModel {
    
    @objc var code = ""
    
    override func yx_requestUrl() -> String {
        return "/quotes-basic-service/api/v1/stock-wiki"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXQuoteTipRequestModel: YXJYBaseRequestModel {
    @objc var marketType: Int = 0
    @objc var selectType: Int = 1  //查询类型；1：待使用、2：已使用、3：已失效

    override func yx_requestUrl() -> String {
        return "/product-server/api/unused-quotation-coupon-list/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
