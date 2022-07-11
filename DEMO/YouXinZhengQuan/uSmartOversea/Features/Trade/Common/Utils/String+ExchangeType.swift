//
//  String+ExchangeType.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

extension NSString {
    @objc var exchangeType: YXExchangeType {
        get {
            return (self as String).exchangeType
        }
    }
    
    @objc var coinName: String {
        get {
            return (self as String).coinName
        }
    }
    
    @objc class func market(exchangeType: YXExchangeType) -> String {
        switch exchangeType {
        case .hk:
            return kYXMarketHK
        case .us:
            return kYXMarketUS
        case .sh:
            return kYXMarketChinaSH
        case .sz:
            return kYXMarketChinaSZ
        case .usop:
            return kYXMarketUsOption
        case .hs:
            return kYXMarketChinaHS
        default:
            return kYXMarketHK
        }
    }
    
    @objc var tradeOrderType: TradeOrderType {
        get {
            return (self as String).tradeOrderType
        }
    }
}

extension String {
    var exchangeType: YXExchangeType {
        get {
            let marketType = YXMarketType(rawValue: self)
            switch marketType {
            case .HK:
                return .hk
            case .US:
                return .us
            case .ChinaSH:
                return .sh
            case .ChinaSZ:
                return .sz
            case .ChinaHS:
                return .hs
            case .USOption:
                return .usop
            case .SG:
                return .sg
            default:
                return .hk
            }
        }
    }
    
    var coinName: String {
        get {
            return exchangeType.coinName
        }
    }
    
    var tradeOrderType: TradeOrderType {
        switch self {
        case TradeOrderType.limit.entrustPropOld,
             TradeOrderType.limit.entrustProp:
            return .limit
        case TradeOrderType.limitEnhanced.entrustPropOld,
             TradeOrderType.limitEnhanced.entrustProp:
            return .limitEnhanced
        case TradeOrderType.market.entrustPropOld,
            TradeOrderType.market.entrustProp:
            return .market
        case TradeOrderType.bidding.entrustPropOld,
             TradeOrderType.bidding.entrustProp:
            return .bidding
        case TradeOrderType.limitBidding.entrustPropOld,
             TradeOrderType.limitBidding.entrustProp:
            return .limitBidding
//        case TradeOrderType.condition.entrustProp,
//             TradeOrderType.condition.entrustProp:
//            return .condition
        case TradeOrderType.smart.entrustPropOld,
             TradeOrderType.smart.entrustProp:
            return .smart
        case TradeOrderType.broken.entrustPropOld,
             TradeOrderType.broken.entrustProp:
            return .broken
        default:
            return .limitEnhanced
        }
    }
}

