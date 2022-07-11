//
//  YXNewsType.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//http://szshowdoc.youxin.com/web/#/23?page_id=315
enum YXNewsType: Int {
    case newStock = 1       //新股中心首页
    case openAccountGuide   //开户引导页
    case openAccountGuide2  //继续开户引导页
    case openAccountResult  //开户结果页
    case register = 5       //注册页
    case login              //登录页
    case personalCenterHome     //个人中心-首页
    case personalCenterQuotes   //个人中心-我的行情
    case personalCenterHelp     //个人中心-帮助中心
    case MonthStock = 10        //月供股页
    case quotesBuy              //行情购买页
    case tradePosition          //交易持仓页
    case infomationChannel      //资讯频道页
    case selfStock              //自选股页
    case stockStrategy = 15     //智投頁 Banner1
    case loginBindPhone = 16    //登录引导绑定手机号页面
    case openAccountSucceed = 17//开户提交成功资源位。
    case newStockApply = 18     //新股认购页面
    case newStockDetail = 19    //新股详情页面
    case search = 32            //搜索(港版)
    case stockStrategy2 = 102   //智投頁 Banner2
    case course = 109           //资讯课程
    case stockDetail = 113      //个股详情
    case dailyFunding = 114     //日内融列表页
}

enum YXOtherAdvertisementShowPage: Int {
    case activity           = 1     //活动中心
    case optional           = 2     //自选股
    case floatWindow        = 3     //浮窗
    case youXinBao          = 6     //友信宝入口
    case activityOutBanner  = 8     //活动中心露出广告位
}

//banner页面 1：自选股页；2：个人中心-首页；   pop浮窗广告  1 自选 7 市场 8策略
//enum YXNewsAdType: Int { //注释掉dolphin的字段对应逻辑
//
//    case selfStock   = 1            //自选股页、市场与自选合并了，自选即首页
//    case personalCenterHome  = 2   //个人中心-首页
//    case maket = 7                //市场
//    case stockStrategy = 8     //策略 Banner1
//    case stockStrategy2 = 102   //策略 Banner2
//}

//sg的banner广告对应关系
enum YXNewsAdType: Int {
    
    case selfStock   = 1            //自选股页、市场与自选合并了，自选即首页
    case disover   = 2            //策略
    case account   = 3            //账户
    case personalCenterHome  = 4   //个人中心-首页
    case advRegisterLogin  = 6   //登录注册页
    case maket = 7                //市场
    case stockStrategy = 8     //策略 Banner1
    case stockStrategy2 = 102   //策略 Banner2
}

