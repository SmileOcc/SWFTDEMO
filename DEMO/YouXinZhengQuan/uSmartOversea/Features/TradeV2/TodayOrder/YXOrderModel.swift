//
//  YXOrderModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXOrderModel: YXModel {
    
    var businessQty: NSNumber?
    var businessAvgPrice: NSNumber?
    var conId: Int64 = 0
    var createTime: String = ""
    var entrustQty: NSNumber?
    var entrustId: String = ""
    var entrustNo: String  = ""
    var entrustPrice: NSNumber?
    var entrustAmount: NSNumber?
    var entrustProp: String = ""
    var entrustType: Int32 = 0
    var isFinalStatus: String = ""
    var moneyType: Int32 = 0
    var quickFlag: String = ""
    var flag: String = ""
    var dayEnd: Int = 0
    var status: Int32 = 0 // 1-等待提交，5-待报单，10-报单中，11-待成交，12-等待撤单，13-等待改单，20-部分成交，27-成交处理中，28-部成撤单，29-全部成交，30-已撤单，31-下单失败，32-废单，33-收市撤单
    var statusName: String = ""
    var symbol: String = ""
    var symbolName: String = ""
    var createDate: String = ""
    var sessionType = 0    //0/不传-正常订单交易（默认），1-盘前，2-盘后交易，3-暗盘交易
    var failReason: String = ""
    var dayMarginId: String = ""
    var stockModifyFlag: Int32 = 0
    
    var isStopOut: Int = 0
    var modifyFlag: Bool = false
    var market: String = ""
    var entrustSide: String = ""
    var cancelFlag :Bool = false   //   是否允许撤单,0:不允许,1允许
    var finalStateFlag:String = "" //0非终态，1是终态
    //var tradePeriod :String = "" ////交易时段N-正常下单交易,G-暗盘交易,盘前盘后:AB,默认:正常
    
    var tradePeriod:String = "" //N正常下单交易 B盘后 A盘前 G暗盘
    var symbolType: Int = 1 //1-股票；3-涡轮牛熊；4-期权
    
    var oddTradeType: Int = 0 //1-股数
    
    // 用于今日订单排序，已结束的订单排在后面
    @objc var isFinished: Bool {
        // 已结束的订单包含：下单失败、废单、已撤单、全部成交、收市撤单
        let isFinished = self.status == 29 || self.status == 30 || self.status == 31 || self.status == 32 || self.status == 33;
        return isFinished
    }

    func realMarket() -> String {
        if symbolType == 4 {
            return kYXMarketUsOption
        }
        return market.lowercased()
    }

    override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["dayMarginId": "id",
                "entrustId":"id",
                "stockName":"symbolName"];
    }
}
