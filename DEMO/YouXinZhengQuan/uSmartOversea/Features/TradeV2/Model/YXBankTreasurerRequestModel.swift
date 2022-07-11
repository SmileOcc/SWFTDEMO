//
//  YXBankTreasurerRequestModel.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/8/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBankTreasurerRequestModel: YXJYBaseRequestModel {
    
    @objc var applyAmount = ""
    // 业务类型 日内融传10 期权传20
    @objc var businessType: Int = 10
    
    // 市场
    @objc var exchangeType: Int = 0
    
    // 币种类型。(0-人民币，1-美元，2-港币)
    @objc var moneyType: Int = 2
    
    // 转入账户类型 (0:普通账户; 1:house账户; 2:margin账户; 10:DA账户; 11:MA公共账户; 12:MA费用账户; 20:日内融账户; 30:期权账户)
    @objc var inAccountType = 0
    
    // 转出账户类型 (0:普通账户; 1:house账户; 2:margin账户; 10:DA账户; 11:MA公共账户; 12:MA费用账户; 20:日内融账户; 30:期权账户)
    @objc var outAccountType = 0
    
    
    override func yx_requestUrl() -> String {
        return "/stock-capital-server/api/apply-allocation/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

}

class YXBankTreasurerDetailRequestModel: YXJYBaseRequestModel {
    
    @objc var id = ""
    
    
    override func yx_requestUrl() -> String {
        return "/stock-capital-server/api/query-allocation-detail/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

}


class YXBankTreasurerListRequestModel: YXJYBaseRequestModel {
        
    @objc var pageNum: Int = 1
    @objc var pageSize: Int = 30
    
    @objc var query = [AnyHashable: Any]()
    
    override func yx_requestUrl() -> String {
        return "/stock-capital-server/api/query-allocation-list/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

}
