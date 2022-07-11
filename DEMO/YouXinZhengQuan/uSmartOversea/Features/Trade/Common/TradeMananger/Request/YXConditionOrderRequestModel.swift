//
//  YXConditionOrderRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXConditionOrderRequestModel: YXJYBaseRequestModel {
    
    ///条件单ID
    var conId: String?
    ///触发价格
    var conditionPrice: String?
    ///委托数量
    var entrustAmount:Int64 = 0
    ///委托价格，市价单传0
    var entrustPrice: String?
    ///交易类别(HK-香港,US-美股,HGT-沪港通,SGT-深港通)
    var market: String?
    ///市值价
    var marketPrice: String?
    ///股票代码
    var stockCode: String?
    ///股票名称
    var stockName: String?
    ///条件单最终有效时间描述,1-收盘前有效,2-2天.3-3天,4-1周,5-2周，6-30天,7-暗盘全日（16：15~18：30），8-暗盘半日（14：15~16：30）9-60天
    var strategyEnddateDesc: String?
    
    //以上必传
    
    ///关联资产参数
    var relatedStockCode: String?
    var relatedStockMarket: String?
    var relatedStockName: String?
    var entrustSide: String?
    
    ///跟踪止损价差
    var dropPrice: String?
    ///成本价
    var costPrice: String?
    ///幅度百分比
    var amountIncrease: NSDecimalNumber?
    ///扩展信息
    var conditionExtendDTO: ConditionExtendDTO?
    ///条件类型（1:突破买入，2:低价买入，3:高价卖出，4:跌破卖出）
    var conditionType: SmartOrderType = .breakBuy
    ///触发委托挡位,0最新价, 买一档 1, 买五档2, 卖一档3, 卖五档4,市场价5
    var entrustGear: NSNumber?
    ///委托属性,限价单:LMT,增强限价单:ELMT,市价单:MKT,竟价市价单:AM,竟价限价单:AL
    var entrustProp: String?
    ///交易时段N-正常下单交易,G-暗盘交易,盘前盘后:AB,默认:正常
    var tradePeriod: String?
    
    override func yx_requestUrl() -> String {
        if conId != nil {
            return "/condition-center-sg/api/update-condition/v1"
        }
        return "/condition-center-sg/api/add-condition/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    func yx_requestTimeoutInterval() -> TimeInterval {
        30
    }
    
    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["conditionExtendDTO": ConditionExtendDTO.self]
    }
}

class YXQueryCondinfoRequestModel: YXHZBaseRequestModel {
    @objc var syncIdList: [String] = [String]()
    
    override func yx_requestUrl() -> String {
        return "/quotes-smart-order-front/api/v1/querycondinfo"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXQueryCondinfoResponseModel.self
    }
}

class YXQueryCondinfoResponseModel: YXResponseModel {
    
    @objc var list: [YXCondInfo]? = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["list": "data.condInfoList"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXCondInfo.self]
    }
}

class YXCondInfo: YXModel {
    @objc var triggerprice: String? //触发价
    @objc var highestPrice: String? //最高价
    @objc var syncId: String?
}
