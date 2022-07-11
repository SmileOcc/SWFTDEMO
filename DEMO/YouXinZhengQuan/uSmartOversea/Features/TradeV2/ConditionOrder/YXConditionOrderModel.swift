//
//  YXConditionOrderModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/2/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXConditionOrderModel: YXModel {
    @objc var market: String?   

    @objc var amountIncrease: NSDecimalNumber?         //涨幅(前端需要转换成10%这种形式)
    @objc var conId: String = ""                //订单id
    @objc var conditionPrice: NSNumber = 0      //触发价格
    @objc var conditionType: Int = 0            //订单类型
    @objc var conditionTypeDesc: String = ""    //类型描述
    @objc var createTime: String = ""           //条件单创建时间
    
    @objc var entrustAmount: Int64 = 0          //委托数量
    @objc var entrustPrice: NSNumber = 0        //委托价格

    //委托类别
    @objc var smartOrderType: SmartOrderType {
        return SmartOrderType(rawValue: conditionType) ?? .breakBuy
    }

    @objc var triggerPrice: NSNumber = 0        //触发价格
    
    @objc var moneyType: Int32 = 0              //币种类别(1-美元，2-港币)
    @objc var status: Int32 = 0                 //订单发送状态('0'-未执行,'1'-已执行,'2'-失效,'3'-已取消） ，除了0都是终态
    @objc var statusDes: String = ""            //状态描述（0-生效中,1-已触发,2-已失效,3-已取消/已失效）
    @objc var stockCode: String = ""            //股票代码
    @objc var stockName: String = ""            //股票名称
    @objc var strategyEnddate: String = ""      //条件单有效时间
    @objc var strategyEnddateDesc: String = ""  //条件单有效时间中文描述
    
    @objc var entrustProp: String = ""
//    @objc var sessionType = 0
    @objc var tradePeriod:String = "" //N正常下单交易 B盘后 A盘前 G暗盘
    
    @objc var entrustGear: NSNumber?
    @objc var dropPrice: NSNumber?
    // 扩展信息
    @objc var conditionExtendDTO: ConditionExtendDTO?
    // 关联正股代码
    @objc var releationStockCode: String = ""
    @objc var releationStockName: String = ""
    @objc var relatedStockMarket: String = ""
    @objc var relatedStockCurrency: String = ""

    //行情ID, 跟踪止损查最高价用
    @objc var quoteCondId: String = ""
    
    //期权智能单
    @objc var expireType: NSNumber?
    @objc var expireTime: NSNumber?
    @objc var symbol: String = ""
    @objc var contractMultiplier: Int32 = 0 // 合约乘数
    @objc var orderType: Int32 = 2 //1市价2限价
    @objc var orderId: String = ""

    @objc var currency: String = ""

    @objc var relatedStockName: String = ""

    ///委托方向,买入:B,卖出:S
    @objc var entrustSide: String = ""

    override class func modelCustomPropertyMapper() -> [String : Any]! {
        return ["statusDes": ["statusDes", "statusDesc", "statusFrontDesc"],
                // 以下是期权订单的字段映射
                "status": ["status", "smartStatus", "statusFront"],
                "entrustAmount": ["entrustAmount", "orderQty"],
                "entrustPrice": ["entrustPrice", "orderPrice"],
                "strategyEnddateDesc": ["strategyEnddateDesc", "expireType"],
                "stockName": ["stockName", "symbolName"],
                "amountIncrease": ["amountIncrease", "conditionValue"],
                "conId": ["conId", "id"],
                "releationStockName": ["releationStockName", "relationSymbolName", "relatedStockName"],
                "releationStockCode": ["releationStockCode", "relationSymbol", "relatedStockCode"],
                "entrustType":["entrustType", "orderSide"]
        ]
    }

    // 委托总金额
    @objc func entrustTotalMoney() -> NSNumber {
        return NSNumber.init(value: self.entrustPrice.doubleValue * Double(self.entrustAmount))
    }
}
