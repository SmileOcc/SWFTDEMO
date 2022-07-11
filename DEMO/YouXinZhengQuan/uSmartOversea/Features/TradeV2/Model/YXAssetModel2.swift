//
//  YXAssetModel2.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXAssetModel2: YXModel {
    @objc var asset: String = ""
    @objc var anticipatedInterest: String = ""
    @objc var creditAmount: String = ""
    @objc var creditRatio: String = ""
    @objc var marginRatioDay: String = ""
    @objc var marginRatioYear: String = ""
    @objc var mortgageMarketValue: String = ""
    @objc var callMarginCall: String = ""
    @objc var debitBalance: String = ""
    @objc var mv: String = ""
    @objc var marketValue: String = ""
    @objc var riskStatusCode: Int = 0
    @objc var riskStatusName: String = ""
    @objc var purchasePower: String = ""
    @objc var enableBalance: String = ""
    @objc var frozenBalance: String = ""
    @objc var stockMarketValue: String = ""
    @objc var fundMarketValue: String = ""
    @objc var bondMarketValue: String = ""
    @objc var onWayBalance: String = ""
    @objc var holdStockProfitList: [YXJYHoldStockModel] = []
    @objc var holdFundProfitList: [YXJYHoldFundModel] = []
    @objc var holdBondProfitList: [YXJYHoldBondModel] = []
    @objc var groupByStockDTOList: [YXJYDTOModel] = []
    @objc var holdList: [YXJYHoldShortSellModel] = []
    
    @objc var totalDailyBalance: String = ""
    @objc var totalDailyBalancePercent: String = ""
    @objc var totalHoldingBalance: String = ""
    @objc var totalHoldingBalancePercent: String = ""
    @objc var withdrawBalance: String = ""
    
    @objc var holdCount: Int = 0
    
    @objc var holdingBalance: String = ""
    @objc var totalMarketValue: String = ""
    @objc var holdDTOList: [YXJYHoldOptionModel] = []
    @objc var afBalance: String = ""
    @objc var penaltyCapitalBalance: String = ""
    @objc var penaltyCouponBalance: String = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return
            ["totalDailyBalance": ["dailyBalance", "totalDailyBalance"],
             "totalDailyBalancePercent": ["dailyBalancePercent", "totalDailyBalancePercent"],
             "withdrawBalance": ["withdrawBalance", "accountSubInfoRespVO.withdrawBalance"]];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["holdStockProfitList": YXJYHoldStockModel.self,
                "holdFundProfitList": YXJYHoldFundModel.self,
                "holdBondProfitList": YXJYHoldBondModel.self,
                "groupByStockDTOList": YXJYDTOModel.self,
                "holdDTOList": YXJYHoldOptionModel.self,
                "holdList": YXJYHoldShortSellModel.self]
    }
}

class YXJYHoldStockModel: YXModel {
    
    @objc var costPrice: String? = ""
    @objc var currentAmount: String? = ""
    @objc var dailyBalance: String? = ""
    @objc var dailyBalancePercent: String? = ""
    @objc var exchangeType: Int = 0
    @objc var holdingBalance: String? = ""
    @objc var holdingBalancePercent: String? = ""
    @objc var lastPrice: String? = ""
    @objc var marketValue: String? = ""
    @objc var stockCode: String? = ""
    @objc var stockName: String? = ""
    @objc var quoteType: String? = ""
    //  "股票类型(0-股票，1-基金，2-红利，D-交易权证，F-一篮子权证，U-债券)"
    @objc var stockType: String? = ""
    
//    @objc var heaverRatio: String? = ""
    @objc var heaverMaxRatio: String? = ""
    @objc var buyPrice: String? = ""
    @objc var stopLossPrice: String? = ""
    @objc var stopLessCeilIng: String? = ""
    @objc var stopLossRate: String? = ""
    @objc var stopWinPrice: String? = ""
    @objc var stopWinRate: String? = ""
    @objc var seqNo: String? = ""
    @objc var holdFrontStatus: Int = 0
    @objc var holdId: Int64 = 0
    @objc var entrustCash: String? = ""
    @objc var orderStatus: Int = 0
    @objc var buildTime: Int = 0
    @objc var sessionType: Int = 0
    
    @objc var bitMark: Int = 0 //1 可以调整保证金
    @objc var heaverRatioDecimal: Double = 0
    @objc var market :String = ""
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
    
//    var p_modelType: Int = 0
//    
//    func p_name() -> String {
//        return stockName
//    }
//    
//    func p_stockCode() -> String {
//        return stockCode
//    }
//    
//    func p_quoteType() -> String {
//        return quoteType
//    }
//    
//    func p_exchangeType() -> Int {
//        return exchangeType
//    }
//    
//    func p_marketValue() -> String {
//        return marketValue
//    }
//    
//    func p_currentPrice() -> String {
//        return lastPrice
//    }
//    
//    func p_costPrice() -> String {
//        return costPrice
//    }
//    
//    func p_holdingBalance() -> String {
//        return holdingBalance
//    }
//    
//    func p_holdingBalancePercent() -> String {
//        return holdingBalancePercent
//    }
//    
//    func p_currentAmount() -> String {
//        return currentAmount
//    }
}

class YXJYHoldShortSellModel: YXModel {
    
    @objc var costPrice: String? = ""
    @objc var curHoldNum: String? = ""
    @objc var code: String? = ""
    @objc var name: String? = ""
    @objc var exchangeType: Int = 0
    @objc var marketValue: String? = ""
    @objc var lastPrice: String? = ""
    @objc var imBalance: String? = ""
    @objc var holdingProfit: String? = ""
    @objc var holdingProfitPercent: String? = ""
    @objc var todayProfit: String? = ""
    @objc var todayProfitPercent: String? = ""
    @objc var capitalBalance: String? = ""
    @objc var id: Int64 = 0
    @objc var moneyType: Int = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXJYHoldOptionModel: YXModel {
    
    @objc var buyPrice: String? = ""
    @objc var code: String? = ""
    @objc var currentAmount: String? = ""
    @objc var dailyBalance: String? = ""
    @objc var dailyBalancePercent: String? = ""
    @objc var holdType: Int = 0
    @objc var holdingBalance: String? = ""
    @objc var holdingBalancePercent: String? = ""
    @objc var holdingPercent: String? = ""
    @objc var id: String? = ""
    @objc var lastPrice: String? = ""
    @objc var marketValue: String? = ""
    @objc var moneyType: Int = 0
    @objc var multiplier: String? = ""
    @objc var name: String? = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXJYHoldFundModel: YXModel {
    
    @objc var fundCode : String = ""
    @objc var fundId : String = ""
    @objc var fundName : String = ""
    @objc var holdingBalance : String = ""
    @objc var inTransitAmount : String = ""
    @objc var lastPrice : String = ""
    @objc var marketValue : String = ""
    @objc var positionShare : String = ""
    @objc var preEarningBalance : String = ""
    @objc var redeemDeliveryShare : String = ""
    @objc var status : Int = 0
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXJYHoldBondModel : YXModel {

//    @objc var availableQuantity : String = ""
//    @objc var bondId : String = ""
//    @objc var bondCode : String = ""
//    @objc var bondName : String = ""
//    @objc var costPrice : String = ""
//    @objc var currency : YXBondHoldCurrency = YXBondHoldCurrency()
//    @objc var frozenQuantity : String = ""
//    @objc var market : YXBondHoldMarket = YXBondHoldMarket()
//    @objc var marketValue : String = ""
//    @objc var positionQuantity : String = ""
//    @objc var price : String = ""
//    @objc var profit : String = ""
//    @objc var profitRatio : String = ""
//    @objc var totalProfit : String = ""
//    @objc var totalProfitRatio : String = ""
    
    
    @objc var bondCode: String? = ""
    @objc var bondId: String? = ""
    @objc var bondName: String? = ""
    // 成本价
    @objc var costPrice: String? = ""
    // 持仓数量
    @objc var currentAmount: String? = ""
    // 当日盈亏金额
    @objc var dailyBalance: String? = ""
    // 当日盈亏占比
    @objc var dailyBalancePercent: String? = ""
    @objc var exchangeType: Int = 0
    // 历史市值
    @objc var hisMarketValue: String? = ""
    // 持仓盈亏金额
    @objc var holdingBalance: String? = ""
    // 持仓盈亏占比
    @objc var holdingBalancePercent: String? = ""
    // 最新价
    @objc var lastPrice: String? = ""
    // 市值
    @objc var marketValue: String? = ""
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:];
    }
}

class YXJYDTOModel : YXModel {
    @objc var stockCode: String? = ""
    @objc var holdDTOList: [YXJYHoldStockModel] = []
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["holdDTOList": YXJYHoldStockModel.self]
    }
}

class YXJYHoldHistoryModel : YXModel {
    @objc var list: [YXIntradayHoldHistoryStockModel] = []
    @objc var total: Int = 0
    @objc var nowDate: String = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXIntradayHoldHistoryStockModel.self]
    }
}

class YXIntradayHoldHistoryStockModel : YXModel {
    @objc var stockCode: String? = ""
    @objc var stockName: String? = ""
    @objc var list: [YXIntradayHoldHistoryModel] = []
    @objc var heaverRatio: String? = ""
    @objc var trade: String? = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXIntradayHoldHistoryModel.self]
    }
}

class YXIntradayHoldHistoryModel: YXModel {
    @objc var seqNo: String? = ""
    @objc var stockCode: String? = ""
    @objc var stockName: String? = ""
    @objc var buyNum: String? = ""
    @objc var buyPrice: String? = ""
    @objc var sellPrice: String? = ""
    @objc var cashAmount: String? = ""
    @objc var totalHoldingBalance: String? = ""
    @objc var totalHoldingProportion: String? = ""

    @objc var buyFristTime: String? = ""
    @objc var closeTime: String? = ""
    @objc var day:  Int = 0
    
    @objc var heaverRatio: String? = ""
    @objc var mid:String = ""
    @objc var heaverRatioDecimal: Double = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["mid":"id"]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXJYHoldStockModel.self]
    }
}
