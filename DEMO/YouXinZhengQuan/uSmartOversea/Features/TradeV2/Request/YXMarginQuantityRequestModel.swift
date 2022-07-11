//
//  YXMarginQuantityRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/3/19.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarginQuantityRequestModel: YXJYBaseRequestModel {
    
    //委托数量
    @objc var entrustAmount: Int64 = 0
    
    //委托属性('0'-美股限价单,'d'-竞价单,'e' -增强限价单,'g'-竞价限价单，'u'-碎股单)
    @objc var entrustProp = ""
    
    //交易类别(0-香港,5-美股,6-沪港通,7-深港通)
    @objc var exchangeType = 0
    
    //证券代码
    @objc var stockCode = ""
    
    //委托Id-如果entrystType是改单的话，必填
    @objc var entrustId = ""
    
    //委托价格(不能为0,竞价单可不填)
    @objc var entrustPrice = ""
    
    //查询委托类别(0-买，5-改单)
    @objc var entrustType: Int = 0
    
    override func yx_requestUrl() -> String {
        "/stock-order-server/api/trade-margin-quantity/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
}
