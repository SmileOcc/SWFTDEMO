//
//  YXMessage.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

enum YXMessageType: Int {
    case systemNoti = 1   //系统公告
    case reminder = 2     //业务提醒
    case activityNoti = 3  //活动通知
    case InternalAudit = 4 //友信内审
    case smartNoti = 5        //智能盯盘
    case stockPriceReminder = 6 //股价提醒
    
    case signOut = 10 //登出
}

class YXMessage: NSObject {
    
    class func handleMessage(_ noticeModel: YXNoticeStruct) {
        let content = UNMutableNotificationContent()
        content.title = noticeModel.title ?? ""
        content.body = noticeModel.content ?? ""
        content.userInfo = ["custom" : ["param" : noticeModel.pushPloy ?? ""]]
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
        let identifier = String(format: "%lld", noticeModel.msgId ?? 0)
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
