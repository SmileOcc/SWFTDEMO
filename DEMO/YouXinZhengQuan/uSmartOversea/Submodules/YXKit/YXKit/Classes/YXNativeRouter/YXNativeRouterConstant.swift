//
//  YXNativeRouterConstant.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers public class YXNativeRouterConstant: NSObject {
// 伪Scheme
// 并未遵循苹果官方Scheme规范，因为直接使用UIApplication直接无法打开这个伪Scheme的Url
// V1版本SCHEME
public static let YXZQ_SCHEME_V1 = "yxzq_goto://"
// V2版本SCHEME
public static let YXZQ_SCHEME = "usmart-goto://"

/*
 个股详情页
 带参数market和code；market和code参数必须的，没有不会跳转
 例如：usmart-goto://stock_quote?market=sh&code=600837
 */
public static let GOTO_STOCK_QUOTE = YXZQ_SCHEME + "stock_quote"

public static let GOTO_STOCK_QUOTE_DISCUSSION = YXZQ_SCHEME + "stock_quote_discussion"
/*
 入金
 例如：usmart-goto://deposit
 */
public static let GOTO_DEPOSIT = YXZQ_SCHEME + "deposit"

/*
 出金
 例如：usmart-goto://withdrawal
 */
public static let GOTO_WITHDRAWAL = YXZQ_SCHEME + "withdrawal"

/*
 用户登录
 例如：usmart-goto://user_login
 */
public static let GOTO_USER_LOGIN = YXZQ_SCHEME + "user_login"

/*
 交易登录
 例如：usmart-goto://trade_login
 */
public static let GOTO_TRADE_LOGIN = YXZQ_SCHEME + "trade_login"
/*
一级页面 行情页tab
例如：usmart-goto://quotes
*/
public static let GOTO_QUOTES = YXZQ_SCHEME + "quotes"

/*
1级页面 发现页tab
例如：usmart-goto://discover
*/
public static let GOTO_DISCOVER = YXZQ_SCHEME + "discover"

/*
 自选股行情页
 例如：usmart-goto://main_optstocks
 */
public static let GOTO_MAIN_OPTSTOCKS = YXZQ_SCHEME + "main_optstocks"

/*
 港股市场行情页
 例如：usmart-goto://main_hkmarket
 */
public static let GOTO_MAIN_HKMARKET = YXZQ_SCHEME + "main_hkmarket"

/*
 美股市场行情页
 例如：usmart-goto://main_usmarket
 */
public static let GOTO_MAIN_USMARKET = YXZQ_SCHEME + "main_usmarket"
  
/*
sg市场行情页
例如：usmart-goto://main_sgmarket
*/
public static let GOTO_MAIN_SGMARKET = YXZQ_SCHEME + "main_sgmarket"

/*
 沪深市场行情页
 例如：usmart-goto://main_hsmarket
 */
public static let GOTO_MAIN_HSMARKET = YXZQ_SCHEME + "main_hsmarket"

/*
 资讯主页
 例如：usmart-goto://main_info
 */
public static let GOTO_MAIN_INFO = YXZQ_SCHEME + "main_info"

/*
 交易菜单页
 例如：usmart-goto://main_trade
 */
public static let GOTO_MAIN_TRADE = YXZQ_SCHEME + "main_trade"

/*
 课程主页
 例如：usmart-goto://main_info
 */
public static let GOTO_MAIN_INFO_COURSE = YXZQ_SCHEME + "main_info_course"

/*
 直播
 例如：usmart-goto://live_list
 */
public static let GOTO_INFO_LIVE = YXZQ_SCHEME + "live_list"

/*
 直播页面
例如：usmart-goto://push_live pushId=xxx
*/
public static let GOTO_PUSH_LIVE = YXZQ_SCHEME + "push_live"

/*
 打开资讯-课程-我的课程
 例如：usmart-goto://main_info_my_course
 */
public static let GOTO_MAIN_INFO_MY_COURSE = YXZQ_SCHEME + "main_info_my_course"

/*
 “我的”菜单页
 例如：usmart-goto://main_personal
 */
public static let GOTO_MAIN_PERSONAL = YXZQ_SCHEME + "main_personal"

/*
 开户
 例如：usmart-goto://open_account
 */
public static let GOTO_OPEN_ACCOUNT = YXZQ_SCHEME + "open_account"

/*
 消息中心
 例如：usmart-goto://message_center
 */
public static let GOTO_MESSAGE_CENTER = YXZQ_SCHEME + "message_center"

/*
 消息中心-消息详情
 例如：usmart-goto://message_detail
 */
public static let GOTO_MESSAGE_DETAIL = YXZQ_SCHEME + "message_detail"

/*
 交易股票
 可带参数market和code，也可不带
 例如：usmart-goto://stock_trade?market=sh&code=600837
 */
public static let GOTO_STOCK_TRADE = YXZQ_SCHEME + "stock_trade"

/*
 Native Webview页面
 可带参数title和url
 例如：usmart-goto://webview?title=xxx&url=xxx
 */
public static let GOTO_WEBVIEW = YXZQ_SCHEME + "webview"

/*
 资讯详情页面
 可带参数title、type和newsid
 例如：usmart-goto://info_detail?type=x&title=xxx&newsid=xxxxx
 */
public static let GOTO_INFO_DETAIL = YXZQ_SCHEME + "info_detail"

/*
 历史记录页面
 可带参数type
 0: 全部类型
 1：入金
 2：出金
 3：货币兑换
 例如：usmart-goto://fund_history_record?type=0
 */
public static let GOTO_FUND_HISTORY_RECORD = YXZQ_SCHEME + "fund_history_record"

/*
 跳转意见反馈页面
 */
public static let GOTO_FEEDBACK = YXZQ_SCHEME + "feedback"

/*
 电话
 带参数phoneNumber
 例如：usmart-goto://tel?phoneNumber=4008880808
 */
public static let GOTO_TEL = YXZQ_SCHEME + "tel"

/*
 在线客服
 例如：usmart-goto://customer_service
 */
public static let GOTO_CUSTOMER_SERVICE = YXZQ_SCHEME + "customer_service"


/*
 智能盯盘
 例如：usmart-goto://smart_monitor
 */
public static let GOTO_SMART_MONITOR = YXZQ_SCHEME + "smart_monitor"

/*
 交易订单
 例如：usmart-goto://smart_monitor
 */
public static let GOTO_ORDER_RECORD = YXZQ_SCHEME + "order_record"

/*
 IPO首页
 例如：usmart-goto://ipo_center
 */
public static let GOTO_IPO_CENTER = YXZQ_SCHEME + "ipo_center"

/*
 IPO详情页
 例如：usmart-goto://ipo_detail
 */
public static let GOTO_IPO_DETAIL = YXZQ_SCHEME + "ipo_detail"

/*
 IPO认购下单页
 例如：usmart-goto://ipo_purchase_order
 */
public static let GOTO_IPO_PURCHASE_ORDER = YXZQ_SCHEME + "ipo_purchase_order"

/*
 IPO购买记录
 例如：usmart-goto://ipo_purchase_list
 */
public static let GOTO_IPO_PURCHASE_LIST = YXZQ_SCHEME + "ipo_purchase_list"

/*
 首页股王页面
 例如：usmart-goto://main_stockking
 */
public static let GOTO_MAIN_STOCKKING = YXZQ_SCHEME + "main_stockking"

/*
 首页动态页面
 例如：usmart-goto://main_moments
 */
public static let GOTO_MAIN_MOMENTS = YXZQ_SCHEME + "main_moments"

/*
 持仓列表页
 例如：usmart-goto://hold_position
 */
public static let GOTO_HOLD_POSITION = YXZQ_SCHEME + "hold_position"

/*
 转股列表
 例如：usmart-goto://conversion_record
 */
public static let GOTO_CONVERSION_RECORD = YXZQ_SCHEME + "conversion_record"

/*
 换汇页
 例如：usmart-goto://currency_exchange
 */
public static let GOTO_CURRENCY_EXCHANGE = YXZQ_SCHEME + "currency_exchange"

/*
 交易tab今日订单
 例如：usmart-goto://today_order
 */
public static let GOTO_TRADE_TODAYORDER = YXZQ_SCHEME + "today_order"

/*
 基金tab
 例如：usmart-goto://main_fund
 */
public static let GOTO_MAIN_FUND = YXZQ_SCHEME + "main_fund"

/*
 新股认购记录详情页
 例如：usmart-goto://purchase_record_detail
 */
public static let GOTO_NEWSTOCK_PURCHASE_DETAIL = YXZQ_SCHEME + "purchase_record_detail"

/*
 关于的界面
 例如：usmart-goto://about
 */
public static let GOTO_ABOUT_DETAIL = YXZQ_SCHEME + "about"

/*
 我的收藏
 例如：usmart-goto://mine_collect
 */
public static let GOTO_MINE_COLLECT = YXZQ_SCHEME + "mine_collect"

/*
 搜索
 例如：usmart-goto://search
 */
public static let GOTO_SEARCH = YXZQ_SCHEME + "search"

/*
 新股中心待上市列表
 例如：usmart-goto://ipo_waiting
 */
public static let GOTO_IPO_PREMARKET = YXZQ_SCHEME + "ipo_waiting"

/*
 观看直播
 例如：usmart-goto://live_audience?pusId=xxx
 */
public static let GOTO_LIVE_AUDIENCE = YXZQ_SCHEME + "live_audience"


/*
 资金调拨
 例如：usmart-goto://bank_treasurer?market=hk
 */
public static let GOTO_BANK_TREASURER = YXZQ_SCHEME + "bank_treasurer"

/*
 排行列表
 例如：usmart-goto://market_rank?rankType=hotIndustry&market=hk&rankCode=xxx
 */
public static let GOTO_MARKET_RANK = YXZQ_SCHEME + "market_rank"

/*
 选股器
 例如：usmart-goto://stock_screener?market=hk
 */
public static let GOTO_STOCK_SCREENER = YXZQ_SCHEME + "stock_screener"

/*
 市场轮证
 例如：usmart-goto://market_warrants
 */
public static let GOTO_MARKET_WARRANTS = YXZQ_SCHEME + "market_warrants"

/*
 跳转视频
 例如：usmart-goto://info_video
 */
public static let GOTO_INFO_VIDEO = YXZQ_SCHEME + "info_video"

/*
 消息通知设置
 例如：usmart-goto://message_notice_settings
 */
public static let GOTO_MESSAGE_NOTICE_SETTINGS = YXZQ_SCHEME + "message_notice_settings"
    
/*
 App设置页面
 例如：usmart-goto://app_settings
 */
public static let GOTO_APP_SETTINGS = YXZQ_SCHEME + "app_settings"

/*
 暗盘列表
 例如：yxzq_goto://grey_market_list
 */
public static let GOTO_GREY_MARKET_LIST = YXZQ_SCHEME + "grey_market_list"
    
/*
 全部轮证
 例如：yxzq_goto://grey_market_list
*/
public static let GOTO_ALL_WARRANTS = YXZQ_SCHEME + "warrant_all"
    
/*
 期权搜索
 例如：yxzq_goto://option_search
*/
public static let GOTO_OPTION_SEARCH = YXZQ_SCHEME + "option_search"
    
/*
 期权链
 例如：yxzq_goto://option_chain
*/
public static let GOTO_OPTION_CHAIN = YXZQ_SCHEME + "option_chain"

/*
港股ETF
例如：yxzq_goto://hk_etf
*/
public static let GOTO_HK_ETF = YXZQ_SCHEME + "hk_etf"

/*
AH股
例如：yxzq_goto://ah_rank
*/
public static let GOTO_AH_RANK = YXZQ_SCHEME + "ah_rank"
    
/*
ADR
例如：yxzq_goto://adr?market=hk&title=港股adr
*/
public static let GOTO_ADR = YXZQ_SCHEME + "adr"
    
/*
区间涨幅
例如：yxzq_goto://range_rank?market=hk
*/
public static let GOTO_RANGE_RANK = YXZQ_SCHEME + "range_rank"
    
/*
盘前盘后
例如：yxzq_goto://pre_after_rank
*/
public static let GOTO_PRE_AFTER_RANK = YXZQ_SCHEME + "pre_after_rank"
    
/*
全部智能单
例如：yxzq_goto://all_smart_orders?market=hk
*/
public static let GOTO_ALL_SMART_ORDERS = YXZQ_SCHEME + "all_smart_orders"
    
/*
条件单
例如：yxzq_goto://all_condition_orders?market=hk
*/
public static let GOTO_ALL_CONDITION_ORDERS = YXZQ_SCHEME + "all_condition_orders"
    
/*
 智能下单-菜单页
 例如：yxzq_goto://smart_trade_menu
     market=hk
     code=00700(选填，不填从菜单进入下单页无股票)

 */
public static let GOTO_SMART_TRADE_MENU = YXZQ_SCHEME + "smart_trade_menu"
    
    /*
     首页
     例如：yxzq_goto://smart_trade_menu
     */
    public static let GOTO_SMART_HOME = YXZQ_SCHEME + "home"
    
    /*
     盈广场
     例如：yxzq_goto://square
     */
    public static let GOTO_SMART_SQUARE = YXZQ_SCHEME + "square"
    
    /*
     盈财经个人信息流
     例如：yxzq_goto://ugc_user_flow
     */
    public static let GOTO_SMART_USER_FLOW = YXZQ_SCHEME + "ugc_user_flow"
    
    /*
     盈财经个人信息流
     例如：yxzq_goto://ugc_content_detail?type=1&id=123
     */
    public static let GOTO_UGC_CONTENT_DETAIL = YXZQ_SCHEME + "ugc_content_detail"

    /*
     盈财经快讯
     例如：yxzq_goto://flash_news
     */
    public static let GOTO_FLASH_NEWS = YXZQ_SCHEME + "flash_news"

    public static let GOTO_INFO_RECOMMEND = YXZQ_SCHEME + "info_recommend "
    
    public static let GOTO_INFO_OPTIONAL = YXZQ_SCHEME + "info_optional"

    /*
     海外版绑定邮箱
     例如：yxzq_goto://bind_email
     */
    public static let GOTO_SMART_BIND_EMAIL = YXZQ_SCHEME + "bind_email"
        
    /*
     经济商持股详情
     例如：yxzq_goto://broker_stock_detail
     */
    public static let GOTO_BROKER_STOCK_DETAIL = YXZQ_SCHEME + "broker_stock_detail"
        
    /*
     转入股票
     例如：yxzq_goto://shiftin_stock
     */
    public static let GOTO_SHIFTIN_STOCK = YXZQ_SCHEME + "shiftin_stock"
    
    /*
     我的结单
     例如：yxzq_goto://statement
     */
    public static let GOTO_STATEMENT = YXZQ_SCHEME + "statement"
    
    /*
     投教首页
     例如：usmart-goto://main_home
     */
    public static let GOTO_NBB_HOME = YXZQ_SCHEME + "main_home"
    
    /*
     投教我的
     例如：usmart-goto://main_mine
     */
    public static let GOTO_NBB_MINE = YXZQ_SCHEME + "main_mine"
    
    /*
     投教课程
     例如：usmart-goto://main_course
     */
    public static let GOTO_NBB_COURSE = YXZQ_SCHEME + "main_course"
    /*
     投教 学习-课程
     例如：yxzq_goto://learn_course
     */
    public static let GOTO_SMART_LEARN_COURSE = YXZQ_SCHEME + "learn_course"
    /*
     投教大咖
     例如：usmart-goto://main_course
     */
    public static let GOTO_NBB_MASTER = YXZQ_SCHEME + "main_master"
    /*
     打开浏览器
     例如：usmart-goto://goto_native_browser
     */
    public static let GOTO_NBB_BROWSE = YXZQ_SCHEME + "goto_native_browser"
    /*
     打开浏览器
     例如：usmart-goto://short_video/?id=xxx
     */
    public static let GOTO_NBB_SHORT_VIDEO = YXZQ_SCHEME + "short_video"
    /*
     打开股价提醒
     例如：usmart-goto://stock_price_remind?market=xx&code=xx
     */
    public static let GOTO_STOCK_PRICE_REMIND = YXZQ_SCHEME + "stock_price_remind"
    /*
     投教课程详情
     例如：usmart-goto://course_detail?courseId=xxx&lessonId=xxx
     */
    public static let GOTO_NBB_COURSE_DETAIL = YXZQ_SCHEME + "course_detail"
        /*
     投教Kol主页
     例如：usmart-goto://kol_personal?kolId=xxx
     */
    public static let GOTO_NBB_KOL_PERSONAL = YXZQ_SCHEME + "kol_personal"
    /*
     直播详情页
     例如：usmart-goto://live_detail?id=xxx
     */
    public static let GOTO_NBB_LIVE_DETAIL = YXZQ_SCHEME + "live_detail"
    /*
     回放详情页
     例如：usmart-goto://replay_detail?id=xxx
     */
    public static let GOTO_NBB_REPLAY_DETAIL = YXZQ_SCHEME + "replay_detail"
    
    /*
     理财tab页
     例如：usmart-goto://main_finance
     */
    public static let GOTO_MAIN_FINANCE = YXZQ_SCHEME + "main_finance"
}
