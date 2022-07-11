//
//  YXSensorAnalyticsEvents.swift
//  uSmartEducation
//
//  Created by 胡华翔 on 2018/12/4.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

let APP_ID = "yxstock_app"

let EVENT_PREFIX = APP_ID + "_"

@objc public enum YXSensorAnalyticsEvent: Int, RawRepresentable {
    case Unknown, SystemLog, ViewClick, ViewScreen, Share, InfoRecommendListExposure,
        InfoNegativeFeedback, Search, Push, PushClick, RegisterSuccess, OpenAccount, Order, CancelOrder, AdClick, schemeJump, viewEvent
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        get {
            switch self {
            // 日志信息事件
            case .viewEvent:
                return EVENT_PREFIX + "view"
            case .SystemLog:
                return EVENT_PREFIX + "log"
            // 控件点击事件
            case .ViewClick:
                return EVENT_PREFIX + "view_click"
            // 页面浏览事件
            case .ViewScreen:
                return EVENT_PREFIX + "view_screen"
            // 分享成功
            case .Share:
                return EVENT_PREFIX + "share"
            // 资讯曝光资讯列表
            case .InfoRecommendListExposure:
                return EVENT_PREFIX + "info_recommend_list_exposure"
            // 资讯负反馈标签
            case .InfoNegativeFeedback:
                return EVENT_PREFIX + "info_negative_feedback"
            // 搜索股票
            case .Search:
                return EVENT_PREFIX + "search"
            // 推送消息
            case .Push:
                return EVENT_PREFIX + "push"
            // 推送消息点击
            case .PushClick:
                return EVENT_PREFIX + "push_click"
            //注册成功
            case .RegisterSuccess:
                return EVENT_PREFIX + "register_success"
            //点击开户
            case .OpenAccount:
                return EVENT_PREFIX + "open_account"
            //下单
            case .Order:
                return EVENT_PREFIX + "order"
            //撤单
            case .CancelOrder:
                return EVENT_PREFIX + "cancel_order"
            //广告页点击事件
            case .AdClick:
                return EVENT_PREFIX + "ad_click"
            //外部跳转
            case .schemeJump:
                return EVENT_PREFIX + "scheme_jump"
            case .Unknown:
                return "unknown"
            }
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case EVENT_PREFIX + "log":
            self = .SystemLog
        case EVENT_PREFIX + "view_click":
            self = .ViewClick
        case EVENT_PREFIX + "view_screen":
            self = .ViewScreen
        case EVENT_PREFIX + "share":
            self = .Share
        case EVENT_PREFIX + "info_recommend_list_exposure":
            self = .InfoRecommendListExposure
        case EVENT_PREFIX + "info_negative_feedback":
            self = .InfoNegativeFeedback
        case EVENT_PREFIX + "search":
            self = .Search
        case EVENT_PREFIX + "push":
            self = .Push
        case EVENT_PREFIX + "push_click":
            self = .PushClick
        case EVENT_PREFIX + "register_success":
            self = .RegisterSuccess
        case EVENT_PREFIX + "open_account":
            self = .OpenAccount
        case EVENT_PREFIX + "order":
            self = .Order
        case EVENT_PREFIX + "cancel_order":
            self = .CancelOrder
        case EVENT_PREFIX + "ad_click":
            self = .AdClick
        case EVENT_PREFIX + "scheme_jump":
            self = .schemeJump
        case EVENT_PREFIX + "view":
            self = .viewEvent
        default:
            self = .Unknown
        }
    }
}

