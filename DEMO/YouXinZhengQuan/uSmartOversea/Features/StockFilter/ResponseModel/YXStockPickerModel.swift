//
//  YXStockPickerModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import Foundation

// MARK: - YXStockPickerModel
class YXStockPickerModel: NSObject {
    @objc var list: [YXStockPickerList]?
    @objc var count: Int = 0
    @objc var nextPageFrom: Int = 0
    @objc var hasMore: Bool = false

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXStockPickerList.self]
    }
}

// MARK: - YXStockPickerList
class YXStockPickerList: YXModel {

    @objc var isSelected = false
    @objc var ah: Int = 0   //是否ah股，0：否、1：是。
    @objc var amount: Int64 = 0 //成交额
    @objc var biYoyGRatio: Double = 0 //营收同比增长率
    @objc var businessIncome: Double = 0 //营业收入
    @objc var bvps: Double = 0 //每股净资产
    @objc var cittThan: Double = 0
    @objc var code: String = ""
    @objc var divYield: Double = 0 //股息率
    @objc var eps: Double = 0 //每股收益
    @objc var exchange: String = ""
    @objc var floatCap: Double = 0   //流通市值
    @objc var floatShare: Double = 0  //流通股本
    @objc var hkschs: Int = 0  //港股通
    @objc var hsschk: Int = 0  //陆股通
    @objc var index: [YXStockPickerIndustryModel]? //所属指数
    @objc var industry: YXStockPickerIndustryModel?  //所属行业
    @objc var insertTime: Int64 = 0
    @objc var issuedShare: Double = 0  //总股本
    @objc var latestTime: Int64 = 0
    @objc var listDate: Int64 = 0 //上市日期
    @objc var mainInflow: Double = 0 //主力净流入
    @objc var margin: Int = 0 //可融资，0：不可融资，1：可融资。
    @objc var market: String = ""  //市场
    @objc var mktCap: Double = 0 //总市值
    @objc var name: String = ""
    @objc var netIncomeGRatio: Double = 0 //净利润同比增长率
    @objc var netIncomeLtm: Double = 0 //净利润
    @objc var pb: Double = 0 //市净率
    @objc var pctchng: Double = 0 //涨跌幅
    @objc var netchng: Double = 0 //涨跌额
    @objc var pe: Double = 0 //静态市盈率
    @objc var peTTM: Double = 0 //市盈率TTM
    @objc var price: Double = 0 //价格
    @objc var priceBase: Double = 0
    @objc var rangeChng10Day: Double = 0  //近10日涨跌幅
    @objc var rangeChng120Day: Double = 0 //近120日涨跌幅
    @objc var rangeChng250Day: Double = 0 //近250日涨跌幅
    @objc var rangeChng30Day: Double = 0 //近30日涨跌幅
    @objc var rangeChng5Day: Double = 0  //近5日涨跌幅
    @objc var rangeChng60Day: Double = 0 //近60日涨跌幅
    @objc var rangeChngThisYear: Double = 0 //今年以来涨跌幅
    @objc var roa: Double = 0  //总资产收益率
    @objc var roe: Double = 0 //净资产收益率
    @objc var turnoverRate: Double = 0 //换手率
    @objc var volRatio: Double = 0  //量比
    @objc var volume: Int64 = 0 //成交量
    @objc var board: [String]? //市场 主板、创业板、沪深A股等


    override class func modelCustomPropertyMapper() -> [String : Any]! {
        [:]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["index": YXStockPickerIndustryModel.self, "industry": YXStockPickerIndustryModel.self]
    }

}


class YXStockPickerIndustryModel: YXModel {

    @objc var code: String?
    @objc var market: String?
    @objc var name: String?
    @objc var type1: Int = 0
    @objc var type2: Int = 0
    @objc var type3: Int = 0

    override class func modelCustomPropertyMapper() -> [String : Any]! {
        [:]
    }

}
