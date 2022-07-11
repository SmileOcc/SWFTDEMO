//
//  YXStockSTModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXMultiassetModel: Codable {
    let multiasset: [YXStockMultiasset]?
    
    enum CodingKeys: String, CodingKey {
        case multiasset
    }
}

@objcMembers class YXStockSTModel: NSObject, Codable {
    //let multiasset: [YXStockMultiasset]?
    let strategyList: [YXStockStrategyList]?
    let priceBase: Int?

    enum CodingKeys: String, CodingKey {
        case strategyList = "strategy_list"
        //case multiasset
        case priceBase = "price_base"
    }
}

// MARK: - StrategyList
@objcMembers class YXStockStrategyList: NSObject, Codable {
    let strategyType: Int? // 1：长线策略 2：短线策略 3：ETF策略
    let etfstrategy: YXStockEtfstrategy?
    let longstrategy: YXStockLongstrategy?
    let shortstrategy: YXStockShortstrategy?
    let manstrategy: YXStockLongstrategy?

    enum CodingKeys: String, CodingKey {
        case strategyType = "strategy_type"
        case etfstrategy, shortstrategy, longstrategy, manstrategy
    }
}

// MARK: - Etfstrategy
@objcMembers class YXStockEtfstrategy: NSObject, Codable {
    let strategyID, strategyVersion: Int?
    let strategyType: Int?
    let strategyName, briefInstruction: String?
    let strategyTags: [String]?
    let accureturnRate: Int?
    let senior: Int? //是否是高级账户策略  1：是 0：否
    let popTag: String? //精选

    var returnrateModel: YXStockSTReturnRateModel? //APP定义参数，内部使用

    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"
        case strategyVersion = "strategy_version"
        case strategyType = "strategy_type"
        case strategyName = "strategy_name"
        case strategyTags = "strategy_tags"
        case briefInstruction = "brief_instruction"
        case accureturnRate = "accureturn_rate"
        case senior
        case returnrateModel
        case popTag = "pop_tag"
    }
}


@objcMembers class YXStockEtfStock: NSObject, Codable {
    let secuCode, secuName, percentage, increase: String?

    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case secuName = "secu_name"
        case percentage, increase
    }
}

//MARK:长线策略
@objcMembers class YXStockLongstrategy: NSObject, Codable {
    let strategyID, strategyVersion: Int?
    let strategyType: Int?
    let strategyName: String?
    let strategyTags: [String]?
    let accureturnRate: Int?
    let briefInstruction: String?
    let senior: Int? //是否是高级账户策略  1：是 0：否
    let popTag: String? //精选

    var returnrateModel: YXStockSTReturnRateModel? //APP定义参数，内部使用
    
    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"                     //策略id
        case strategyVersion = "strategy_version"           //策略版本号
        case strategyType = "strategy_type"                 // 策略类型  1-手工策略 2-自动策略
        case strategyName = "strategy_name"                 //策略名（简体或繁体）
        case strategyTags = "strategy_tags"                 //策略标签（逗号分隔，客户端拆分展示）
        case accureturnRate = "accureturn_rate"             //累计收益率
        case briefInstruction = "brief_instruction"         //策略描述
        case senior                                         //是否是高级账户策略  1：是 0：否
        case returnrateModel
        case popTag = "pop_tag"
    }
}

@objcMembers class YXStockSTLongStock: NSObject, Codable {
    let secuCode: String?           //股票代码
    let secuName: String?           //股票名
    let selPrice: String?           //入选价
    let selDate: String?            //入选时间
    let returnRate: String?         //收益率
    let returnRateNdays: String?    //近N天收益率
    let curPrice: String?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case secuName = "secu_name"
        case selPrice = "sel_price"
        case selDate = "sel_date"
        case returnRate = "return_rate"
        case returnRateNdays = "return_rate_Ndays"
        case curPrice = "cur_price"
    }
}
//MARK:短线策略
@objcMembers class YXStockShortstrategy: NSObject, Codable {
    let strategyID, strategyVersion: Int?
    let strategyType: Int?
    let strategyName: String?
    let strategyTags: [String]?
    let winRate: Int?
    let averageIncrRate: Int?
    let profitRate: Int?
    let briefInstruction: String?       //策略描述（主页暂时无用）
    let senior: Int? //是否是高级账户策略  1：是 0：否
    let popTag: String? //精选
    
    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"
        case strategyVersion = "strategy_version"
        case strategyType = "strategy_type"
        case strategyName = "strategy_name"
        case strategyTags = "strategy_tags"
        case winRate = "win_rate"
        case averageIncrRate = "average_incr_rate"
        case profitRate = "profit_rate"
        case briefInstruction = "brief_instruction"
        case senior
        case popTag = "pop_tag"
    }
}

@objcMembers class YXStockSTShortStock: NSObject, Codable {
    let secuCode, secuName, selPrice, stopPrice, lossPrice: String?
    let stopProfit: Int?
    let stopStatus: Int? //止盈/止损状态：0：否；1：止盈 2：止损
    let incRate, hincRate: String?
    
    enum CodingKeys: String, CodingKey {
        case secuCode = "secu_code"
        case secuName = "secu_name"
        case selPrice = "sel_price"
        case stopPrice = "stop_price"
        case stopProfit = "stop_profit"
        case incRate = "inc_rate"
        case hincRate = "hinc_rate"
        case lossPrice = "loss_price"
        case stopStatus = "stop_status"
    }
}

@objcMembers class YXStockAuth: NSObject, Codable {
    let strategyGroup: Int?
    let isAuth: Int
    let tips: String?
    
    enum CodingKeys: String, CodingKey {
        case strategyGroup = "strategy_group"
        case isAuth = "is_auth"
        case tips = "tips"
    }
}

//MARK:短线策略
@objcMembers class YXStockManstrategy: NSObject, Codable {
    let strategyID, strategyVersion: Int?
    let strategyType: Int?
    let strategyName: String?
    let strategyTags: [String]?
    let briefInstruction: String?       //策略描述（主页暂时无用）
    let senior: Int? //是否是高级账户策略  1：是 0：否
    let accureturnRate: Int?

    var returnrateModel: YXStockSTReturnRateModel? //APP定义参数，内部使用

    enum CodingKeys: String, CodingKey {
        case strategyID = "strategy_id"
        case strategyVersion = "strategy_version"
        case strategyType = "strategy_type"
        case strategyName = "strategy_name"
        case strategyTags = "strategy_tags"
        case briefInstruction = "brief_instruction"
        case senior
        case accureturnRate = "accureturn_rate"
    }
}

//MARK: 多元资产专栏
@objcMembers class YXStockMultiasset: NSObject, Codable {
    let clomunID: Int
    let columnHeading: String?
    let columnSubhead: String?
    let blocks: [YXStockMultiassetBlocks]?
    
//    func maxHeight() -> CGFloat {
//        var maxHeight: CGFloat = 0
//        if let list = blocks, list.count > 0 {
//            let textWidth = 240 - 20 * 2 - 5 - 70
//            for (_, block) in list.enumerated() {
//                let height = NSString(string: block.topStockName ?? "").boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)], context: nil).size.height
//                if maxHeight < height {
//                    maxHeight = height
//                }
//            }
//        }
//        return maxHeight
//    }
    
    enum CodingKeys: String, CodingKey {
        case clomunID = "clomun_id"
        case columnHeading = "column_heading"
        case columnSubhead = "column_subhead"
        case blocks
    }
}

@objcMembers class YXStockMultiassetBlocks: NSObject, Codable {
    let blockID: Int
    let blockHeading: String?
    let blockSubhead: String?
    let blockWeight: Float?
    let topStockID: String?
    let topStockName: String?
    let topStockPrice: String?
    let topStockRate: String?
    let icon: String? //只针对港股
    let topStockMarket: String?
    
    enum CodingKeys: String, CodingKey {
        case blockID = "block_id"
        case blockHeading = "block_heading"
        case blockSubhead = "block_subhead"
        case blockWeight = "block_weight"
        case topStockID = "top_stock_id"
        case topStockName = "top_stock_name"
        case topStockPrice = "top_stock_price"
        case topStockRate = "top_stock_rate"
        case icon = "icon"
        case topStockMarket = "top_stock_market"
    }
}
