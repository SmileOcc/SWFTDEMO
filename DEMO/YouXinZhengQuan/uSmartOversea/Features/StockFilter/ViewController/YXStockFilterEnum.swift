//
//  YXStockFilterEnum.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

@objc enum YXStockFilterOperationType: Int {
    // 新增
    case new = 0
    // 修改
    case edit
    // 删除
    case delete
    //我的选股查看
    case query = 99
}


@objc enum YXStockFilterItemType: Int {

    case none = 0

    //板块 主板，创业板， 沪深A股
    case board
    //市场
    case market
    //行业
    case industry
    //可融资
    case margin
    //指数成分
    case index
    //港股通
    case hkschs
    //AH股
    case ah
    //交易所
    case exchange
    //陆股通
    case hsschk

    // 总市值
    case mktCap
    // 总股本
    case issuedShare
    // 流通市值
    case floatCap
    // 流通股本
    case floatShare
    // 上市时间
    case listDate
    // 市盈率TTM
    case peTTM
    // 静态市盈率
    case pe
    // 市净率
    case pb
    // 每股收益
    case eps
    // 每股净资产
    case bvps
    // 净利润
    case netIncomeLtm
    // 净利润同比增长率
    case netIncomeGRatio
    // 营业收入
    case businessIncome
    // 营收同比增长率
    case biYoyGRatio
    // 净资产收益率
    case roe
    // 总资产收益率
    case roa
    // 股息率
    case divYield

    // 股价
    case price
    // 涨跌幅
    case pctchng
    // 涨跌额
    case netchng
    // 换手率
    case turnoverRate
    // 量比
    case volRatio
    // 委比
    case cittThan
    // 成交量
    case volume
    // 成交额
    case amount
    // 主力净流入
    case mainInflow
    // 区间涨幅
    case rangeChng

    //近5日涨跌幅
    case rangeChng5Day
    //近10日涨跌幅
    case rangeChng10Day
    //近30日涨跌幅
    case rangeChng30Day
    //近60日涨跌幅
    case rangeChng60Day
    //近120日涨跌幅
    case rangeChng120Day
    //近250日涨跌幅
    case rangeChng250Day
    //今年以来涨跌幅
    case rangeChngThisYear

}


class YXStockFilterEnumUtility: NSObject {

    @objc static let shared = YXStockFilterEnumUtility()

    let filterEnumDic: [String : YXStockFilterItemType] = [
        "board": .board,
        "market": .market,
        "industry": .industry,
        "margin": .margin,
        "index": .index,
        "hkschs": .hkschs,
        "ah": .ah,
        "exchange": .exchange,
        "hsschk": .hsschk,
        "mktCap": .mktCap,
        "issuedShare": .issuedShare,
        "floatCap": .floatCap,
        "floatShare": .floatShare,
        "listDate": .listDate,
        "peTTM": .peTTM,
        "pe": .pe,
        "pb": .pb,
        "eps": .eps,
        "bvps": .bvps,
        "netIncomeLtm": .netIncomeLtm,
        "netIncomeGRatio": .netIncomeGRatio,
        "businessIncome": .businessIncome,
        "biYoyGRatio": .biYoyGRatio,
        "roe": .roe,
        "roa": .roa,
        "divYield": .divYield,
        "price": .price,
        "pctchng": .pctchng,
        "netchng": .netchng,
        "turnoverRate": .turnoverRate,
        "volRatio": .volRatio,
        "cittThan": .cittThan,
        "volume": .volume,
        "amount": .amount,
        "mainInflow": .mainInflow,
        "rangeChng": .rangeChng,
        "rangeChng5Day": .rangeChng5Day,
        "rangeChng10Day": .rangeChng10Day,
        "rangeChng30Day": .rangeChng30Day,
        "rangeChng60Day": .rangeChng60Day,
        "rangeChng120Day": .rangeChng120Day,
        "rangeChng250Day": .rangeChng250Day,
        "rangeChngThisYear": .rangeChngThisYear
    ]

    //字符串匹配枚举
    @objc func enumFromString(_ match: String) -> YXStockFilterItemType {

        //        for (key, value) in self.filterEnumDic {
        //            if key == match {
        //                return value
        //            }
        //        }

        if !match.isEmpty, let value = self.filterEnumDic[match] {
            return value
        }
        return .none
    }

    //枚举匹配字符串
    @objc func stringFromEnum(_ match: YXStockFilterItemType) -> String {

        for (key, value) in self.filterEnumDic {
            if match == value {
                return key
            }
        }

        return "none"
    }


}
