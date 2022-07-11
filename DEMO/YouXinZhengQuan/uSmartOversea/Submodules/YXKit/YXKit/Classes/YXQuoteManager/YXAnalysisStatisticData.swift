//
//  YXAnalysisStatisticData.swift
//  AFNetworking
//
//  Created by Mac on 2019/11/18.
//

import UIKit

@objcMembers public class YXAnalysisStatisticData: NSObject, Codable {
    public let priceBase: NumberUInt32?         // 价格小数计算基数，10的幂次表示
    public let avgTradePrice: NumberUInt32?     //平均成交价
    public let totalTradeVol: NumberUInt64?     //总成交量
    public let totalTradeCount: NumberUInt32?   // 总成交笔数
    public let totalAskCount: NumberUInt32?     // 主动卖出股数
    public let totalBidCount: NumberUInt32?     // 主动买入股数
    public let totalBothCount: NumberUInt32?    // 中性盘股数
    public var priceData: [YXAnalysisStatisticPrice]?   // 量价分布行情数据
    public let nextPageRef: NumberUInt32?       //翻页使用，请求下一页时候，需要带上这个值
    public let hasMore: Bool?                   //bool值，是否有下一页数据
}

@objcMembers public class YXAnalysisStatisticPrice: NSObject, Codable {
    public let tradePrice: NumberUInt32?    //价格
    public let volume: NumberUInt32?        //成交量
    public let askSize: NumberUInt32?       //主卖成交量
    public let bidSize: NumberUInt32?       //主买成交量
    public let bothSize: NumberUInt32?      //平盘成交量
    public let rate: NumberUInt32?          //占总成交量比例，使用时除100
}


