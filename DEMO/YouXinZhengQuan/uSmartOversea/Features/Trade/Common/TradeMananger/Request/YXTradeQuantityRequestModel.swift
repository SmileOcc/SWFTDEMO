//
//  YXTradequantityRequestModel.swift
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2019/1/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeQuantityRequestModel: YXJYBaseRequestModel {
   
    @objc var entrustPrice = ""
    @objc var handQty : UInt32 = 0  //一手的数量
    @objc var market = ""   //
    @objc var symbol = ""  //
    
    override func yx_requestUrl() -> String {
        "/order-center-dolphin/api/order/stock-order-max-qty-get/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXTradeQuantityResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}

@objcMembers class YXFractionalBuyMaxRequestModel: YXJYBaseRequestModel {
    ///市场，美股期权传US
    var market: String = "US"
    ///代码
    var symbol: String?
    ///价格
    var entrustPrice: String?
    
    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/odd/odd-order-max/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXTradeQuantityResponseModel.self
    }
}

@objcMembers class YXFractionalReplaceBuyMaxRequestModel: YXJYBaseRequestModel {
    ///价格
    var entrustPrice: String?
    ///订单ID
    var orderId: String = ""

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/odd/odd-order-modify-max/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXTradeQuantityResponseModel.self
    }
}

@objcMembers class YXOptionBuyMaxRequestModel: YXJYBaseRequestModel {
    ///市场，美股期权传US
    var market: String = "US"
    ///代码
    var symbol: String?
    ///期权乘数
    var multiplier: Int32 = 0
    ///价格必须传,需要乘以期权乘数
    var price: String?
    
    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/option/option-customer-buy-max/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXTradeQuantityResponseModel.self
    }
}

@objcMembers class YXOptionReplaceBuyMaxRequestModel: YXJYBaseRequestModel {
    ///市场，美股期权传US
    var market: String = "US"
    ///价格必须传,需要乘以期权乘数
    var entrustPrice: String?
    ///订单ID
    var orderId: String = ""

    override func yx_requestUrl() -> String {
        return "/order-center-sg/api/option/option-customer-replace-buy-max/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXTradeQuantityResponseModel.self
    }
}


class YXTradeQuantityResponseModel: YXResponseModel {
    @objc var canBuyModel: CanBuyModel?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["canBuyModel": CanBuyModel.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["canBuyModel": "data"]
    }
}

@objcMembers class CanBuyModel: NSObject {
    ///现金金额
    var cashBalance: NSNumber?
    ///最大可买,即融资可买
    var maxBuyQty: NSNumber?
    ///最大现金可买
    var maxCashBuyQty: NSNumber?
    ///最大融资购买力
    var maxPurchasePower: NSNumber?
    ///最大可卖,即持仓可卖
    var maxSellQty: NSNumber?
    
    ///现金可以买入数量, 正股
    var maxCashBuyMulti:NSNumber?
    
    ///成交数量, 碎股
    var businessQty: NSNumber?
    ///可修改范围的修改下限, 碎股
    var modifiedLowerAmount: NSNumber?
    ///可修改范围的修改上限, 碎股
    var modifiedUpperAmount: NSNumber?

    ///最大可买, 期权
    var buyMax: NSNumber?
    ///最大可卖, 期权
    var sellMax: NSNumber?
}
