//
//  YXHKMsgHomeResponseModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - YXHKMsgHomeResponseModel
struct  YXHKMsgHomeResponseModel: Codable {
    var system: YXNoticeStruct?
    var business: YXNoticeStruct?
    var stockNotify: YXNoticeStruct?
    var news: YXNoticeStruct?
    var activity: YXNoticeStruct?
    
    enum CodingKeys: String, CodingKey {
        case system = "system"
        case business = "business"
        case stockNotify = "stockNotify"
        case news = "news"
        case activity = "activity"
    }
}

/* v2/catalogs/unread/num  获取未读消息数  1：系统公告 2：业务提醒 3：活动通知 4：友信内审 5：智能盯盘 6：股价提醒 7：智投提醒 8：资讯推送
9：客服消息 10：登出 11：每日复盘 12:保留 13:话题 14: 直播消息 15: 行情登出*/
struct  YXMsgUnreadNumResponseModel: Codable {
    var unreadNum: [String:Int]?
    
    enum CodingKeys: String, CodingKey {
        case unreadNum = "unreadNum"
    }
}

