//
//  YXGlobalURLConfigModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXGlobalURLConfigModel: Codable {
    let version: Int?
    let parameter: YXGlobalUrlConfigParameterModel?
    let serverUrls: YXGlobalUrlConfigServerUrlsModel?
    let tcpConnectIPS: [YXGlobalUrlConfigIPModel]?
    
    enum CodingKeys: String, CodingKey {
        case version, parameter
        case serverUrls = "server_urls"
        case tcpConnectIPS = "tcp_connect_ips"
    }
}

struct YXGlobalUrlConfigParameterModel: Codable {
    let optStocksMaxNum, rankFreq, quotesResendFreq, holdingFreq: Int?
    let marketRankFreq, marketStockKingFreq: Int?
    
    let delayQuoteRealtimeFreq, delayTimesharingFreq: Int?
    let delayKlineFreq, timesharingFreq: Int?
    let klineFreq: Int?
    let marketStatusFreq, trendFreq, currencyFreq: Int?
    let selfstockFreq: Int?
    let isDynamicShow: String? //1开，0关
    let ipoNewsVisible, stockRealquoteRefreshFreq, lowAdrTradeEnable: Int?
    let stockValueVisible: Int?
    let iOSDNSEnable: Int?
    let httpDNSEnable: Int?
    let discussTabVisible: Int?
    let mainPageTabDefault: String?
    let accountFreq, greyTradeFutu: Int?
    let h5CacheOn: Int? //1开，0关
    let certificateCheck: Int? //1开，0关 // 证书双向校验是否开启
    let beerichShareDomain: String?
    let configEsopValue: Int? //1开，0关
    let configSgOpenValue: Int? //1开，0关

    enum CodingKeys: String, CodingKey {
        case optStocksMaxNum = "opt_stocks_maxNum"
        case rankFreq = "rank_freq"
        case quotesResendFreq = "quotes_resend_freq"
        case holdingFreq = "holding_freq"
        case marketRankFreq = "market_rank_freq"
        case marketStockKingFreq = "market_stock_king_freq"
        case delayQuoteRealtimeFreq = "delay_quote_realtime_freq"
        case delayTimesharingFreq = "delay_timesharing_freq"
        case delayKlineFreq = "delay_kline_freq"
        case timesharingFreq = "timesharing_freq"
        case klineFreq = "kline_freq"
        case marketStatusFreq = "market_status_freq"
        case trendFreq = "trend_freq"
        case currencyFreq = "currency_freq"
        case selfstockFreq = "selfstock_freq"
        case isDynamicShow = "isDynamicShow"
        case ipoNewsVisible = "new_stock_news_visible"
        case stockRealquoteRefreshFreq = "stock_realquote_refresh_freq"
        case lowAdrTradeEnable = "low_adr_trade_enable"
        case stockValueVisible = "stock_value_visible"
        case iOSDNSEnable = "ios_dns_enable"
        case httpDNSEnable = "httpdns_enable"
        case discussTabVisible = "discuss_tab_visible"
        case mainPageTabDefault = "main_page_tab_default"
        case accountFreq = "account_Freq"
        case greyTradeFutu = "grey_trade_futu"
        case h5CacheOn = "ios_h5_cache_on"
        case certificateCheck = "certificate_check"
        case beerichShareDomain = "beerich_share_domain"
        case configEsopValue = "config_esop_value"
        case configSgOpenValue = "config_sg_open_value"
    }
}

struct YXGlobalUrlConfigServerUrlsModel: Codable {
    let img, jyCenter, quoteInfoCenter, staticPage, zxCenter, wjCenter: YXGlobalUrlConfigServerDetailModel?
    
    enum CodingKeys: String, CodingKey {
        case img
        case jyCenter = "jy_center"
        case quoteInfoCenter = "quote_info_center"
        case staticPage = "static_page"
        case zxCenter = "zx_center"
        case wjCenter = "wj_center"
    }
}

struct YXGlobalUrlConfigServerDetailModel: Codable {
    let url: String?
    let ips: [YXGlobalUrlConfigIPModel]?
}

struct YXGlobalUrlConfigIPModel: Codable {
    let nameCN, nameTc, nameEn, ip: String?
    
    enum CodingKeys: String, CodingKey {
        case nameCN = "name_cn"
        case nameTc = "name_tc"
        case nameEn = "name_en"
        case ip
    }
}
