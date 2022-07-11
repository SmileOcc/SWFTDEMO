//
//  File.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import sqlcipher

/// MARK- 帮助中心
let YX_H5_PATHS = "/webapp/market/generator.html"

@objcMembers class YXH5Urls: NSObject {

    // 消息中心
    class func YX_MSG_CENTER_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/msg-center.html#/dolphin"
    }

    // MGM跳转链接
    class func YX_MGM_URL(realAttribution: Int?) -> String {
        switch realAttribution {
        case 1: //1：大陆
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/marketing/mgm-ch.html?register-ct=ecp&register-cid=1010#/"
        default: //2：香港
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/marketing/mgm.html?register-ct=ecp&register-cid=12019060501#/"
        }
    }

    // 活动中心
    class func YX_ACTIVITY_CENTER_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/marketing/award-center.html#/activity-center"
    }
    // SG活动中心
    class func YX_SG_ACTIVITY_CENTER_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/promo/overseas/activity-center.html#/"
    }

    // 奖励中心
    class func YX_AWARD_CENTER_URL() -> String {
        
        //YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/overseas/award-center.html#/ch"
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/overseas-marketing/sg.html#/award-center"
    }

    // 我的佣金
    class func YX_MY_COMMISSION_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/marketing/my-commission.html"
    }

    // 我的行情 0 sg 1 us 2 hk
    class func YX_MY_QUOTES_URL(tab: Int = 0) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/marketing/quotes.html#/index?tab=\(tab)"
    }
    
    // 我的行情 0 sg 1 us 2 hk
    class func YX_MY_QUOTES_URL(market: String) -> String {
        var tab: Int = 0
        if market == kYXMarketUS {
            tab = 1
        } else if market == kYXMarketHK {
            tab = 2
        }
        return self.YX_MY_QUOTES_URL(tab: tab)
    }
    
    /* 我的行情
     levelType(美股下用)
     0: 纳斯达克 basic行情
     1: 全美综合
     2: arca
     3: 美股期权
     */
    class func myQuotesUrl(tab: Int = 0, levelType: Int) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/transaction/marketing/quotes.html#/index?tab=\(tab)&levelType=\(levelType)"
    }

    // 风险测评
    class func YX_BOND_RISK_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/wealth/fund/index.html#/risk-assessment"
    }

    // 帮助与客服

    class func YX_HELP_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/help.html"
    }

    // 基金交易
    class func YX_FUND_TRADE_URL(with fundId: String? = nil, market: String? = nil) -> String {
        var baseUrl = "\(YXUrlRouterConstant.staticResourceBaseUrl())/wealth/fund/index.html#/"
        if let temp = fundId, temp.isNotEmpty() {
            baseUrl = baseUrl + "fund-details?id=" + temp
        } else {
            baseUrl = baseUrl + "home" //基金首页地址
            if let temp = market, temp.isNotEmpty() {
                baseUrl = baseUrl + "?market=" + temp   //添加市场
            }
        }
        return baseUrl
    }

    // 智投
    class func YX_STOCK_KING_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart-home/index.html"
    }

    // 月供股
    class func YX_MONTHLY_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/monthly.html#/"
    }

    // 全部月供股
    class func YX_MONTHLY_ALL_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/monthly.html#/list"
    }

    // 指定股票月供股（编辑）
    class func YX_MONTHLY_EDIT_URL(symbol: String, exchangeType: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/monthly.html#/edit/\(symbol)/\(exchangeType)"
    }

    // 资金流水
    class func YX_CAPITAL_FLOW_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/capital-flow.html"
    }

    class func YX_INTRADAY_CAPITAL_FLOW_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/capital-flow.html?type=financing"
    }

    class func YX_OPTION_CAPITAL_FLOW_URL() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/capital-flow.html?type=option"
    }
    
    class func YX_SHORTSELL_CAPITAL_FLOW_URL() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/capital-flow.html?type=sell-short"
    }

    class func YX_PROFESSIONAL_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/professional-investor/profession.html#/"
    }

    // 开户引导页
    class func YX_OPEN_ACCOUNT_APPLY_URL(_ isOpenAccount: Bool = false) -> String {
        if isOpenAccount { // 登录注册开户引导页
            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/acct/open-account/index.html?openAccount=1#/"
        } else {
            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/acct/open-account/index.html#/"
        }
        
    }

    // 开户页面
    class func YX_OPEN_ACCOUNT_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/acct/open-account/index.html#/"
    }

    // 资讯链接
    class func YX_NEWS_URL(newsId: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/news.html?newsid=\(newsId)"
    }

    // 美股行情权限声明
    class func YX_US_STOCK_MARKET_STATEMENT_URL(_ hideSkip:Bool = true) -> String {
        
        if  hideSkip {
            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/statement/statement.html?hideSkip=1"
        }else {
            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/statement/statement.html"
        }
    }

    // 转入股票历史记录
    class func YX_SHIFTIN_STOCK_HISTORY_URL(market: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/transaction/conversion-hk.html#/log?market=\(market)"
    }

    // 转入股票
    class func YX_SHIFTIN_STOCK_URL(market: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/transaction/conversion-hk.html#/?market=\(market)"
    }

    // 短线策略
    class func YX_STUB_URL(strategyID: Int, strategyVersion: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/short/detail/\(strategyID)/\(strategyVersion)"
    }

    // 长线策略
    class func YX_STRATEGY_URL(strategyID: Int, strategyVersion: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/long/detail/\(strategyID)/\(strategyVersion)"
    }

    // ETF策略
    class func YX_ETF_STRATEGY_URL(strategyID: Int, strategyVersion: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/etf/detail/\(strategyID)/\(strategyVersion)"
    }

    // 人工策略
    class func YX_MANUAL_STRATEGY_URL(strategyID: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/manual/detail/\(strategyID)"
    }



    // 分享链接
    class func YX_QR_BASE_STRING_URL() -> String {
        var inviteCode = ""
        if YXUserManager.isLogin() {
            inviteCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
        }
        let path = "/promo/overseas/sg-register.html?langType=\(YXUserHelper.currentLanguage())&ICode=\(inviteCode)#marketing-register"
        
        return YXUrlRouterConstant.staticResourceBaseUrl() + path
    }

    /// MARK- 出入金
    // 入金
    class func YX_DEPOSIT_URL(market: String? = nil) -> String {
//        if let market = market {
//            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account-hk/deposit.html#/?market=\(market)"
//        } else {
//            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account-hk/deposit.html#/"
//        }
        return DEPOSIT_GUIDELINE_SG_URL()
    }

    // 出金
    class func YX_WITHDRAWAL_URL(market: String? = nil) -> String {
//        if let market = market {
//            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account-hk/withdrawal.html#/?market=\(market)"
//        } else {
//            return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account-hk/withdrawal.html#/"
//        }
        return WITHDRAWAL_GUIDELINE_SG_URL()
        
    }
    
    // 衍生品交易风险披露
    class func DERIVATIVES_TRADING_RISK_DISCLOSURE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=CAF_RISK_02"
    }

    // 新股认购说明
    class func NEW_STOCK_SUBSCRIBE_INSTRUCTIONS_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=AGR0101"
    }

    // 新股融资认购了解更多
    class func NEW_STOCK_FINANCE_SUBSCRIBE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=XY019"
    }

    // 新股ECM风险提示
    class func NEW_STOCK_ECM_RISK_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=ECM01"
    }

    // 新股ECM独立协议
    class func NEW_STOCK_ECM_INDEPENDENT_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/transaction/ecm.html#/index?"
    }

    // 新股认购费用说明
    class func NEW_STOCK_SUBSCRIBE_FEE_INSTRUCTIONS_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=XY001"
    }

    // 入金引导
//    class func DEPOSIT_GUIDELINE_URL() -> String {
//        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/open-account/deposit.html#/"
//    }
    // SG入金引导
    class func DEPOSIT_GUIDELINE_SG_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/open-account-sg/deposit.html"
    }

    // 换汇引导
    class func EXCHANGE_GUIDELINE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=XY0041"
    }

    // 出金引导
//    class func WITHDRAWAL_GUIDELINE_URL() -> String {
//        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/open-account/withdraw.html#/"
//    }
    // SG出金引导
    class func WITHDRAWAL_GUIDELINE_SG_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/open-account-sg/withdraw.html"
    }

    // 隐私政策
    class func PRIVACY_POLICY_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=sg_privacy_policy"
    }

    // 用户注册协议
    class func USER_REGISTRATION_AGREEMENT_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=sg_registration_agreement" //"?key=AGR008"
    }

    // 交易费用说明
    class func TRANSACTION_FEE_DESCRIPTION_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=XY0091"
    }

    // 多元资产 详情
    class func STOCKST_MULTIASSET(_ columnId: Int, _ blockId: Int) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/stock-king/multi-asset.html?column_id=\(columnId)&block_id=\(blockId)"
    }
    // 智能選股策略 详情
    class func STOCKST_STRATEGY() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/smart-choice.html"
    }
    // 跟投晒单 详情
    class func DYNAMIC_SUNDRYING_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/marketing/dynamic-sundrying-hk.html"
    }
    // 个股分析 详情
    class func STOCK_ANALYZE_URL(_ symbol: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/diagnose/stock.html?stock=" + symbol
    }
    // 专栏 详情
    class func COLUMN_DETAIL_URL(_ enlangType: Int) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/news/column.html?enlangType=" + "\(enlangType)"
    }


    // 关于uSMART 页面进入SFC页面
    class func YX_ABOUT_SFC_URL() -> String {
        if YXUserManager.isENMode() {
            return "https://www.sfc.hk/publicregWeb/corp/BJA907/details?locale=en"
        } else {
            return "https://www.sfc.hk/publicregWeb/corp/BJA907/details"
        }
    }

    // A股开户
    class func YX_AOPEN_ACCOUNT_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account/a-share.html#/hk/"
    }

    // 十大股东
    class func YX_SHARE_HOLDERS_URL(_ tabId: String, symbol: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/hz-stock/shareholders.html#/" + symbol + "/\(tabId)"
    }

    // 跳转回AAStocks
    class func YX_OPEN_AASTOCKS_URL(with source: String) -> String {
        "https://m.aastocks.com/tsp/bchkredirect?com=USSL&source=\(source)"
    }

    // 财务详情页面
    class func YX_STOCK_FINANCE_URL(symbol: String, type: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/finance.html?symbol=\(symbol)&type=\(type)"
    }

    // 财经日历页面
    class func YX_INFO_CALENDAR_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/news/economic-calendar.html"
    }

    // 债券首页
    class func BOND_HOME_PAGE() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/wealth/bond/index.html#/hk/"
    }

    // 债券详情页
    class func BOND_DETAIL_PAGE() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/wealth/bond/index.html#/hk/bond-detail"
    }

    // 高级账户介绍落地页
    class func YX_USERCENTER_PRO_INTRO(_ source: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/account/pro/index.html?source=\(source)"
    }
    // 高级账户介绍
    class func YX_USERCENTER_PRO_INTRO() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/market/pro-account-center.html"
    }
    // 历史记录-驳回详情
    class func YX_HISTORY_DETAIL_URL(_ cashApplyId: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/open-account/deposit.html#/history-detail?cashApplyId=\(cashApplyId)"
    }

    //新股预约界面
    class func YX_NEWSTOCK_BOOKING_URL(_ subscribeId: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/ecm/index.html?subscribeId=\(subscribeId)#/"
    }

    //新股认购详情界面
    class func YX_NEWSTOCK_DETAIL_URL(exchangeType: Int, ipoId: Int64, stockCode: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/ecm/index.html#/subscription-information?exchangeType=\(exchangeType)&ipoId=\(ipoId)&stockCode=\(stockCode)"
    }

    //新股认购明细
    class func YX_NEWSTOCK_LIST_DETAIL_URL(_ applyId: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/ecm/index.html#/subscription-detail/\(applyId)"
    }

    //新股预约明细界面
    class func YX_NEWSTOCK_BOOKING_DETAIL_URL(_ applyId: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/ecm/index.html#/booking-detail/\(applyId)"
    }

    // 新股认购记录页
    class func YX_NEW_STOCK_SUBSCRIBE_RECORD_URL(_ exchangeType: Int = 0) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/ecm/index.html#/subscription-record?exchangeType=\(exchangeType)"
    }

    //股王重要提示
    class func YX_STOCK_KING_IMPORTANT_NOTICE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/generator.html?key=XY027"
    }
    //我的智投
    class func YX_STOCK_KING_MY_SUBSCRIBE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/stock-king/strategy.html#/mine"
    }
    //友信内参
    class func YX_STOCK_KING_INTERNAL_REFERENCE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/news/refer.html"
    }

    //友信严选
    class func YX_INFO_RECOMMEND_STRICT_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/news/research.html"
    }

    // 投研精选
    class func YX_STOCK_DIS_RESEARCH_REPORT_URL(with id: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/news/column.html#/intro/\(id)"
    }

    // 英Sir前膽
    class func YX_STOCK_DIS_FORESIGHT_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/news/huiyue-news.html#/"
    }

    // 智能评分
    class func YX_STOCK_ANALYZE_SCORE_HOME_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/diagnose/home.html"
    }

    // 基金详情
    class func YX_FUND_DETAIL_PAGE_URL(_ code: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/wealth/fund/index.html#/fund-details?isin=\(code)"
    }

    // 基金详情
    class func YX_FUND_DETAIL_PAGE_URL(with fundId: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/wealth/fund/index.html#/fund-details?id=\(fundId)"
    }

    // 拼团落地页
    class func YX_PIN_TUAN_SHARING_URL(with bizId:String, orderId:String, groupId:Int,appType:Int) -> String {
        let xLang = "\(YXUserHelper.currentLanguage())" //语言 1-简体  2-繁体  3-英文
        let inviteCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
        // bizType  //0:基金 1：ecm
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/marketing/group.html?biz_id=\(bizId)&order_id=\(orderId)&biz_type=1&group_id=\(groupId)&appType=\(appType)&langType=\(xLang)&invitationCode=\(inviteCode)#/invite"
    }

    // 拼团首页
    class func YX_PIN_TUAN_HOME_PAGE_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/marketing/group.html"
    }


    // 盯盘精灵绑定微信
    class func YX_BIND_WECHAT_PAGE_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=binding_wechat"
    }

    // 现金账户升级到保证金账户的  升级链接
    class func YX_TRADE_ACCOUNT_UPDATE_TO_MARGIN_URL(exchangeType: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/margin/index.html?exchangeType=\(exchangeType)#/"
    }

    class func YX_TRADE_ASSET_DESC_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/margin/index.html#/asset-description"
    }

    class func YX_TRADE_INTRADAY_ASSET_DESC_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/intraday-financing/index.html#/asset-description"
    }

    class func YX_TRADE_OPTION_ASSET_DESC_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=shortselling"
    }
     
    class func YX_TRADE_SHORTSELL_ASSET_DESC_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/option/index.html#/asset-description"
    }
    
    class func YX_PURCHASE_URL(_ exchangeType: Int) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/pro/index.html#/assetOption?exchangeType=\(exchangeType)"
    }

    class func YX_PURCHASE_DETAIL_INDEX_URL() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/pro/index.html#/purchaseDetail"
    }

    class func YX_TRADE_ASSET_DESC_URL_FROM_RISKLEVEL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/margin/index.html#/asset-description?position=risklevel"
    }

    /// 现金账户点「升级」融资账户
    class func YX_TRADE_MARGIN_UPDATE_URL(_ exchangeType: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/margin/index.html?exchangeType=\(exchangeType)#/"
    }
    /// 智能下单引导页 帮助1
    class func YX_SMART_GUIDE_HELP_ONE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=smartorder-help1"
    }
    /// 智能下单引导页 帮助2
    class func YX_SMART_GUIDE_HELP_TWO_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=smartorder-help2"
    }
    
    // 购买股票
    class func STOCK_BUY_ON_LINE_URL() -> String {
        if YXUserManager.isENMode() {
            return "https://www.usmartsg.com/"
        } else if YXUserManager.curLanguage() == .HK {
            return "https://www.usmartsg.com/"
        } else {
            return "https://www.usmartsg.com/"
        }
    }

    // 购买股票
    class func OPTION_BUY_ON_LINE_URL(_ tokenKey: String, and path: String) -> String {
        YXUrlRouterConstant.pcStaticResourceBaseUrl() + "/sign?tokenKey=\(tokenKey)&targetUrl=\(path)"
    }

    // 价值掘金 主页
    class func STOCK_VALUE_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/smart/nuggets.html#/"
    }

    // 调整课程 详情
    class func YX_INFO_COURSE_DETAIL_URL(with id: Int) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/news/course.html#/detail/\(id)"
    }
    // 价值掘金 详情
    class func STOCK_VALUE_Detail_URL(_ stockId: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/smart/nuggets.html?stock=\(stockId)#/"
    }

    // 专属服务
    class func EXCLUSIVE_SERVICE_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/marketing/exclusive-customer/index.html#/"
    }
    // 选股选息
    class func STOCK_SELECTION_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/transaction/corporate-action.html#/choose-list/BC,DS"
    }
    // 供股选择
    class func STOCK_OPTION_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/transaction/corporate-action.html#/choose-list/RC"
    }

    // 技术洞察 详情
    class func TECHNICAL_INSIGHT_URL(_ stockId: String) -> String {
        if stockId.isEmpty {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/smart/morph.html"
        } else {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/smart/morph.html#/detail/\(stockId)"
        }
    }

    // 大事提醒 详情
    class func EVENT_REMINDER_URL(_ stockId: String, _ eventId: String = "") -> String {
        if eventId.isEmpty {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/news/event-reminder.html?stock=\(stockId)"
        } else {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/news/event-reminder.html?stock=\(stockId)&eventId=\(eventId)"
        }
    }

    // 诊股解锁
    class func YX_CONSULTATION_UNLOCK_URL() -> String {
         YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/diagnose/unlock.html"
    }

    // 每日复盘
    class func DAILY_REPLAY_URL(market: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/today-analyse.html#/\(market)"
    }

    // 筹码分布解释
    class func ANALYZE_CHIP_EXPLAIN_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=Chip_Distribution"
    }

    // 日内融开户
    class func OPEN_DAILY_MARGIN_URL(_ exchangeType: Int) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/intraday-financing/index.html?exchangeType=\(exchangeType)"
    }

    // 日内融解释
    class func DAILY_MARGIN_EXPLAIN_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=Day_Margin_Introduction"
    }

    // 美股盘前盘后声明
    class func US_QUOTES_STATEMENT_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=us-panqianpanhou"
    }

    // 期权学院页面
    class func OPTION_COLLEGE_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/option-college.html"
    }

    // 期权开户界面
    class func OPEN_OPTION_ACCOUNT_URL() -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/account/open-stock-option/index.html#/"
    }

    class func goProUrl(_ source: String) -> String {
        YX_USERCENTER_PRO_INTRO(source)
    }

    class func analyzeDetailUrl(_ stockCode: String) -> String {
        STOCK_ANALYZE_URL(stockCode)
    }

    class func technicalDetailUrl(_ stockCode: String) -> String {
        TECHNICAL_INSIGHT_URL(stockCode)
    }

    class func goConsultationUnlockUrl() -> String {
        YX_CONSULTATION_UNLOCK_URL()
    }

    class func dynamicSundryingUrl() -> String {
        DYNAMIC_SUNDRYING_URL()
    }

    class func analyzeChipExplainUrl() -> String {
        return ANALYZE_CHIP_EXPLAIN_URL()
    }


    class func goBuyOnLineUrl() -> String {
        return "\(YXUrlRouterConstant.pcStaticResourceBaseUrl())/pricing"
    }

    class func goTradeAssetDescUrl() -> String {
        return YX_TRADE_ASSET_DESC_URL()
    }
    
    class func goOptionAssetDescUrl() -> String {
        return YX_TRADE_OPTION_ASSET_DESC_URL()
    }
    
    // 所有视频
    class func allVideoUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/all-video/"
    }
    // 热门推荐
    class func recommendVideoUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/new-hot-recommend-videos/"
    }
    // 直播跳转更多
    class func videoSetUrl(type: String, id: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/special-topic/\(type)/\(id)"
    }
    // 大家爱看
    class func alllikeVideoUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/pepole-like/"
    }
    // 浏览历史
    class func historyVideoUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/visit-history/"
    }
    // 集合跳转
    class func collectonVideoUrl(with collectionId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/collection/\(collectionId)"
    }
    // 推荐的视频跳转
    class func playRecommendVideoUrl(with videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/detail/VIDEO/\(videoId)"
    }
    // 视频
    class func playVideoUrl(with specificId: String, videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/detail/SPECFIC/\(specificId)/\(videoId)"
    }
    
    // 集合的单个视频
    class func playCollectionVideoUrl(with collectionId: String, videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/video-center.html#/detail/COLLECTION/\(collectionId)/\(videoId)"
    }
    
    // 点播
    class func playNewsRecordUrl(with videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html#/record/\(videoId)"
    }
    // 直播
    class func playNewsLiveUrl(with videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html#/live/\(videoId)"
    }
    // 带分享的直播链接
    class func playInviteCodeLiveUrl(with videoId: String, inviteCode: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html?invitationCode=\(inviteCode)#/live/\(videoId)"
    }
    // 预告
    class func playNewsNoticeUrl(with videoId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html#/notice/\(videoId)"
    }

    //oc 我的行情
    class func myQuotesUrl() -> String {
        return YX_MY_QUOTES_URL()
    }
    
    class func websiteBuyQuoteUrl() -> String {
//        return OPTION_BUY_ON_LINE_URL()
        ""
    }

    // 话题广场
    class func topicSquareUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/topic.html#/square"
    }
    // 话题详情
    class func topicDetailUrl(with topicId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/topic.html#/detail/\(topicId)"
    }
    
    // 主播简介
    class func liveAnchorDetailUrl(with anchorId:String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html#/anchor/\(anchorId)"
    }
    // 轮证日报
    class func warrantsDayReportUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/news/column.html#/intro/1023"
    }
    // 轮证学院
    class func warrantsCollegeUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/rotation-college.html#/"
    }
    //高级用户落地页
    class func goProCenterUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/pro-account-center.html"
           
    }
    class func professionalUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/professional-investor/profession.html#/"
    }
    // 盈立值页面
    class func smartScoreUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/marketing/profit-value.html#/index-hk"
    }
    
    class func bondDetailPage(with bondId: Int) -> String {
        return BOND_DETAIL_PAGE() + "?id=\(bondId)"
    }
    
    // 轮商评分投教页
    class func marketMakerScoreUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=Round-merchant"
    }
    
    // 经纪商排行
    class func brokerRankUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/broker.html#/"
    }
    
    // 买卖方向解释页面
    class func tradeDirectionExplainUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=BS-Itemized"
    }
    
    // 趋势长盈的升级链接
    class func goUsmartAccessoryUnlockUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/diagnose/unlock.html?product_type=24&item_id=1"
    }
    
    // 趋势长盈的股票详情
    class func goUsmartAccessoryDetailUrl(with stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/profit-channel.html#/detail/\(stockId)"
    }

    // 简况公司简介详情
    class func companyDetailUrl(_ stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/company-brief.html#/detail/\(stockId)"
    }

    // 简况分红送转详情
    class func companyDividendsDetailUrl(_ stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/company-brief.html#/dividends/\(stockId)"
    }

    // 简况公司回购详情
    class func companyRepurchaseDetailUrl(_ stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/company-brief.html#/repurchase/\(stockId)"
    }

    // 简况主要股东详情
    class func companyShareholderDetailUrl(_ stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/company-brief.html#/shareholder/\(stockId)"
    }

    // 简况拆股合股详情
    class func companySplittingDetailUrl(_ stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/company-brief.html#/stock-splitting/\(stockId)"
    }
    
    // 猜涨跌
    class func guessUpOrDownUrl(market: String, symbol: String, type: String, upOrDown: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/guess-rise-fall.html#/index/\(market)/\(type)/\(upOrDown)?symbol=\(symbol)"
    }
    
    //支持融资url
    class func marginExplainUrl(market: String, symbol: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/market/stock-detail.html?market=\(market)&symbol=\(symbol)"
    }

    // 券商消息中心
    class func YX_BROKERS_MSG_CENTER_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/msg-center.html"
    }
    //资产说明页
    class func assetExplainUrl(accountBusinessType: Int, moneyType: String, market: String) -> String {
        if YXUserManager.shared().curBroker.brokerNo() == "nz" {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/open-account/index.html#/assets-detail?accountBusinessType=\(accountBusinessType)&moneyType=\(moneyType)"
        } else if YXUserManager.shared().curBroker.brokerNo() == "sg"{
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/open-account/index.html#/assets-detail-sg?market=\(market)"
        }
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/open-account/index.html#/assets-detail?accountBusinessType=\(accountBusinessType)&moneyType=\(moneyType)"
    }
    // 深度摆盘解释
    class func DEPTH_ORDER_EXPLAIN_URL(with value: String) -> String {
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=\(value)"
    }
    //我的佣金
    class func MY_COMMISSION() -> String{
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/transaction/marketing/quotes.html#/my-commission"
    }
    //个股详情分享二维码
    class func introduction() ->String {
       "\(YXUrlRouterConstant.staticResourceBaseUrl())/transaction/download/introduction.html"
    }

    //净资产说明
    class func netAssetsDescURL() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/apply/desc.html#/sg-net-assets-desc"
    }
    
}

//投教相关的HTML
extension YXH5Urls {
//MARK: 投教相关H5
    //kol个人主页
    class func kolHomePage(kolId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/kol-personal.html?id=\(kolId)"
    }
    
    //kol文章详情
    class func kolArticleDetail(postId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/article-details.html?postId=\(postId)"
    }
    
    //kol文章详情评论
    class func kolArticleComment(postId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/article-details.html?postId=\(postId)&jump=true"
    }
    
    //我的全部订阅
    class func myALLSubscribeKOL() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/my-subscription.html"
    }

    //未绑定手机号跳转付费页
    class func bindingPhone(type: Int, courseId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/bind-account.html?type=\(type)&id=\(courseId)"
    }

    
    //已绑定手机号跳转付费页
    class func coursePay(courseId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/course-pay.html?id=\(courseId)"
    }
    
    //聊天室列表
    class func chatList() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/chat-room.html"
    }
    
    //聊天室详情
    class func chatRoom(chatRoomId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/chat-room.html#/\(chatRoomId)"
    }
    
    //问股列表
    class func askList() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/ask-stock.html#/list"
    }
    //问股详情
    class func askDetail(questionId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/ask-stock.html#/detail?questionId=\(questionId)"
    }
    
    //新增问股
    class func ask() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/ask-stock.html"
    }
    
    //kol订阅入口
    class func kolPay(kolId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/kol-pay.html?id=\(kolId)"
    }

    
    //课程 课时
    class func courseUrl(courseId: String, lessonId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/course-details.html?courseId=\(courseId)&lessonId=\(lessonId)&appType=12&langType=\(YXUserHelper.currentLanguage())"
    }
    
    //随堂小测
    class func courseTest(examPaperId: String, lessonId: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/post-test.html?id=\(examPaperId)&lesson=\(lessonId)"
    }
    
    //学习记录
    class func studyRecordUrl() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/learning-records.html"
    }
    
    //我的收藏
    class func myCollectUrl() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/collection.html"
    }
    
    //我的订单
    class func myOrder() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/my-order.html"
    }
    
    //联系我们
    class func contactUs() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/contact-us.html"
    }
    
    //开会
    class func openAcc() -> String {
        return "https://m.usmartsecurities.com/promo/activity-hk/generic.html#/"
    }
    
    //新增问股
    class func ask(replyUid: String?) -> String {
        if let id = replyUid {
            return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/ask-stock.html#/?replyUid=\(id)"
        }
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/ask-stock.html"
    }
    
    class func smartHelpUrl() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/help-middle.html?key=stock"
    }
    
    class func orderHelpUrl() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/market/help-middle.html?key=orderType"
    }

    class func smartInfoUrl(with market: String, smartOrderType: SmartOrderType) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=\(smartOrderType.key(with:market))"
    }
    
    /*20220106以下部分是挪盈广场、个股讨论时新增的html，没用到的可以删除**/
    // 个股讨论url
    class func stockDiscussionUrl(_ stockName: String, stockId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/stock-discussion.html?stockName=\(stockName)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/\(stockId)"
    }
    
    // 额度预约
    class func amountOrderUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/ecm/index.html#/booking-list"
    }
    
    // 新股日历
    class func newStockCalendar() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/hz-stock/new-stock-calendar.html"
    }
    
    // 新股百科
    class func newStockEncyclopedia() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/hz-stock/new-stock.html#/"
    }
    
    // 猜涨跌列表
    class func guessUpOrDownMoreUrl(market: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/guess-rise-fall.html#/list/\(market)"
    }
    
    // 猜涨跌列表
    class func newGuessUpOrDownMoreUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/guess-rise-fall.html#/list-recommend"
    }
    
    // 调整保证金
    class func changeEarnestUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?key=rineirong02"
    }
    
    // 股票百科
    class func stockWikiUrl(_ code: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/stock-encyc.html?code=\(code)#/"
    }
    
    // 评论详情（app内打开用）
    class func commentDetailUrl(with postId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/market/stock-discussion.html?appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/comment-detail/\(postId)"
    }
    
    // 评论详情（分享出去时用）
    class func commentDetailUrlForShare(with postId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrlForShare())/hqzx/market/stock-discussion.html?appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/comment-detail/\(postId)"
    }
    
    // 新股认购详情评论tab链接
    class func newStockApplyUrl(with exchangeType: String, ipoId: String, stockCode: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/ecm/index.html#/subscription-information?exchangeType=\(exchangeType)&ipoId=\(ipoId)&stockCode=\(stockCode)&active=comment"
    }
    
    // 新股认购详情评论tab链接(港股)
    class func newStockHKSubscribeIdUrl(with subscribeId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/ecm/index.html#/booking?subscribeId=\(subscribeId)"
    }
    
    // 新股认购详情评论tab链接(美股)
    class func newStockUSSubscribeIdUrl(with subscribeId: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/ecm/index.html#/booking-detail?subscribeId=\(subscribeId)"
    }
    
    // 今日热股列表
    class func hotStockListUrl(market: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/hot-stock.html#/list/\(market)"
    }
    
    // 今日热股详情页
    class func hotStockDetailUrl(postId: String, flag: Int) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/smart/hot-stock.html#detail/\(postId)/\(flag)"
    }
    
    //新股聆听、递表阶段评论
    class func newStockDeliverCommentUrl(with exchangeType: String, stockname: String, stockCode: String,subscribeId:String) -> String{
        
        let urlQuery = "stockName=\(stockname)&stockCode=\(stockCode)&exchangeType=\(exchangeType)&subscribeId=\(subscribeId)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/ecm/index.html#/unsale-information?\(urlQuery)"
    }
    
    //聊天室
    class func chatRoomUrl(id: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/hqzx/smart/chat-room.html#/\(id)"
    }

    // 文章详情url
    class func articleDetailIdUrl(with articleId: String, inviteCode: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrlForShare())/hqzx/marketing/article-and-news.html?articleId=\(articleId)&invitationCode=\(inviteCode)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/article-index"
    }
    
    // 新闻资讯
    class func importantNewsDetailUrl(newsId: String, inviteCode: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrlForShare())/hqzx/marketing/article-and-news.html?newsid=\(newsId)&invitationCode=\(inviteCode)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/news-index"
    }
    
    // 隐私政策
    class func DISCLAIMER_URL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=Disclaimer_3"
    }
    
    //止损说明
    class func stopLossTipUrl() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=TrailingStop"
    }
    
    //月供基金
    class func monthlyFundUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/wealth/fund/index.html#/fixed-fund-list"
    }
    //月供股票+标签
    class func monthlyListUrl(with tag: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/monthly.html#/list/\(tag)"
    }
    //edda
    class func eddaUrl() -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/open-account/deposit.html?firstLogin=null#/deposit-amount?from=hk"
    }
    
    class func playNewsRecordUrl(with videoId: String, inviteCode: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/news/live.html?invitationCode=\(inviteCode)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())#/record/\(videoId)"
    }
    
    // 跳转注册页面(此处应该是港版的，目前还是大陆版）
    class func jumpRegisterUrl(shareId: String = "", bizId: String = "") -> String {
        let invitationCode = YXUserManager.isLogin() ? YXUserManager.shared().curLoginUser?.invitationCode : nil
        if let invitationCode = invitationCode {
            return "\(YXUrlRouterConstant.staticResourceBaseUrlForShare())/webapp/open-account/apply.html?ICode=\(invitationCode)&share_id=\(shareId)&biz_id=\(bizId)#/register"
        } else {
            return "\(YXUrlRouterConstant.staticResourceBaseUrlForShare())/webapp/open-account/apply.html?ICode=&share_id=\(shareId)&biz_id=\(bizId)#/register"
        }
    }
    class func wxMiniProgramPath(_ id: String) -> String {
        let invitationCode = YXUserManager.isLogin() ? YXUserManager.shared().curLoginUser?.invitationCode : nil
        if let invitationCode = invitationCode {
            return "pages-sub/news/app?newsid=\(id)&invitationCode=\(invitationCode)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())"
        } else {
            return "pages-sub/news/app?newsid=\(id)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())"
        }
        
    }
    
    // 订阅专栏
    class func subcribeColumnUrl(with uid: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/marketing/sub-column.html?id=\(uid)&appType=\(YXConstant.appType)&langType=\(YXUserHelper.currentLanguage())"
    }
    
    // url需要encode
    class func jumpOutsideWebView(url: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/hqzx/redirect/index.html?redirectUrl=\(url)&token=\(YXUserHelper.currentToken())"
    }
    
    /*20220106以上部分是挪盈广场、个股讨论时新增的html，没用到的可以删除**/
    
    class func accountDetailUrl(accountType:Int) -> String{
        "\(YXUrlRouterConstant.staticResourceBaseUrl())/acct/open-account/index.html#/sg-account-center?accountType=\(accountType)"
    }

    // 转股
    class func stockDepositURL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/conversion-sg/stock-transfer.html#/"
    }
    
    //期权开户
    class func OpenUsOptionURL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/open-account/index.html#/sg-options-experience"
    }

    //碎股开户
    class func OpenUsFractionURL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/apply/odd-lot.html#/sg-odd-risk"
    }

    // 逐笔类型解释
    class func tickTypeExplainUrl() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=TICKER_TYPE210923"
    }
    //邀请好友
    class func inviteFriendsUrl() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/promo/overseas/mgm.html#/"
    }

    // 资金流水
    class func cashFlowURL(with market: String) -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/transaction/cash-flow/cashFlow.html#/?market=\(market)"
    }

    // TODO:银行卡
    class func myBankAccURL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/promo/overseas/mgm.html#/"
    }
    
    //个人中心订阅
    class func mineSubscribeURL() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/promo/overseas/subscription-management.html#/"
    }
    
    ///短视频分享
    class func shareShortVideo(langType: String, id: String) -> String {
        return YXUrlRouterConstant.staticResourceUrlForBeerichShare() + "/webapp/exchange/short-video.html?id=\(id)&langType=\(langType)&appType=11"
    }
    
    ///短视频举报
    class func shortVideoReport() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/exchange/report-detail.html?appType=12"
    }

    // 人工策略详情
    class func manualUrl(strategyId: Int) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/manual/detail/\(strategyId)"
    }

    class func fundUrl(strategyId: Int) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/stock-king/strategy.html#/fund/detail/\(strategyId)"
    }

    // 帮助详情页 url
    class func helpDetailURL(with id: String) -> String {
        return "\(YXUrlRouterConstant.staticResourceBaseUrl())/webapp/market/generator.html?id=\(id)"
    }

    ///资产指标说明
    class func assetsDesc(accountType: String) -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/apply/desc.html?accountType=\(accountType)#/sg-assets-desc"
    }

    ///sg升级保证金
    class func sgUpgradeMarginUrl() -> String {
        return YXUrlRouterConstant.staticResourceBaseUrl() + "/acct/cash-margin/index.html#/sg-cash-advantage"
    }
    
    //止损说明
    class func otcRiskTipUrl() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=OTC_Stock_Trading"
    }
    
    //止损说明
    class func bitcoinETFDocUrl() -> String {
        YXUrlRouterConstant.staticResourceBaseUrl() + YX_H5_PATHS + "?key=BitcoinETFDoc"
    }
    
}

extension SmartOrderType {
    fileprivate func key(with market: String) -> String {
        var string: String = ""
        if market == kYXMarketUsOption {
            string = "qq"
        }
        switch self {
        case .stopProfitSell,
             .stopProfitSellOption:
            string += "zhiyingmaichu"
        case .stopLossSell,
             .stopLossSellOption:
            string += "zhisunmaichu"
        case .tralingStop:
            string += "genzongzhisun"
        case .highPriceSell:
            string += "gaojiamaichu"
        case .breakSell:
            string += "diepomaichu"
        case .breakBuy:
            string += "tupomairu"
        case .lowPriceBuy:
            string += "dijiamairu"
        case .priceHandicap:
            string += "jiagepankouchufa"
        case .stockHandicap:
            string += "guanlianzichanchufa"
        case .grid:
            string += "wangluotiaojiandingdan"
        default:
            string += ""
        }
        return string
    }
}
