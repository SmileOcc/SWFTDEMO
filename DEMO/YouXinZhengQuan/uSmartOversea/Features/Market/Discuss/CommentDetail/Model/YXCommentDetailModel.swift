//
//  YXCommentDetailModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//总的模型
class YXCommentDetailModel: YXResponseModel {
    @objc var post: YXCommentDetailPostModel?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "post": "data.post",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "post": YXCommentDetailPostModel.self,
        ]
    }
}


class YXCommentDetailPostModel: YXModel {
    @objc var channel_id: Int32 = 0
    @objc var comment_count: Int64 = 0
    @objc var comment_list: [YXCommentDetailCommentModel] = []
    @objc var content: String = ""
    @objc var create_time:String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var likeCount: Int64 = 0
    @objc var like_flag: Bool = false
    @objc var pictures: [String] = []
    @objc var post_id: String = ""
    @objc var status: Int32 = 0
    
    @objc var postHeaderLayout: YXSquareCommentHeaderFooterLayout? //正文的布局
    
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "comment_list": YXCommentDetailCommentModel.self,
            "creator_user": YXCreateUserModel.self
        ]
    }
}

//评论数据model
class YXCommentDetailCommentModel: YXModel {
    @objc var comment_id: String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var content: String = ""
    @objc var create_time: String = ""
    @objc var level: Int32 = 0
    @objc var likeCount: Int64 = 0
    @objc var like_flag: Bool = false
    @objc var pictures: [String] = []
    @objc var reply_count:Int64 = 0
    
    @objc var reply_list: [YXCommentDetailListReplyModel] = []  //这里是数组
    
    @objc var commentHeaderLayout:YXSquareCommentHeaderFooterLayout? //评论为header
    @objc var isLast:Bool = false

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "reply_list": YXCommentDetailListReplyModel.self,
            "creator_user": YXCreateUserModel.self
        ]
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any]! {
        return ["creator_user":["comment_user", "creator_user"]]
    }
}

class YXCommentDetailListReplyModel: YXModel {
    @objc var content:String = ""
    @objc var create_time:String = ""
    @objc var creator_user:YXCreateUserModel?
    @objc var level:Int32 = 0
    @objc var likeCount:Int64 = 0
    @objc var like_flag:Bool = false
    @objc var pictures:[String] = []
    @objc var replied_data:YXCommentDetailReplyDataItemModel?
    @objc var reply_id:String = ""
    @objc var reply_target_user:YXCreateUserModel?
    
    @objc var replyLayout:YXSquareCommentHeaderFooterLayout?  //回复的布局
}


class YXCommentDetailReplyDataItemModel: YXModel {
    @objc var content: String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var pictures:[String] = []
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["creator_user": YXCreateUserModel.self]
    }
}

extension YXCommentDetailCommentModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}


