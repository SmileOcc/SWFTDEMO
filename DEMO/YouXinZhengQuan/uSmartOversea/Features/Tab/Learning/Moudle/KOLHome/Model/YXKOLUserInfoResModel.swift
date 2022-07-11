//
//  YXKOLUserInfoResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXKOLUserInfoResModel: YXModel {
    @objc var personalProfile : String? //个人简介 最大长度108字符
    @objc var paidType : Int = 0 //付费类型0免费 1付费
    @objc var isGlobalPaid : Int = 0 //是否支持付费0免费 1付费
    @objc var avatar : String? //头像
    @objc var nickname : String? //昵称
    @objc var chatRoomFlag : Bool = false //聊天室小红点标记 true-标记 false-不标记
    @objc var followFlag : Bool = false //是否关注
    @objc var hasPurchased : Bool = false //是否购买
    @objc var kolTag : [String]? //KOL认证标签
    @objc var uid : String?
    @objc var viewsSortSg : [String]? //主页视SG视图排序 1Views 2Answes 3Chats

}
