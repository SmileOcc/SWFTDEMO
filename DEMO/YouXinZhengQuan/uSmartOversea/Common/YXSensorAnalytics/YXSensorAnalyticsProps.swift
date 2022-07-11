//
//  YXSensorAnalyticsEvents.swift
//  uSmartEducation
//
//  Created by 胡华翔 on 2018/12/4.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers class YXSensorAnalyticsPropsConstant : NSObject{
    static let PROP_PREFIX             = ""
    
    // 属性：点击事件
    static let PROP_PAGE_BTN            = PROP_PREFIX + "page_btn"
    // 属性：视图行为
    static let PROP_VIEW_ACTION          = PROP_PREFIX + "page_act"
    // 属性：视图页面
    static let PROP_VIEW_PAGE            = PROP_PREFIX + "page_name"
    //
    static let PROP_PAGE_MEDIA            = PROP_PREFIX + "page_media"

    // 回放ID
    static let PROP_VIDEO_ID            = PROP_PREFIX + "video_id"   //String类型
    
    static func stockID(market: String?, symbol: String?) -> String {
        (market ?? "") + (symbol ?? "")
    }
}

//资讯来源
@objcMembers class YXPropInfoSourceValue : NSObject {

    //id banner
    static let adBanner = "ad_banner"

    //资讯banner
    static let infoBanner = "info_banner"

    //7x24
    static let seven24 = "7x24_marquee"

    //今日焦点
    static let todayFocus = "today_focus"

    //早报
    static let moringPaper = "moring_paper"

    //午报
    static let noonPaper = "noon_paper"

    //晚报
    static let eveningPaper = "evening_paper"

    //美股前瞻
    static let usOutlook = "us_outlook"

    //推荐
    static let infoRecommend = "info_recommend"

    //自选
    static let infoOptional = "info_optional"

    //收藏
    static let mineCollect = "mine_collect"

    //个股新闻
    static let infoStock = "info_stock"

    //个股重点关注新闻
    static let infoFocusStock = "info_focus_stock"
}

