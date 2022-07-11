//
//  YXNoticeModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


@objc public enum YXPushType: Int {
    case none = 0
    case notify = 1
    case note = 2
    case pop = 3
    case fringe = 4
    case message = 5
    case unknown
}

extension YXPushType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXPushType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


@objcMembers public class YXNoticeModel: NSObject {
    var msgId: Int64 = 0
    var title: String = ""
    var content: String = ""
    var contentType: Int = 0
    var msgType: Int = 0
    var pushType: YXPushType = .none //信鸽(notify_1), 消息(message_5), 刘海通知(fringe_4), 小黄条(note_2), 弹窗(pop_3)
    var pushPloy: String = ""
    var createTime: Double = 0.0
    var startTime: Double = 0.0
    var endTime: Double = 0.0
    var isBmp: Bool = false
    var newFlag: Int = 0
    var isTempCode: Bool = false
    var isQuoteKicks: Bool = false //是否是行情互踢
    var attributeContent: NSAttributedString = NSAttributedString()
    
    init(msgId: Int64, title: String, content: String, pushType: YXPushType, pushPloy: String,  msgType: Int, contentType: Int, startTime: Double, endTime: Double, createTime: Double, newFlag: Int) {
        self.msgId = msgId
        self.title = title
        self.content = content
        self.pushType = pushType
        self.pushPloy = pushPloy
        self.msgType = msgType
        self.contentType = contentType
        self.startTime = startTime
        self.endTime = endTime
        self.createTime = createTime
        self.newFlag = newFlag
    }
}

struct YXNoticeStruct: Codable {
    let msgId: Int64?
    let title: String?
    let content: String?
    let contentType: Int?
    let msgType: Int?
    let pushType: YXPushType? //信鸽(notify_1), 消息(message_5), 刘海通知(fringe_4), 小黄条(note_2), 弹窗(pop_3)
    let pushPloy: String?
    let createTime: Double?
    let startTime: Double?
    let endTime: Double?
    let newFlag: Int?
}

