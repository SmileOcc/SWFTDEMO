//
//  File.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/1/8.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation


@objc enum TradeType: Int {
    case normal     //正常交易
    case shortSell  //做空交易
    case intraday   //日内融交易
    case fractional //零碎股交易
}

@objc enum TradeStatus: Int {
    case normal
    case change     //改单
    case limit      //只买 ，只卖
    case cancel     //撤单
}


@objcMembers class TradeModel: NSObject {
    var tradeType: TradeType = .normal              //交易类型
    var tradeStatus: TradeStatus = .normal          //交易状态
    var tradeOrderType: TradeOrderType = .limit     //订单类型
    var direction: TradeDirection = .buy            //方向
    var market: String = "" {                       //市场
        didSet {
            currency = YXToolUtility.currency(market: market)
            if market == "hs" {
                market = "sh"
            }
        }
    }
    var currency: String = ""                       //货币单位
    var symbol: String = ""                         //代码
    var name: String = ""                           //名称
    var entrustPrice: String = ""                   //委托价格
    var entrustQuantity: String = ""                  //委托数量
    
    //var sessionType: Int = 0                      //交易阶段标志（0/不传-正常订单交易（默认），1-盘前，2-盘后交易，3-暗盘交易, 12-允许盘前盘后交易）
    var tradePeriod: TradePeriod = .normal          //交易时段N-正常下单交易,G-暗盘交易,盘前盘后:AB,默认:正常

    var powerInfo: PowerInfo?                       //购买力
    var canMargin: Bool = false                     //是否支持margin
    var condition: ConditionModel = ConditionModel() //条件(智能订单、条件单)
    
    var entrustId: String?                          //委托Id
    var latestPrice: String?                        //最新价
    var trdUnit: UInt32?                            //每手股数
    
    var multiplier: Int32?                          //合约乘数,美股期权用
    
    var fractionalTradeType: FractionalTradeType = .amount      //碎股交易类型
    var fractionalAmount: String = ""                //碎股金额
    var fractionalQuantity: String = ""              //碎股数量

    var isDerivatives: Bool = false                 //用于衍生品风险提示
    
}

extension TradeModel {
    var useMargin: Bool {
        guard let powerInfo = powerInfo, direction == .buy, canMargin else {
            return false
        }
        
        if tradeType == .fractional {
            if fractionalTradeType == .amount,
               fractionalAmount.doubleValue > powerInfo.cashPurchasingPower.doubleValue {
                return true
            }
        }else {
            if entrustQuantity.doubleValue > powerInfo.cashEnableAmount,
               powerInfo.cashEnableAmount != -1,
               powerInfo.marginEnableAmount > 0 {
                return true
            }
        }

        return false
    }
}

@objcMembers class ConditionModel: NSObject {
    var amountIncrease: NSDecimalNumber?            //涨幅
    var conditionPrice: String?                     //触发价格
    var conditionOrderType: TradeOrderType = .limit //触发订单类型
    var smartOrderType: SmartOrderType = .normal    //智能订单类型(0:价格触发，1:止盈卖出，2:止损卖出，3:高价卖出，4:低价买入, 7, 11, 12)
//    var strategyEnddate: String = ""              //条件单有效时间 "yyyyMMddHHmmss"
    var strategyEnddateTitle: String = ""           //条件单有效时间 "收盘前有效"
    var strategyEnddateYearMsg: String = ""         //条件单有效时间 "yyyy-MM-dd HH:mm后失效"
    var strategyEnddateDesc: String = ""            //条件单有效时间 (1, 2, 3, 4, 5, 6, 9, 10)
    var conditionExtendDTO: ConditionExtendDTO = ConditionExtendDTO() //扩展
    var releationStockCode: String?                 //关联正股
    var releationStockMarket: String?               //关联正股市场
    var releationStockName: String?                 //关联正股名字
    var releationStockCurrency: String?             //关联货币单位
    var dropPrice: String?                          //跟踪止损价差
    var entrustGear: GearType = .entrust            //跟踪止损触发委托挡位, 最新价 0, 买一档 1, 买五档2, 卖一档3, 卖五档4,市场价5
    var highestPrice: String?                       //跟踪止损的最高价
    var trackMarketPrice: String?                   //关联股票市价
}

@objcMembers class ConditionExtendDTO: NSObject {
    var buyCondition: NSNumber?                     //买一档条件，0：> ，1：<
    var buyQuantity: NSNumber?                      //买一档数量（股）
    var buySellCondition: NSNumber?                 //买卖条件：0或，1且
    var quotationSource: NSNumber?                  //行情来源，0：自身行情 1：正股行情
    var sellCondition: NSNumber?                    //卖一档条件，0：> ，1：<
    var sellQuantity: NSNumber?                     //卖一档数量（股）
}

@objc enum GearType: Int {
    case ask_5      = 4
    case ask_1      = 3
    case latest     = 0
    case market     = 5
    case bid_1      = 1
    case bid_5      = 2
    case entrust    = 6
}

protocol EnumTextProtocol {
    var text: String { get }
}

@objc enum TradeOrderType: Int {
    case limit          // 限价单
    case limitEnhanced  // 增强限价单
    case market         // 市价单
    case bidding        // 竞价单
    case limitBidding   // 竞价限价单
//    case condition      // 条件单
    case smart          // 智能下单
    case broken         // 碎股单
    
    var entrustPropOld: String {
        switch self {
        case .limit:
            return "0"
        case .limitEnhanced:
            return "e"
        case .market:
            return "w"
        case .bidding:
            return "d"
        case .limitBidding:
            return "g"
        case .broken:
            return "u"
        default:
            return ""
        }
    }
    
    var entrustProp :String {
        switch self {
        case .limit:
            return "LMT"
        case .limitEnhanced:
            return "ELMT"
        case .market:
            return "MKT"
        case .bidding:
            return "AM"
        case .limitBidding:
            return "AL"
        default:
            return ""
        }
    }
    
}

extension TradeOrderType: EnumTextProtocol {
    
    var text: String {
        switch self {
        case .limit:
            return YXLanguageUtility.kLang(key: "limit_order")
        case .limitEnhanced:
            return YXLanguageUtility.kLang(key: "limit_enhanced_order")
        case .market:
            return YXLanguageUtility.kLang(key: "trade_market_order")
        case .bidding:
            return YXLanguageUtility.kLang(key: "bidding_order")
        case .limitBidding:
            return YXLanguageUtility.kLang(key: "limit_bidding_order")
//        case .condition:
//            return YXLanguageUtility.kLang(key: "condition_order")
        case .smart:
            return YXLanguageUtility.kLang(key: "trading_smart_order")
        case .broken:
            return YXLanguageUtility.kLang(key: "broken_order")
        }
    }
}

@objc enum SmartOrderType: Int {
    case normal
    case breakBuy           =   1   //突破买入
    case lowPriceBuy        =   2   //低价买入
    case highPriceSell      =   3   //高价卖出
    case breakSell          =   4   //跌破卖出
    
    case stopProfitSell     =   5   //止盈卖出
    case stopLossSell       =   6   //止损卖出
    case tralingStop        =   7   //跟踪止损
    case stockHandicap      =   8   //关联资产触发

    case priceHandicap          //价格盘口触发
    case grid
    case intradayPrice          //日内融价格智能单

    case stopProfitSellOption   //期权止盈卖出
    case stopLossSellOption     //期权止损卖出
}

extension SmartOrderType {
    var direction: TradeDirection {
        switch self {
        case .breakSell,
             .highPriceSell,
             .stopProfitSell,
             .stopLossSell,
             .tralingStop:
            return .sell
        default:
            return .buy
        }
    }
    
    static let portfolioTypes: [SmartOrderType] = [.stopProfitSell, .stopProfitSellOption, .stopLossSell, .stopLossSellOption, .tralingStop]
}

extension SmartOrderType: EnumTextProtocol {
    
    var text: String {
        switch self {
        case .stopProfitSell,
             .stopProfitSellOption:
            return YXLanguageUtility.kLang(key: "trading_stop_profit_sell_order")
        case .stopLossSell,
             .stopLossSellOption:
            return YXLanguageUtility.kLang(key: "trading_stop_loss_sell_order")
        case .highPriceSell:
            return YXLanguageUtility.kLang(key: "trading_high_price_sell_order")
        case .lowPriceBuy:
            return YXLanguageUtility.kLang(key: "trading_low_price_buy_order")
        case .breakBuy:
            return YXLanguageUtility.kLang(key: "trading_break_buy_order")
        case .breakSell:
            return YXLanguageUtility.kLang(key: "trading_break_sell_order")
        case .priceHandicap:
            return YXLanguageUtility.kLang(key: "trigger_bid_ask_price")
        case .stockHandicap:
            return YXLanguageUtility.kLang(key: "trigger_follow_stock")
        case .tralingStop:
            return YXLanguageUtility.kLang(key: "trading_traling_stop")
        case .grid:
            return YXLanguageUtility.kLang(key: "grid_trade_order_title")
        case .intradayPrice:
            return YXLanguageUtility.kLang(key: "intraday_smart_type_price")
        default:
            return ""
        }
    }
}

@objc enum TradeDirection: Int {
    case buy
    case sell
    
    var color: UIColor {
        switch self {
        case .buy:
            return QMUITheme().stockRedColor()
        case .sell:
            return QMUITheme().stockGreenColor()
        }
    }
    
    var entrustSide : String{
        switch self {
        case .buy:
            return "B"
        case .sell:
            return "S"
        }
    }
    
}


extension TradeDirection: EnumTextProtocol {
    var text: String {
        switch self {
        case .buy:
            return YXLanguageUtility.kLang(key: "trade_buy")
        case .sell:
            return YXLanguageUtility.kLang(key: "trade_sell")
        }
    }
}
 
@objc enum TradePeriod: Int {
    case normal
    case grey
    case preAfter
}

extension TradePeriod {
    var stringValue: String {
        switch self {
        case .normal:
            return "N"
        case .grey:
            return "G"
        case .preAfter:
            return "AB"
        }
    }
}

@objc enum FractionalTradeType: Int {
    case amount = 2
    case shares = 1
}

extension FractionalTradeType: EnumTextProtocol {
    var text: String {
        switch self {
        case .amount:
            return YXLanguageUtility.kLang(key: "trade_amount")+" (\(YXLanguageUtility.kLang(key: "common_us_dollar")))"
        case .shares:
            return YXLanguageUtility.kLang(key: "trade_shares")
        }
    }
}

