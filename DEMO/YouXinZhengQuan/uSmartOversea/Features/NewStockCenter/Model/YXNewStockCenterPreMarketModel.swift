//
//  YXNewStockCenterPreMarketModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockCenterPreMarketModel: Codable {
    let pageNum: Int?
    let pageSize: Int?
    let total: Int?
    let list: [YXNewStockCenterPreMarketStockModel]?
}

public enum YXStocklabelStatus: Int {
    case purchase = 0, wined, notWined, financeApplying,  none
}

extension YXStocklabelStatus: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXStocklabelStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
    }
}

class YXNewStockCenterPreMarketStockModel: Codable {
    
    ///ipoId
    let ipoId: String?
    
    let appliedCount: Int?
    
    ///市场类型(0-港股, 5-us)
    let exchangeType: Int?
    
    ///新股代码
    let stockCode: String?
    
    ///新股名称
    let stockName: String?
    
    ///标签状态(0-已认购,1-已中签,2-未中签)
    let labelStatus: Int?

    let labelStatusName: String?

    ///公开认购起购金额， 入场费
    let leastAmount: Double?
    
    ///最高招股价
    let priceMax: Double?
    
    ///最低招股价
    let priceMin: Double?
    
    ///认购截止日期
    let endTime: String?
    
    let englishName: String?
    ///认购剩余时间（秒）
    let remainingTime: Int?
    
    ///公布中签日期
    let publishTime: String?
    
    ///中签率
    let successRate: Double?
    
    ///认购倍数
    let bookingRatio: Double?
    
    //上市日期
    let listingTime: String?
    
    ///服务器时间
    let serverTime: String?
    
    let focusCount: Int?
    
    let ipoSpecialInfos: [String]?
    
    let moneyType: Int?
    
    let status: Int?
    
    let statusName: String?
    
    //融资倍数
    let financingMultiple: Int?
    
    //融资截止时间
    let financingEndTime: String?
    
    //最晚截止时间（服务器对比现金和融资认购，算好了的时间）
    let latestEndtime: String?
    
    //认购方式，多种认购用,隔开，比如1,2支持现金和融资(1-公开现金认购，2-公开融资认购，3-国际配售)-这个字段可以判断是否支持融资认购
    let subscribeWay: String?
    
    //国际认购结束时间
    let ecmEndTime: String?
    
    let ecmStatus: Int? //ecm新股状态(0-待认购,1-认购中，2-待扣款，3-待扣款[未全部扣款成功]，4-待提交，5-待分配，6-待返款，7-待返款[未全部返款成功]，8-待返券，9-待返券[未全部返券成功]，10-待CCASS确认，11-待上市，12-已上市，13-暂停认购, 15-认购确认中，16-撤销确认中)
    
    let ecmLeastAmount: Double? //国际认购起购资金, 入场费
    
    let piFlag: Int? //专业投资者标志 0-不需要，1-需要
    
    let ecmLabelV2: String?
    
    let piTag: Int? //PI标签 0-不是，1-是
    
    let piTagName: String? //PI标签名称
    
    let listExchanges: String? //交易所
    
    let topStatus: Int? //是否置顶

    let openApplyInfo: Int? //是否可以打开认购详情页 0-否， 1-是

    let tagList: [YXNewStockTagList]? //标签列表

    let financingAccountDiff: Int? //是否区分普通高级账户 0-不区分，1-区分
    
    let ordinaryFinancingMultiple: Int? //普通用户融资倍数，可能返回 null
}

class YXNewStockTagList: Codable {

    let seniorFlag: Int?    //0-普通账户，1-高级账户
    let tagText: String?    //标签文案
    let tagType: Int?       //tag类型(0-其他，1-融资倍数，2-融资利率，3-国际配售，4-PI)
}
