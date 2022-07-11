//
//  YXMarketEnum.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//@objc enum YXSortState: Int {
//    case normal = 0, descending, ascending
//    
//    var image: UIImage? {
//           switch self {
//           case .normal:
//               return UIImage(named: "optional_sort")
//           case .ascending:
//               return UIImage(named: "optional_sort_ascending")
//           case .descending:
//               return UIImage(named: "optional_sort_descending")
//           }
//       }
//}

func yxSortImage(state: YXSortState) -> UIImage? {
    switch state {
    case .normal:
        return UIImage(named: "optional_sort")
    case .ascending:
        return UIImage(named: "optional_sort_ascending")
    case .descending:
        return UIImage(named: "optional_sort_descending")
    default:
        return nil
    }
}

enum YXStockRankSortType: Int {
    
    /**
     * 涨跌幅
     */
    case roc = 1;
    
    /**
     * 最新价
     */
    case now = 2;
    
    /**
     * 昨收价
     */
    case pclose = 3;
    
    /**
     * 成交量
     */
    case volume = 4;
    
    /**
     * 成交金额
     */
    case amount = 5;
    
    /**
     * 开盘价
     */
    case open = 6;
    
    /**
     * 最高价
     */
    case high = 7;
    
    /**
     * 最低价
     */
    case low = 8;
    
    /**
     * 股票代码
     */
    case stockCode = 9;
    
    /**
     * 换手率
     */
    case turnoverRate = 10;
    
    /**
     * 市盈率
     */
    case pe = 11;
    
    /**
     * 涨跌值
     */
    case change = 12;
    
    /**
     * 振幅
     */
    case amp = 14;
    
    /**
    * 总净流入
    */
    case netInflow = 16;
    
    case purchaseMoney = 18     //起购资金
    case purchaseEndDay = 19    //认购截止日
    
    /**
     * 市值
     */
    case marketValue = 20;
    
    /**
     * 市净率
     */
    case pb = 21;
    
    /**
     * 新股上市日期
     */
    case listDate = 22;
    
    /**
     * 新股发行价
     */
    case issuePrice = 23;
    
    /**
     * 新股上市天数
     */
    case listedDays = 24;
    
    /**
     * 首日收盘价
     */
    case firstDayClosePrice = 25;
    
    /**
     * 首日涨跌幅
     */
    case firstDayRoc = 26;
    
    /**
     * 累计涨跌幅
     */
    case totalRoc = 27;
    
    /**
    * 暗盘涨跌幅
    */
    case greyChgPct = 28;
    
    /**
    * 一手中签率
    */
    case winningRate = 29;
    
    /**
     * 量比
     */
    case volumeRatio = 40;
    
    /**
    * 3分钟涨速
    */
    case accer3 = 60;
    
    /**
    * 5分钟涨速
    */
    case accer5 = 15;
    
    /**
    * 股息率
    */
    case dividendYield = 61;
    
    /**
    * 主力净流入
    */
    case mainInflow = 62;
    
    /**
    * 资金流出
    */
    case outflow = 64;
    
    /**
    * 融资抵押率
    */
    case marginRatio = 65;
    
    /**
    * 最低保证金
    */
    case bail = 66;
    
    /**
    * 杠杆比例
    */
    case gearingRatio = 74;
    
    //买入价
    case bid     =  77;
    
    //买量
    case bidSize = 78;
    
    //卖出价
    case ask     =  79;
    
    //委比
    case cittthan = 80;
    
    //卖量
    case askSize = 81;
    
    //货币
    case currency  = 82;
    
    //到期日
    case expiryDate = 83;
    //股息
    case dividendsRate = 84;
    //股息率
    case dividendsYield = 85;
    /**
     * 到期日
     */
    case endDate = 101;
    
    /**
     * 溢价
     */
    case premium = 102;
    
    /**
     * 街货币
     */
    case outstandingRatio = 103;
    
    /**
     * 杠杆比率
     */
    case leverageRatio = 104;
    
    /**
     * 换股比率
     */
    case exchangeRatio = 105;
    
    /**
     * 行使价
     */
    case strikePrice = 106;
    
    /**
     * 持仓盈亏
     */
    case holdingBalance = 1001
    
    /**
     * 今日盈亏
     */
    case dailyBalance = 1002
    
    /**
     * 现价/成本
     */
    case lastAndCostPrice = 1003
    
    /**
     * 市值/数量
     */
    case marketValueAndNumber = 1004
    /**
     * 窝轮最新价
     */
    case warrantsNow = 107;
    
    /**
     * 价内价外
     */
    case moneyness = 1005;
    
    /**
     * 引申波幅
     */
    case impliedVolatility = 1006;
    
    /**
     * 实际杠杆
     */
    case actualLeverage = 1007;
    
    /**
     * 回收价
     */
    case callPrice = 1008;
    
    /**
     * 距回收价
     */
    case toCallPrice = 1009;
    
    /**
     * 下限价
     */
    case lowerStrike = 1010;
    
    /**
     * 上限价
     */
    case upperStrike = 1011;
    
    /**
     * 距下限
     */
    case toLowerStrike = 1012;
    
    /**
     * 距上线
     */
    case toUpperStrike = 1013;
    
    /**
     * 金額
     */
    case amountMoney = 1014;
    
    /**
     * 昨日收益
     */
    case yesterdayGains = 1015;
    /**
     * 持有收益
     */
    case holdGains = 1016;
    
    /**
     * 领涨股
     */
    case leadStock = 1017;
    
    /**
     * 友智评分
     */
    case yxScore = 1018;
    
    //已递表使用
    /**
     * 申请日期
     */
    case deliverApplyDate = 1101;
    
    /**
     *  状态
     */
    case deliverStatus = 1102;
    
    //港股ADR使用
    /**
     * ADR换算价
     */
    case adrExchangePrice = 1201;
    
    /**
     *  相对港股
     */
    case adrPriceSpread = 1202;
    
    /**
     *  adr港股价格
     */
    case adrPrice = 1203;
    
    /**
     *  ah股 H股
     */
    case hStock = 1204;
    
    /**
     *  ah股 A股
     */
    case aStock = 1205;
    
    /**
     *  ah股 溢价
     */
    case ahSpread = 1206;
    
    /**
     *  港股代码
     */
    case adrHKCode = 1207;
    
    /**
     *  盘前/收盘价
     */
    case preAndClosePrice = 1208;
    
    /**
     *  盘前涨跌幅
     */
    case preRoc = 1209;
    
    /**
     *  盘后/收盘价
     */
    case afterAndClosePrice = 1210;
    
    /**
     *  盘后涨跌幅
     */
    case afterRoc = 1211;

    /**
     *  对冲值
     */
    case delta
    
    /**
     *  状态 sg
     */
    case status
    
    case dividendsPriceChg
     

    
    
    var title: String {
        switch self {
        case .roc:
            return YXLanguageUtility.kLang(key: "market_roc")
        case .change:
            return YXLanguageUtility.kLang(key: "market_change")
        case .now:
            return YXLanguageUtility.kLang(key: "market_now")
        case .accer3:
            return YXLanguageUtility.kLang(key: "market_3mins_chg")
        case .accer5:
            return YXLanguageUtility.kLang(key: "interval_5_min_chg")
        case .volume:
            return YXLanguageUtility.kLang(key: "market_volume")
        case .amount:
            return YXLanguageUtility.kLang(key: "market_amount")
        case .mainInflow:
            return YXLanguageUtility.kLang(key: "market_high_netinflow")
        case .netInflow:
            return YXLanguageUtility.kLang(key: "market_total_netinflow")
        case .turnoverRate:
            return YXLanguageUtility.kLang(key: "market_turnoverRate")
        case .marketValue:
            return YXLanguageUtility.kLang(key: "stock_detail_marketValue")
        case .pe:
            return YXLanguageUtility.kLang(key: "stock_detail_pe")
        case .pb:
            return YXLanguageUtility.kLang(key: "stock_detail_pb")
        case .dividendYield:
            return YXLanguageUtility.kLang(key: "stock_detail_div_yield")
        case .volumeRatio:
            return YXLanguageUtility.kLang(key: "stock_detail_vol_ratio")
        case .amp:
            return YXLanguageUtility.kLang(key: "stock_detail_amplitude")
        case .yxScore:
            return YXLanguageUtility.kLang(key: "bullbear_yxscore")
        case .hStock:
            return YXLanguageUtility.kLang(key: "market_h_shares")
        case .aStock:
            return YXLanguageUtility.kLang(key: "market_a_shares")
        case .ahSpread:
            if YXUserManager.isENMode() {
                return YXLanguageUtility.kLang(key: "stock_detail_premium")+"\n(H/A)"
            }else {
                return YXLanguageUtility.kLang(key: "stock_detail_premium")+"(H/A)"
            }
            
        case .adrHKCode:
            return YXLanguageUtility.kLang(key: "market_adr_hkcode")
        case .marginRatio:
            return YXLanguageUtility.kLang(key: "market_margin_ratio")
        case .bail:
            return YXLanguageUtility.kLang(key: "market_bail")
        case .greyChgPct:
            return YXLanguageUtility.kLang(key: "marketed_stock_greyChgPct")
        case .winningRate:
            return YXLanguageUtility.kLang(key: "marketed_stock_winningRate")
        case .gearingRatio:
            return YXLanguageUtility.kLang(key: "day_maigin_gearing")
        case .preAndClosePrice:
            return YXLanguageUtility.kLang(key: "premarket_closing_price")
        case .preRoc:
            return YXLanguageUtility.kLang(key: "premarket_chg")
        case .afterAndClosePrice:
            return YXLanguageUtility.kLang(key: "after_closing_price")
        case .afterRoc:
            return YXLanguageUtility.kLang(key: "after_chg")
        case .cittthan:
            return YXLanguageUtility.kLang(key: "market_cittthan")
        case .bid:
            return YXLanguageUtility.kLang(key: "market_bid")
        case .ask:
            return YXLanguageUtility.kLang(key: "market_ask")
        case .bidSize:
            return YXLanguageUtility.kLang(key: "market_bid_volume")
        case .askSize:
            return YXLanguageUtility.kLang(key: "market_ask_volume")
        case .currency:
            return YXLanguageUtility.kLang(key: "market_currency")
        case .expiryDate:
            return YXLanguageUtility.kLang(key: "market_expiry_date")
        case .delta:
            return YXLanguageUtility.kLang(key: "market_sg_warrants_delta")
        case .status:
            return YXLanguageUtility.kLang(key: "market_sg_warrants_status")
        default:
            return ""
        }
    }
}
