//
//  YXKOLChatGroupResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXKOLChatGroupResModel: YXModel {
    @objc var chatGroupCover : String? //群聊封面
    @objc var chatGroupId : String? //群聊id
    @objc var chatGroupProfile : String? //群聊简介
    @objc var chatGroupTitle : String? //群聊名称
    @objc var isSpot : Bool = false //聊天室小红点标记 true-标记 false-不标记
    @objc var paidType : Int = 0 //群聊简介
    @objc var tagList : [YXKOLChatRoomTagResModel]?  //聊天室小红点标记 true-标记 false-不标记
    @objc var totalPeople : Int = 0 //是否关注
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["tagList": YXKOLChatRoomTagResModel.self]
    }
}

class YXKOLChatRoomTagResModel: YXModel {
    @objc var code : String?
    @objc var itemNameCn : String?
    @objc var itemNameHk : String?
    @objc var itemNameEn : String?
    @objc var gradientLeft : String?
    @objc var gradientRight : String?
}
