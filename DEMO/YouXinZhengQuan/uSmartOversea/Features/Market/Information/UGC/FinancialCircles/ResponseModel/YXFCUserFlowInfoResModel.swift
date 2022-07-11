//
//  YXFCUserFlowInfoResModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCUserFlowInfoResModel: YXModel {
    @objc var attention_count = 0
    @objc var attention_status: YXFollowStatus = .none
    @objc var auth_explain : String?
    @objc var auth_user : Bool = false
    @objc var avatar : String?
    @objc var fan_count : Int = 0
    @objc var nickName : String?
    @objc var pro : YXFCUserProType = .normal
    @objc var profile : String?
    @objc var uid : String?

    /// 视频直播状态
    @objc var liveshow_status: Int = 0 // 1:预告 2.直播中 3:暂停 4.直播结束 5.下架

    /// 聊天室直播状态
    @objc var text_live_status: Int = 0 // 1:预告 2.直播中 3:暂停 4.直播结束 5.下架
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }

    /// 是否在视频直播
    @objc var isLive: Bool {
        return liveshow_status == 2 || liveshow_status == 3
    }

    /// 是否在聊天室直播
    @objc var isTextLive: Bool {
        return text_live_status == 2 || text_live_status == 3
    }
}
