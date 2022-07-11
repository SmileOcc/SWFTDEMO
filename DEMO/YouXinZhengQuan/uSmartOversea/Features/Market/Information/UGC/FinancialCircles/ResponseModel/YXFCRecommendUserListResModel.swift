//
//  YXFCRecommendUserListResModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCRecommendUserListResModel: YXModel {
    
    @objc var list : [YXFCRecommendUserListItem] = []
    @objc var position : Int = 0
    @objc var query_token = ""
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXFCRecommendUserListItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXFCRecommendUserListItem: YXModel {
    
    @objc var authExplain : String?
    @objc var avatar : String?
    @objc var id : String?
    @objc var nickname : String?
    @objc var uuid : String?
    @objc var auth_user: Bool = false
    @objc var live_status: Int = 0  //0=非直播 1=直播中
    @objc var userRoleType: Int = 0
    @objc var liveshow_id: String?
    @objc var show_time: String?
    
    var followStatus: YXFollowStatus = .none
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return
            ["authExplain": ["authExplain", "auth_explain"],
             "userRoleType": ["userRoleType", "user_roleType"],
            ];
    }

    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
}
