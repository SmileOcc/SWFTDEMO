//
//  YXMarketCommon.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//


enum YXMarketSectionType {
    // 指数
    case index
    // 涡轮牛熊
    case warrants
    // 新股中心
    case newStockCenter
    //盯盘精灵
    case stare
    //每日复盘
    case dailyReplay
    // 热门行业
    case industry
    // 全部
    case allHKStock
    // 主板
    case mainboard
    // 创业板
    case gem
    // 凯利板
    case cata
    // 中概股
    case chinaConceptStock
    // 涨跌榜(全部美股)
    case upsaAndDowns
    // 明星股
    case star
    // 市场总览
    case marketOverview
    // A股通资金
    case AStockFund
    // A股通
    case AStock
    // 概念板块
    case concept
    // 热门ETF
    case hotETF
    // 全部A股
    case allHSStock
    // 入口
    case entrance
    // 月供股
    case monthlyPayment
    // 日内融
    case dailyFunding
    // 猜涨跌
    case guess
    //美股etf
    case usETF
    // 全部SG
    case allSGStock
    
    
    
    var sectionName: String {
        switch self {
        case .newStockCenter:
            return YXLanguageUtility.kLang(key: "markets_news_ipo")
        case .industry:
            return YXLanguageUtility.kLang(key: "markets_news_hk_industry")
        case .allHKStock:
            return YXLanguageUtility.kLang(key: "markets_news_hk_stocks")
        case .mainboard:
            return YXLanguageUtility.kLang(key: "markets_news_mian_board")
        case .gem:
            return YXLanguageUtility.kLang(key: "markets_news_gem")
        case .cata:
            return YXLanguageUtility.kLang(key: "markets_news_cata")
        case .chinaConceptStock:
            return YXLanguageUtility.kLang(key: "markets_news_us_concept")
        case .upsaAndDowns:
            return YXLanguageUtility.kLang(key: "markets_news_us_stocks")
        case .star:
            return YXLanguageUtility.kLang(key: "market_hot_stock_pick")
        case .marketOverview:
            return YXLanguageUtility.kLang(key: "markets_news_overview")
        case .AStockFund:
            return YXLanguageUtility.kLang(key: "markets_news_stock_connect")
        case .concept:
            return YXLanguageUtility.kLang(key: "markets_news_concept")
        case .stare:
            return YXLanguageUtility.kLang(key: "common_watch")
        case .dailyReplay:
            return YXLanguageUtility.kLang(key: "markets_daily_replay")
        case .hotETF:
            return YXLanguageUtility.kLang(key: "market_hot_ETF")
        case .allHSStock:
            return YXLanguageUtility.kLang(key: "markets_news_hs_stocks")
        case .monthlyPayment:
            return YXLanguageUtility.kLang(key: "hold_monthly")
        case .dailyFunding:
            return YXLanguageUtility.kLang(key: "market_dailyFunding")
        case .guess:
            return YXLanguageUtility.kLang(key: "rise_or_fall")
        case .allSGStock:
            return YXLanguageUtility.kLang(key: "markets_news_sg_stocks")
        case .entrance:
            return YXLanguageUtility.kLang(key: "markets_quick_entry")
        default:
            return ""
        }
    }
    
    var rankCode: String {
        switch self {
        case .allHKStock:
            return "HK_ALL"
        case .mainboard:
            return "MAIN_ALL"
        case .gem:
            return "GEM_ALL"
        case .cata:
            return "CATA_ALL"
        case .industry:
            return "INDUSTRY_ALL"
        case .upsaAndDowns:
            return "US_ALL"
        case .star:
            return "STAR_ALL"
        case .chinaConceptStock:
            return "CONCEPT_ALL"
        case .AStock:
            return "CONNECT_ALL"
        case .concept:
            return "CONCEPT_ALL"
        case .marketOverview:
            return "HS_ALL"
        case .hotETF:
            return "HOTETFSECOND_EBK001" // 指数型热门ETF
        case .dailyFunding:
            return "DAILYFUNDING_ALL"
        case .monthlyPayment:
            return "MONTHPLAN_ALL"
        case .allSGStock:
            return "SG_ALL"
        default:
            return ""
        }
    }
}

enum YXMarketIndex: String {
    // 恒生
    case HSI = "HSI"
    // 国企
    case HSCEI = "HSCEI"
    //恒生科技指数
    case HSTECH = "HSTECH"
    // 红筹
    case HSCCI = "HSCCI"
    //标普香港创业指数
    case SPHKGEM = "SPHKGEM"
    //恒生波幅指数
    case VHSI = "VHSI"
    // 道琼斯指数
    case DIA = "DIA"
    // 纳指100ETF
    case QQQ = "QQQ"
    // 标普500指数
    case SPY = "SPY"
    // 上证指数
    case HSSSE = "000001"
    // 深证指数
    case HSSZSE = "399001"
    // 创业板指
    case HSGEM = "399006"
    
    // 道琼斯指数
    case DJI = ".DJI"
    // 纳斯达克指数
    case IXIC = ".IXIC"
    // 标普500指数
    case SPX = ".SPX"
    
    var indexName: String {
        switch self {
        case .HSI:
            return YXLanguageUtility.kLang(key: "markets_news_hsi")
        case .HSCEI:
            return YXLanguageUtility.kLang(key: "markets_news_hscei")
        case .HSTECH:
            return YXLanguageUtility.kLang(key: "markets_news_hstech")
        case .HSCCI:
            return YXLanguageUtility.kLang(key: "markets_news_hscci")
        case .SPHKGEM:
            return YXLanguageUtility.kLang(key: "markets_news_sphkgem")
        case .VHSI:
            return YXLanguageUtility.kLang(key: "markets_news_vhsi")
        case .DIA:
            return YXLanguageUtility.kLang(key: "dow_jones_etf")
        case .QQQ:
            return YXLanguageUtility.kLang(key: "qqq")
        case .SPY:
            return YXLanguageUtility.kLang(key: "s&p_500_etf")
        case .HSSSE:
            return YXLanguageUtility.kLang(key: "sse_composite")
        case .HSSZSE:
            return YXLanguageUtility.kLang(key: "szse_component")
        case .HSGEM:
            return YXLanguageUtility.kLang(key: "chinext_price")
        case .DJI:
            return YXLanguageUtility.kLang(key: "dow_jones")
        case .IXIC:
            return YXLanguageUtility.kLang(key: "nasdaq_index")
        case .SPX:
            return YXLanguageUtility.kLang(key: "s&p_500")
        }
    }
}
