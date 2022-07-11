//
//  YXCommentResponseModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/9/11.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailResponseModel: YXResponseModel {
    @objc var user_info: CommentUserInfo?
    @objc var post_info: CommentPostInfo?
    @objc var comment_count: NSNumber?
    @objc var comment_detail_info: [CommentInfo]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["user_info": CommentUserInfo.self,
         "post_info": CommentPostInfo.self,
         "comment_detail_info": CommentInfo.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["user_info": "data.user_info",
         "post_info": "data.post_info",
         "comment_count": "data.comment_count",
         "comment_detail_info": "data.comment_detail_info"]
    }
}

class CommentInfo: NSObject {
    @objc var ID: String?
    @objc var comment_id: String?
    @objc var comment_user: CommentUserInfo?
    @objc var content: String?
    @objc var time_stamp: NSNumber?
    @objc var ext_type: Int = 0

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["comment_user": CommentUserInfo.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["ID": "comment_info.id",
         "comment_id": "comment_info.comment_id",
         "comment_user": "comment_info.comment_user",
         "content": "comment_info.content",
         "time_stamp": "comment_info.time_stamp",
         "ext_type": "comment_info.ext_type"]

    }
}

class CommentUserInfo: YXModel {
    @objc var head_shot_url: String?
    @objc var nick: String?
    @objc var user_id: String?
}


class CommentPostInfo: YXModel {
    @objc var post_id: String?
    @objc var content: String?
    @objc var time_stamp: NSNumber?
}

class YXNewCommentDetailResponseModel: YXResponseModel {
    @objc var live_status: Int = 0
    @objc var token: String?
    @objc var list: [NewCommentInfo]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": NewCommentInfo.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["live_status": "data.live_status",
         "token": "data.token",
         "list": "data.list"]
    }
}

@objc enum LiveCommentType: Int {
    case normal = 0
    case join = 1
    case follow = 2
    case share = 3
}

@objcMembers class NewCommentInfo: NSObject {
    var ID: String?
    var comment_id: String?
    var creator_user: YXCreateUserModel?
    var comment_type: Int = 0
    var content: String?
    var create_time: String?
    var time_stamp: NSNumber?
    var ext_type: Int = 0
    var user_role: Int = 0
    
    var commentType: LiveCommentType? {
        get {
            LiveCommentType(rawValue: comment_type)
        }
    }
    
    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["comment_user": YXCreateUserModel.self]
    }
    
    class func modelCustomPropertyMapper() -> [String : Any] {
        ["ID": "id"]
    }
}
