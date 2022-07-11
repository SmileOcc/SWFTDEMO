//
//  YXUserAttentionModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXUserAttentionModel: YXResponseModel {
    @objc var list:[YXUserAttentionItemModel] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXUserAttentionItemModel.self,
        ]
    }
}

class YXUserAttentionItemModel: YXViewModel {
    @objc var auth_info:String = ""
    @objc var auth_user:Bool = false
    @objc var avatar:String = ""
    @objc var follow_status:YXFollowStatus = .none //    integer 1 = 关注、2 = 相互关注

    @objc var nick_name:String = ""
    @objc var profile:String = ""
    @objc var uid:String = ""
    @objc var user_role_type:Int = 0
}
