//
//  YXStockDetailConfigModel.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXStockDetailConfigModel {
    var title: String?
    var isShow: Bool = true
    var keyWord: String = ""
    var height: CGFloat = 0
    var isExpand: Bool = false
    var externHeight: CGFloat = 0
    
    convenience init(title: String?, isShow: Bool, keyWord: String, height: CGFloat) {
        self.init()
        self.title = title
        self.isShow = isShow
        self.keyWord = keyWord
        self.height = height
    }
}

class YXStockDetailItem: NSObject, YXSecuIDProtocol {
    func secuId() -> YXSecuID {
        YXSecuID(market: self.market, symbol: self.symbol)
    }
    var market = ""
    var symbol = ""
}

enum YXStockDetailStockType {
    case hkStock
    case usStock
    case shStock
    case sgStock
    case stIndex
    case fund
    case stWarrant
    case stCbbc
    case bond
    case stInlineWarrant
    case stSector
    case stUsWarrant
    case stUsStockOpt
    case cryptos
    case stSgDlc
    case stTrustFundReit
    case stSgWarrant
}

enum YXStockDetailBasicType {
    case now        //今开
    case pclose     //昨收
    case high       //今日最高
    case low        //今日最低
    case pe         //市盈率(静态）
    case peTTM      //市盈率（TTM)
    case dividend   //股息
    case gx         //股息率
    case volume     //成交量
    case amount     //成交额
    case circulationValue   //流通市值
    case tradingUnit        //每手
    case outstanding_pct    //街货比
    case impliedVolatility  //引伸波幅
    case convertPrice       //换股价
    case callPrice          //回收价
    case diffRatio          //距回收价
    case turnoverRate       //换手率
    case wc_trading_unit    //每手份数
    case exercise_price     //行权价格
    case ent_ratio          //换股比例
    case issue_vol          //发行数量
    case listed_date        //上市日期
    case last_trade_day     //最后交易
    case maturity_date      //到期日期
    case days_remain        //剩余天数
    case stock              //相关资产
    case open               //开盘
    case close              //收盘
    case roc                //涨跌幅
    case change             //涨跌额
    case name               //证券名称
    case secuCode           //证券代码
    case lowerStrike        //下限价
    case upperStrike        //上限价
    case toLowerStrike      //距下限
    case toUpperStrike      //距上限
    case delta              //对冲值
    case issuer             //发行商
    case highP1Y            //52周最高
    case lowP1Y             //52周最低
    case cittthan           //委比
    case volumeRatio        //量比(除以10000)
    case amp                //振幅
    case pb                 //市净率(除以10000)
    case marketValue        //总市值
    case total              //总股本
    case share              //流通股
    case outstandingQty     //街货量
    case premium            //溢价
    case strike             //行权价
    case breakevenPoint     //打和点
    case conversionRatio    //换股比例
    case effgearing         //实际杠杆
    case gearing            //杠杆比率
    case postVolume         //盘后量
    case postAmount         //盘后价
    case upperLimit         //涨停价
    case lowerLimit         //跌停价
    case highLow            //今日高低
    case highLowP1Y         //52周高低
    case stockNature        //证券性质
    case calculation        //计算方式
    case up                 //上涨
    case unchange           //平盘
    case down               //下跌
    case moneyness          //价内价外
    case historyHigh        // 历史最高
    case historyLow         // 历史最低
    case avg                // 均价

    case register           //是否注册制
    case votingRights       //表决权差异
    case controlArc         //协议控制架构
    case profitable         //是否盈利
    case SharesEqualRights  //是否同股同权

    case openInt            //未平仓数
    case contractSize       // 每份合约
    case expDate            // 到期时间
    case gamma              //gamma
    case theta              //theta
    case vega               //vega
    case rho                //rho
    case optionImpliedVolatility //隐含波动率
    case optionDelta        //delta
    case navPs              //基金净值
    case totalAsset         //总资产
    case assetType          //资产类型
    //case fundLever          //基金杠杆比例
    case currency           //交易货币
    case open24             //数字货币 24h向后数第一笔价格
    case high24             //数字货币 24小时最高价
    case low24              //数字货币 24小时最底价
    case volume24            //数字货币 24成交量
    case amount24            //数字货币 24h成交额
    case high52w             //数字货币 52周高成交价格
    case low52w              //数字货币 52周最低成交价格
    case exerciseStyle       //期权类型
    case eps       //每股收益
    case epsTTM       //每股收益TTM
    case circulation //发行量
}

extension YXStockDetailBasicType {
    public var title: String {
        switch self {
        case .now:
            return YXLanguageUtility.kLang(key: "stock_detail_now")
        case .pclose:
            return YXLanguageUtility.kLang(key: "stock_detail_pclose")
        case .high:
            return YXLanguageUtility.kLang(key: "stock_detail_high")
        case .low:
            return YXLanguageUtility.kLang(key: "stock_detail_low")
        case .pe:
            return YXLanguageUtility.kLang(key: "stock_detail_pe_static")
        case .peTTM:
            return YXLanguageUtility.kLang(key: "stock_detail_pe_ttm")
        case .dividend:
            return YXLanguageUtility.kLang(key: "stock_dividend")
        case .gx:
            return YXLanguageUtility.kLang(key: "stock_detail_div_yield")
        case .volume:
            return YXLanguageUtility.kLang(key: "stock_detail_vol")
        case .amount:
            return YXLanguageUtility.kLang(key: "stock_detail_turnover")
        case .circulationValue:
            return YXLanguageUtility.kLang(key: "stock_detail_circ_cap")
        case .marketValue:
            return YXLanguageUtility.kLang(key: "stock_detail_mkt_cap")
        case .tradingUnit:
            return YXLanguageUtility.kLang(key: "stock_detail_lot_size")
        case .outstanding_pct:
            return YXLanguageUtility.kLang(key: "stock_detail_os")
        case .impliedVolatility:
            return YXLanguageUtility.kLang(key: "stock_detail_iv")
        case .convertPrice:
            return YXLanguageUtility.kLang(key: "stock_detail_conv_price")
        case .callPrice:
            return YXLanguageUtility.kLang(key: "stock_detail_call")
        case .diffRatio:
            return YXLanguageUtility.kLang(key: "warrants_spot_vs_call")
        case .turnoverRate:
            return YXLanguageUtility.kLang(key: "stock_detail_turnover_rate")
        case .wc_trading_unit:
            return YXLanguageUtility.kLang(key: "stock_detail_wc_trading_unit")
        case .exercise_price:
            return YXLanguageUtility.kLang(key: "stock_detail_strike")
        case .ent_ratio:
            return YXLanguageUtility.kLang(key: "stock_detail_ent_ratio")
        case .issue_vol:
            return YXLanguageUtility.kLang(key: "stock_detail_issue_vol")
        case .listed_date:
            return YXLanguageUtility.kLang(key: "market_marketDate")
        case .last_trade_day:
            return YXLanguageUtility.kLang(key: "stock_detail_last_trading")
        case .maturity_date:
            return YXLanguageUtility.kLang(key: "stock_detail_maturity")
        case .days_remain:
            return YXLanguageUtility.kLang(key: "stock_detail_days_remain")
        case .stock:
            return YXLanguageUtility.kLang(key: "stock_detail_stock")
        case .open:
            return YXLanguageUtility.kLang(key: "stock_detail_monthly_opening")
        case .close:
            return YXLanguageUtility.kLang(key: "stock_detail_monthly_closing")
        case .roc:
            return YXLanguageUtility.kLang(key: "market_roc")
        case .change:
            return YXLanguageUtility.kLang(key: "market_change")
        case .name:
            return YXLanguageUtility.kLang(key: "common_stock_name")
        case .secuCode:
            return YXLanguageUtility.kLang(key: "market_codeName")
        case .lowerStrike:
            return YXLanguageUtility.kLang(key: "warrants_lower_strike")
        case .upperStrike:
            return YXLanguageUtility.kLang(key: "warrants_upper_strike")
        case .toLowerStrike:
            return YXLanguageUtility.kLang(key: "warrants_to_lower_strike")
        case .toUpperStrike:
            return YXLanguageUtility.kLang(key: "warrants_to_upper_strike")
        case .delta:
            return YXLanguageUtility.kLang(key: "warrants_delta")
        case .issuer:
            return YXLanguageUtility.kLang(key: "warrants_issuer")
        case .highP1Y:
            return YXLanguageUtility.kLang(key: "stock_detail_52w_high")
        case .lowP1Y:
            return YXLanguageUtility.kLang(key: "stock_detail_52w_low")
        case .cittthan:
            return YXLanguageUtility.kLang(key: "stock_detail_rate_ratio")
        case .volumeRatio:
            return YXLanguageUtility.kLang(key: "stock_detail_vol_ratio")
        case .amp:
            return YXLanguageUtility.kLang(key: "stock_detail_amplitude")
        case .pb:
            return YXLanguageUtility.kLang(key: "stock_detail_pb")
        case .total:
            return YXLanguageUtility.kLang(key: "stock_detail_total_share")
        case .share:
            return YXLanguageUtility.kLang(key: "stock_detail_circ_shares")
        case .outstandingQty:
            return YXLanguageUtility.kLang(key: "stock_detail_outs_qty")
        case .premium:
            return YXLanguageUtility.kLang(key: "stock_detail_premium")
        case .strike:
            return YXLanguageUtility.kLang(key: "stock_detail_strike")
        case .breakevenPoint:
            return YXLanguageUtility.kLang(key: "stock_detail_breakeven")
        case .conversionRatio:
            return YXLanguageUtility.kLang(key: "stock_detail_ent_ratio")
        case .effgearing:
            return YXLanguageUtility.kLang(key: "stock_detail_effect_gear")
        case .gearing:
            return YXLanguageUtility.kLang(key: "warrants_gearing")
        case .postVolume:
            return YXLanguageUtility.kLang(key: "stockdetail_post_volume")
        case .postAmount:
            return YXLanguageUtility.kLang(key: "stockdetail_post_anount")
        case .upperLimit:
            return YXLanguageUtility.kLang(key: "stock_detail_upper_limit")
        case .lowerLimit:
            return YXLanguageUtility.kLang(key: "stock_detail_lower_limit")
        case .highLow:
            return YXLanguageUtility.kLang(key: "quote_today_high_low")
        case .highLowP1Y:
            return YXLanguageUtility.kLang(key: "quote_52_high_low")
        case .stockNature:
            return YXLanguageUtility.kLang(key: "stock_property")
        case .calculation:
            return YXLanguageUtility.kLang(key: "stock_detail_calculation")
        case .up:
            return YXLanguageUtility.kLang(key: "up_num")
        case .unchange:
            return YXLanguageUtility.kLang(key: "draw_num")
        case .down:
            return YXLanguageUtility.kLang(key: "down_num")
        case .moneyness:
            return YXLanguageUtility.kLang(key: "warrants_in_out")
        case .historyHigh:
            return YXLanguageUtility.kLang(key: "quote_history_high")
        case .historyLow:
            return YXLanguageUtility.kLang(key: "quote_history_low")
        case .avg:
            return YXLanguageUtility.kLang(key: "quote_average_price")
        case .register:
            return YXLanguageUtility.kLang(key: "whether_register")
        case .votingRights:
            return YXLanguageUtility.kLang(key: "whether_voting_right")
        case .controlArc:
            return YXLanguageUtility.kLang(key: "whether_control_arc")
        case .profitable:
            return YXLanguageUtility.kLang(key: "whether_profitable")
        case .SharesEqualRights:
            return YXLanguageUtility.kLang(key: "whether_shares_equalto_rights")
        case .openInt:
            return YXLanguageUtility.kLang(key: "option_openInt")
        case .contractSize:
            return YXLanguageUtility.kLang(key: "option_contractSize")
        case .expDate:
            return YXLanguageUtility.kLang(key: "stock_detail_maturity")
        case .gamma:
            return "Gamma"
        case .theta:
            return "Theta"
        case .vega:
            return "Vega"
        case .rho:
            return "Rho"
        case .optionImpliedVolatility:
            return YXLanguageUtility.kLang(key: "option_impliedVolatility")
        case .optionDelta:
            return "Delta"
        case .navPs:
            return YXLanguageUtility.kLang(key: "stock_detail_navPs")
        case .totalAsset:
            return YXLanguageUtility.kLang(key: "stock_detail_totalAsset")
        case .assetType:
            return YXLanguageUtility.kLang(key: "stock_detail_assetType")
        case .currency:
            return YXLanguageUtility.kLang(key: "stock_detail_currency")
        case .high24:
            return YXLanguageUtility.kLang(key: "high_24")
        case .low24:
            return YXLanguageUtility.kLang(key: "low_24")
        case .open24:
            return YXLanguageUtility.kLang(key: "open_24")
        case .volume24:
            return YXLanguageUtility.kLang(key: "volumn_24")
        case .amount24:
            return YXLanguageUtility.kLang(key: "amount_24")
        case .high52w:
            return YXLanguageUtility.kLang(key: "stock_detail_52w_high")
        case .low52w:
            return YXLanguageUtility.kLang(key: "stock_detail_52w_low")
        case .exerciseStyle:
            return YXLanguageUtility.kLang(key: "stock_detail_exerciseStyle")
        case .eps:
            return YXLanguageUtility.kLang(key: "stock_detail_eps")
        case .epsTTM:
            return YXLanguageUtility.kLang(key: "stock_detail_epsTTM")
        case .circulation:
            return YXLanguageUtility.kLang(key: "stock_detail_circulation")
        }
    }
}
