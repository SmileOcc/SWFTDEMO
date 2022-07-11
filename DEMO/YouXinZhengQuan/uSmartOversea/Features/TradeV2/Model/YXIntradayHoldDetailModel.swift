//
//  YXIntradayHoldDetailModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIntradayHoldDetailModel: YXResponseModel {
    
    @objc var closeRespVO:YXIntradayCloseRespModel?
    @objc var openRespVO:YXIntradayOpenRespModel?
    @objc var shippingList:[YXIntradayShippingListModel] = []
    
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "closeRespVO": "data.closeRespVO",
            "openRespVO": "data.openRespVO",
            "shippingList": "data.shippingList"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "closeRespVO": YXIntradayCloseRespModel.self,
            "openRespVO": YXIntradayOpenRespModel.self,
            "shippingList":YXIntradayShippingListModel.self
        ]
    }
}

//平仓记录
class YXIntradayCloseRespModel: YXModel {
    @objc var sellBalance:NSNumber? //成交金额number
    @objc var sellLastTime:String = "" //平仓时间string(date-time)
    @objc var sellNum:NSNumber? //成交数量number
    @objc var sellPrice:String = "" //平仓均价number
    @objc var totalProfit:NSNumber? //盈亏金额number
    @objc var totalProfitRatio:NSNumber? //盈亏比例
    
}

class YXIntradayOpenRespModel: YXModel {
    @objc var actualLeverAfter:String = "" //建仓杠杠number
    @objc var buyBalance:NSNumber? //建仓金额number
    @objc var buyDate:String = "" //建仓的交易日string(date-time)
    @objc var buyNum:NSNumber? //建仓数量number
    @objc var buyPrice:NSNumber? //建仓价格number
    @objc var entrustProp:String = "" //订单类型 w市价单，e增强限价单string
    @objc var marginAfter:String = "" //建仓保证金number
    @objc var moneyType:Int = 0 //币种类型。(0-人民币，1-美元，2-港币)integer(int32)
    @objc var stopLossRateAfter:NSNumber? //建仓止损比例number
    @objc var stopWinRateAfter:NSNumber? //建仓止盈比例
}


class YXIntradayShippingListModel: YXModel {
    @objc var actualLeverAfter:String = "" //实际杠杠（调整后）number
    @objc var actualLeverBefore:String = "" //实际杠杠（调整前））number
    @objc var changeType:Int = 0 //仓位调整类型: 1-保证金调整,2-止盈止损调整integer(int32)
    @objc var createTime:String = "" //创建时间string(date-time)
    @objc var id:String = "" //主键string
    @objc var marginAfter:NSNumber? //持仓保证金（调整后）number
    @objc var marginBefore:NSNumber? //持仓保证金（调整前）number
    @objc var orderId:String = "" //主订单idstring
    @objc var stopLossRateAfter:NSNumber? //止损比例（调整后）number
    @objc var stopLossRateBefore:NSNumber? //止损比例（调整前）number
    @objc var stopWinRateAfter:NSNumber? //止盈比例（调整后）number
    @objc var stopWinRateBefore:NSNumber? //止盈比例（调整前））number
    @objc var updateTime:String = "" //修改时间string(date-time)
    @objc var version:String = "" //乐观锁版本号integer(int32)
}
