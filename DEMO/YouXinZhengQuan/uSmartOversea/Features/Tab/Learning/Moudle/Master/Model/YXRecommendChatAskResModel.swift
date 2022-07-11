//
//  YXRecommendChatAskResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXRecommendChatAskResModel: YXModel {
    
    @objc var chatGroupList : [YXRecommendChatResModel] = []
    @objc var askRecommendList : [YXRecommendAskResModel] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["chatGroupList": YXRecommendChatResModel.self,"askRecommendList":YXRecommendAskResModel.self]
    }
    
}

class YXHomerecommendRes: YXModel {
    
    @objc var chatGroupList : [YXRecommendChatResModel] = []
    @objc var askRecommendList : [YXRecommendAskResModel] = []
    @objc var activityBannerList : [YXActivityBannerModel] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["chatGroupList": YXRecommendChatResModel.self,"askRecommendList":YXRecommendAskResModel.self,"activityBannerList":YXActivityBannerModel.self]
    }
    
}

class YXRecommendChatResModel: YXModel {
    @objc var chatGroupId: String? //聊天室ID
    @objc var chatGroupName: String? //聊天室名称
    @objc var chatGroupProfile: String? //聊天室简介
    @objc var chatGroupUrl: String? //聊天室封面
    @objc var isAuthorOnline: Bool = false //主播是否在线 true：是 false：否
    @objc var isSpot: Bool = false //是否有未读提示 true：是 false：否
    @objc var userStatus: Int = 0 //用户状态 0：未试用 1：试用中 2：过期用户 3：VIP 4:免费用户
    @objc var isJoined: Bool = false //是否加入过聊天室

}

class YXRecommendAskResModel: YXModel {
    @objc var questionId: String? //问题ID
    @objc var questionDetail: String? //问题
    @objc var replyDTOList: [YXAskReplyResModel]? //回答
    ///涉及股票信息
    @objc var askStockInfoDTO : YXAskStockResModel?
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["replyDTOList": YXAskReplyResModel.self]
    }
}
