//
//  YXETFBriefModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXETFBriefModel: NSObject {

    @objc var basicInfo: YXETFBriefBasicInfo?
    @objc var returnsInfo: [YXETFBriefReturnsInfo]?
    @objc var elementInfo: [YXUSElementItemModel]?
    @objc var elementChangeInfo: [YXUSElementChangeItemModel]?

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["basicInfo": YXETFBriefBasicInfo.self,
                "returnsInfo": YXETFBriefReturnsInfo.self,
                "elementInfo": YXUSElementItemModel.self,
                "elementChangeInfo": YXUSElementChangeItemModel.self]
    }
}

@objcMembers class YXETFBriefBasicInfo: NSObject {

    @objc var uniqueSecuCode: String = "" //证券唯一编码
    @objc var name: String = ""  //etf名称
    @objc var publisher: String = ""  //发行商

    //港股独有
    @objc var listedDate: String = "" //上市日期
    @objc var targetIndex: String = "" //追踪指数
    @objc var dividendPolicy: String = "" //派息政策
    @objc var investTarget: String = "" //投资目标
    @objc var totalAssetnv: Double = 0 //基金规模
    @objc var totalAssetnvCurrency: Int = 0 //基金规模币种
    @objc var totalFeeRatio: Double = 0 //费用占比
    @objc var unitNv: Double = 0 //资产净值
    @objc var unitNvCurr: Int = 0 //资产净值单位

    //美股独有
    @objc var custodian: String = "" //管理人
    @objc var introduction: String = "" //etf简介
    @objc var issueDate: String = "" //发行时间
    //@objc var endOfFiscalYear: Int = 0 //财年结束日
    @objc var leverage: Int = 0 //杠杆
    @objc var rateFrequency: String = "" //分红频率
}

@objcMembers class YXETFBriefReturnsInfo: NSObject {

    @objc var uniqueSecuCode: String = "" //证券唯一编码

    @objc var rrinSingleWeek: String = "" //本周以来回报率
    @objc var rrinSingleMonth: String = "" //本月以来回报率
    @objc var rrinThreeMonth: String = "" //三个月以来回报率
    @objc var rrinSixMonth: String = "" //六个月以来回报率
    @objc var rrinSingleYear: String = "" //一年以来回报率
    @objc var rrSinceThisYear: String = "" //今年以来回报率
}

