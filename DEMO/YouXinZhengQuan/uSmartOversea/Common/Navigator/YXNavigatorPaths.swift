//
//  YXNavigatorPaths.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public protocol YXModuleType {
    var scheme: String { get }
    
    var path: String { get }
    
    var url: String { get }
}

@objc protocol YXModulePathServices {
    @objc func pushPath(_ path: YXModulePaths, context: Any?, animated: Bool)
    @objc func presentPath(_ path: YXModulePaths, context: Any?, animated: Bool, completion: (() -> Void)?)
}

@objc enum YXModulePaths: Int {
    // 自选股
    case opitonal
    
    // 智能盯盘
    case smartWatch
    
    // 代码搜索
    case search
    
    // 代码搜索(用于股票详情)
    case pushSearch

    // 综合搜索
    case aggregatedSearch

    case pushAggregatedSearch
    
    // 用户中心
    case userCenter
 
    // 用户中心-设置
    case userCenterSet
    
    // 用户中心-收藏
    case userCenterCollect
    
    // 用户中心-账户与安全
    case userCenterUserAccount
    
    // 注册Code
    case registerCode
    
    // 普通用户注册Code
    case normalRegisterCode
    
    // 普通用户注册设置密码
    case normalRegisterSetPwd
    
    // 关于
    case userCenterAbout
    
    // 反馈
    case userCenterFeedback
    
    // 风险测评
    case userCenterBondRisk
    
    // 个股详情
    case stockDetail

    //k线设置
    case stockDetailChartSetting

    // 网页浏览
    case webView
    
    // 用户默认登录页
    case defaultLogin
    
    // 用户密码登录
    case passwordLogin
    
    // 忘记密码-输入手机
    case forgetPwdInputPhone
    
    // 注册输入手机号
    case registerPhone
    
    // 双重验证
    case doubleCheck
    
    // 修改密码
    case changePwd
    
    // 设置新的密码
    case changePhoneOld
    
    // 验证新密码
    case changePhoneNew
    
    // 修改邮箱
    case changeEmail
    
    // 修改交易密码
    case changeTradePwd
    
    // 验证
    case authenticate
    
    // 通知
    case noti
    
    case skin
    
    // 绑定手机
    case bindPhone
    
    // 登录绑定手机
    case loginBindPhone
    // 登录--证件号码激活
    case loginIdNumActivate
    // 第三方平台登录--证件号码激活
    case thirdLoginIdNumActivate
    
    // 绑定验证手机
    case bindCheckPhone
    
    // 重置交易密码验证邮箱
    case verifyEmail
    
    // 调试配置
    case debugInfo
    
    // JS调试配置
    case jsDebugInfo
    
    // 开户引导页
    case openAccountGuide
    // 登录注册开户引导页
    case loginOpenAccountGuide
    
    // 开户页
    case openAccount
    
    // 美股行情权限声明
    case USAuthState
    
    // 忘记密码设置密码
    case forgetPwdSet
    
    // 忘记密码验证码
    case forgetPwdCode
    
    // 历史记录
    case history
    
    // 转入股票
    case shiftInStock
    
    // 转入股票历史记录
    case shiftInHistory
    
    // 货币兑换
    case exchange
    
    // 新股中心
    case newStockCenter
    
    // 新股市场
    case newStockMarket
    
    //已递表列表
    case newStockDelivered
    
    // 新股支付列表
    case newStockPurcahseList
    
    // 新股明细
    case newStockDetail
    
    // IPO新股支付
    case newStockIPOPurchase
    
    // 美股认购
    case newStockUSPurchase
    
    // ECM新股支付
    case newStockECMPurchase
    
    //美股确认页
    case newStockUSConfirm
    
    // IPO新股认购明细
    case newStockIPOListDetail
    
    // ECM新股认购明细
    case newStockECMListDetail

    // 个人资料
    case personalData
    
    // 隐私协议
    case appPrivacy
    // 跳转 修改昵称
    case modifyNickName
    
    case smartSettings
    
    case forgetPwdPhone
    
    case setLoginPwd
    
    // 交易下单页面
    case trading
    
    // 持仓列表
    case holdList
    
    // 订单列表
    case orderList
    
    // 条件列表
    case conditionList
    
    // 订单详情
    case orderDetail
    
    // 帮助与客服
    case onlineService
    
    // 资讯详情
    case infoDetail
    
    // ETF
    case stockETF
    
    // 股票提醒
    case stockRemindSetting
    
    // 我的提醒
    case myRemind
    
    // 简介
    case stockBrief
    
    // 财务
    case stockFinancial
    
    // 公告
    case stockAnnounce
    
    // 股票详情页点击查看更多后跳转的新闻列表
    case stockNewsList
    
    // 资讯
    case infomations
    
    // 图片导入自选股
    case importPic
    
    // 简况
    case stockIntroduce
    
    // 简况
    case HSStockIntroduce

    //新股国际认购签名页
    case newStockSignature
    
    //分析
    case stockAnaylze
    //轮证
    case stockWarrants
    
    //窝轮牛熊和牛熊街货
    case warrantsAndStreet
    
    //轮证筛选
    case stockWarrantsSort
    
    //轮证搜索
    case stockWarrantsSearch

    // 横屏个股
    case landStockDetail

    
    // 个人设置
    case preferenceSetting
    
    // 报价图表
    case setStockQuote
    
    // 优惠信息设定
    case promotionMsg
    // 股票和债券持仓列表
    case mixHoldList
    // 选择区号
    case areaCodeSelection
    //所属行业
    case stockIndustry
    //所属行业横屏
    case stockIndustryLand
    
    // 股票和债券订单列表
    case mixOrderList

    //债券订单详情
    case bondOrderDetail

    // 市场
    case market
    
    // 港股adr
    case hkADR
    
    // 热门行业列表
    case hotIndustryList
    
    // 横屏自选股
    case optionalListLand
    
    // 交易更多
    case tradeMore
    
    // 全部订单
    case allOrderList
    
    // 全部条件单
    case allConditionOrderList

    // 筹码详情
    case chipDetail
    
    // 可融资列表
    case financingList

    //选股器行业列表
    case filterIndustry
    
    //盘前盘后排行榜
    case preAfterRank
    
    //快捷入口
    case shortCuts

    //K线对比
    case klineVS

    case klineVSLand
    
    //机构户手机登录
    case orgDefaultLogin
    //机构户密码登录
    //机构户检查账号
    case orgForgetPwdCheckAccount
    //机构登录重置密码
    case orgForgetPwdReset
    
    //机构激活
    case orgActiviteAccount
    //机构激活检查
    case orgCheckActiviteAccount
    
    //机构检查注册编码
    case orgCheckRegisterNumber
    //机构检查注册邮箱
    case orgCheckRegisterEmail
    
    case orgAccount
    
    case etfrank
    //注册页
    case signUp
    //确认修改
    case verifyChange
    // 绑定邮箱
    case bindEmail
    //设置交易密码
    case setTradePwd
    
    // 网页浏览(顶部带行情）
    case quoteWebView
    //NZ券商设置页
    case nzSettings
    //IB账户详情页
    case IBAccount
    //券商登陆
    case brokerLogin

    //课程详情
    case courseDetail
    //课程列表
    case courseList

    //MARK: 投教相关的跳转
    //投教关注的用户主页
    case kolHome
    case ask //问股
    
    case doubleLoginSet   //登录双重验证设置
    case doubelAuthLogin  //双重登录验证
    //kol短视频播放页
    case kolShortVideoPlay
    case moduleMore // 更多

    case myAssetsDetail
    
    case dividends
}

let NavigatiorScheme = "usmart://"

extension YXModulePaths: YXModuleType {
    var scheme: String {
        NavigatiorScheme
    }
    
    var path: String {
        switch self {
        case .opitonal:
            return "optional/"
        case .smartWatch:
            return "smartWatch/"
        case .search:
            return "search/"
        case .pushSearch:
            return "pushSearch/"
        case .aggregatedSearch:
            return "aggregatedSearch/"
        case .pushAggregatedSearch:
            return "pushAggregatedSearch/"
        case .userCenter:
            return "userCenter/"
        case .userCenterSet:
            return "userCenter/set/"
        case .userCenterCollect:
            return "userCenter/Collect/"
        case .registerCode:
            return "registerCode/"
        case .normalRegisterCode:
            return "normalRegisterCode/"
        case .normalRegisterSetPwd:
            return "normalRegisterSetPwd/"
        case .userCenterAbout:
            return "userCenter/about/"
        case .userCenterFeedback:
            return "userCenter/collect/"
        case .userCenterBondRisk:       // 风险测评
            return "userCenter/bondRisk/"
        case .stockDetail:
            return "stockDetail/"
        case .stockDetailChartSetting:
            return "stockDetailChartSetting/"
        case .webView:
            return "webView/"
        case .defaultLogin:
            return "defaultLogin/"
        case .passwordLogin:
            return "passwordLogin/"
        case .forgetPwdInputPhone:
            return "forgetPwdInputPhone/"
        case .registerPhone:
            return "registerPhone/"
        case .doubleCheck:
            return "doubleCheck/"
        case .changePwd:
            return "changePwd/"
        case .changePhoneOld:
            return "changePhoneOld/"
        case .changePhoneNew:
            return "changePhoneNew/"
        case .changeEmail:
            return "changeEmail/"
        case .changeTradePwd:
            return "changeTradePwd/"
        case .authenticate:
            return "authenticate/"
        case .noti:
            return "noti/"
        case .skin:
            return "skin/"
        case .bindPhone:
            return "bindPhone/"
        case .loginBindPhone:
            return "loginBindPhone/"
        case .loginIdNumActivate:
            return "loginIdNumActivate/"
        case .thirdLoginIdNumActivate:
            return "thirdLoginIdNumActivate/"
        case .bindCheckPhone:
            return "bindCheckPhone/"
        case .verifyEmail:
            return "verifyEmail/"
        case .debugInfo:
            return "debugInfo/"
        case .jsDebugInfo:
            return "jsDebugInfo/"
        case .openAccountGuide:
            return "openAccountGuide/"
        case .loginOpenAccountGuide:
            return "loginOpenAccountGuide/"
        case .openAccount:
            return "openAccount/"
        case .USAuthState:
            return "USAuthState/"
        case .forgetPwdSet:
            return "forgetPwdSet/"
        case .forgetPwdCode:
            return "forgetPwdCode/"
        case .history:
            return "history/"
        case .shiftInStock:
            return "shiftInStock/"
        case .shiftInHistory:
            return "shiftInHistory/"
        case .exchange:
            return "exchange/"
        case .newStockCenter:
            return "newStockCenter/"
        case .newStockMarket:
            return "newStockMarket/"
        case .newStockDelivered:
            return "newStockDelivered/"
        case .newStockPurcahseList:
            return "newStockPurcahseList/"
        case .newStockDetail:
            return "newStockDetail/"
        case .newStockIPOPurchase:
            return "newStockIPOPurchase/"
        case .newStockUSPurchase:
            return "newStockUSPurchase/"
        case .newStockECMPurchase:
            return "newStockECMPurchase/"
        case .newStockUSConfirm:
            return "newStockUSConfirm/"
        case .newStockIPOListDetail:
            return "newStockIPOListDetail/"
        case .newStockECMListDetail:
            return "newStockECMListDetail/"
        case .personalData:
            return "personalData/"
        case .appPrivacy:
            return "appPrivacy/"
        case .modifyNickName:
            return "modifyNickName/"
        case .userCenterUserAccount:
            return "userCenterUserAccount/"
        case .smartSettings:
            return "smartSettings/"
        case .forgetPwdPhone:
            return "forgetPwdPhone/"
        case .setLoginPwd:
            return "setLoginPwd/"
        case .trading:
            return "trading/"
        case .holdList:
            return "holdList/"
        case .onlineService:
            return "onlineService/"
        case .orderList:
            return "orderList/"
        case .conditionList:
            return "conditionList/"
        case .infoDetail:
            return "infoDetail"
        case .orderDetail:
            return "orderDetail/"
        case .stockETF:
             return "stockETF/"
        case .stockRemindSetting:
            return "stockRemindSetting/"
        case .myRemind:
            return "myRemind/"
        case .stockBrief:
            return "stockBrief/"
        case .stockFinancial:
            return "stockFinancial/"
        case .stockAnnounce:
            return "stockAnnounce/"
        case .stockNewsList:
            return "stockNewsList/"
        case .importPic:
            return "importPic/"
        case .stockIntroduce:
            return "stockIntroduce/"
        case .newStockSignature:
            return "newStockSignature/"
        case .stockAnaylze:
            return "stockAnaylze/"
        case .stockWarrants:
            return "stockWarrants/"
        case .stockWarrantsSort:
            return "stockWarrantsSort/"
        case .stockWarrantsSearch:
            return "stockWarrantsSearch/"
        case .landStockDetail:
            return "landStockDetail/"
        case .preferenceSetting:
            return "preferenceSetting/"
        case .setStockQuote:
            return "setStockQuote/"
        case .mixHoldList:
            return "mixHoldList/"
        case .promotionMsg:
            return "promotionMsg/"
        case .HSStockIntroduce:
            return "HSStockIntroduce/"
        // 选择区号
        case .areaCodeSelection:
            return "areaCodeSelection/"
        case .stockIndustry:
            return "stockIndustry/"
        case .stockIndustryLand:
            return "stockIndustryLand/"
        case .mixOrderList:
            return "mixOrderList/"
        case .bondOrderDetail:
            return "bondOrderDetail/"
        case .infomations:
            return "infomationsList/"
        case .market:
            return "market/"
        case .hkADR:
            return "hkADR/"
        case .hotIndustryList:
            return "hotIndustryList/"
        case .optionalListLand:
            return "optionalListLand/"
        case .warrantsAndStreet:
            return "warrantsAndStreet/"
        case .tradeMore:
            return "tradeMore/"
        case .allOrderList:
            return "allOrderList/"
        case .allConditionOrderList:
            return "allConditionOrderList/"
        case .chipDetail:
            return "chipDetail/"
        case .financingList:
            return "financingList/"
        case .filterIndustry:
            return "filterIndustry/"
        case .preAfterRank:
            return "preAfterRank/"
        case .shortCuts:
            return "shortCuts/"
        case .orgDefaultLogin:
            return "orgDefaultLogin/"
        case .orgForgetPwdCheckAccount:
            return "orgForgetPwdCheckAccount/"
        case .orgForgetPwdReset:
            return "orgForgetPwdReset/"
        case .orgActiviteAccount:
            return "orgActiviteAccount/"
        case .orgCheckActiviteAccount:
            return "orgCheckActiviteAccount/"
        case .orgCheckRegisterNumber:
            return "orgCheckRegisterNumber/"
        case .orgCheckRegisterEmail:
            return "orgCheckRegisterEmail/"
        case .orgAccount:
            return "orgAccount/"
        case .klineVS:
            return "klineVS/"
        case .klineVSLand:
            return "klineVSLand/"
        case .etfrank:
            return "etfrank/"
        case .signUp:
            return "signUp/"
        case .verifyChange:
            return "verifyChange/"
        case .bindEmail:
            return "bindEmail/"
        case .setTradePwd:
            return "setTradePwd/"
        case .quoteWebView: // 网页浏览(顶部带行情）
            return "quoteWebView/"
        case .nzSettings:
            return "nzSetting/"
        case .IBAccount:
            return "IBAccount/"
        case .brokerLogin:
            return "brokenLogin/"
        case .courseDetail:
            return "courseDetail/"
        case .courseList:
            return "courseList/"
        case .kolHome:
            return "kol_personal/"
        case .ask:
            return "ask/"
        case .doubleLoginSet:
            return "doubleLoginSet/"
        case .doubelAuthLogin:
            return "doubelAuthLogin/"
        case .kolShortVideoPlay:
            return "short_video/"
        case .moduleMore:
            return "moduleMore/"
        case .myAssetsDetail:
            return "myAssetsDetail/"
        case .dividends:
            return "dividends/"
        }
    }
    
    var url: String {
        scheme + path
    }
}
