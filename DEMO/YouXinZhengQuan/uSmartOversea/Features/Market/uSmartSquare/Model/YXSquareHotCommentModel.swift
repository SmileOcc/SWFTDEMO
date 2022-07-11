//
//  YXSquareHotCommentModel.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

class YXSquareHotCommentV2Model: YXResponseModel {
        
    @objc var query_token = ""
    @objc var total: Int = 0
    @objc var first_stock_list: [String] = []
    @objc var post_list: [YXSquareStockPostListModel] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "post_list": "data.post_list",
            "query_token": "data.query_token",
            "total":"data.total",
            "first_stock_list":"data.first_stock_list"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "post_list": YXSquareStockPostListModel.self
        ]
    }
    
}


class YXSquareHotCommentModel: YXResponseModel {
        
    @objc var post_list: [YXSquareStockPostListModel] = []
    @objc var query_token:YXSquarePostListTokenModel?
    @objc var total: Int = 0
    @objc var first_stock_list: [String] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "post_list": "data.post_list",
            "query_token": "data.query_token",
            "total":"data.total",
            "first_stock_list":"data.first_stock_list"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "post_list": YXSquareStockPostListModel.self
        ]
    }
    
}


class YXSquareStockPostListModel: YXModel {
    @objc var channel_id: Int32 = 0
    @objc var comment_count: Int32 = 0
    @objc var comment_list: [YXSquareStockPostListCommentModel] = []
    @objc var content: String = ""
    @objc var create_time:String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var likeCount: Int64 = 0
    @objc var like_flag: Bool = false
    @objc var pictures: [String] = []
    @objc var post_id: String = ""
    @objc var status: Int32 = 0
    
    @objc var follow_status:Int = 0  //integer 1 = 关注、2 = 相互关注
    
    @objc var jump_type: Int = 0 //jump_type: 1-h5、 2-native
    @objc var jump_url: String = ""

    @objc var source_type:Int = 0  // 0 个股； 1 文章 source_type=4 berich大咖类型评论
    @objc var title:String = "" //文章类型时取
    @objc var video:YXUGCFeedVedioInfoModel? //视频信息
    
    @objc var layout:YXSquareStockPostListLayout?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "comment_list": YXSquareStockPostListCommentModel.self,
            "creator_user": YXCreateUserModel.self,
            "video":YXUGCFeedVedioInfoModel.self
        ]
    }
}

class YXSquareStockPostListCommentModel: YXModel {
    @objc var comment_id: String = ""
    @objc var content: String = ""
    @objc var create_time: String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var level: Int32 = 0
    @objc var likeCount: Int64 = 0
    @objc var like_flag: Bool = false
    @objc var pictures: [String] = []
    @objc var replied_data: YXSquareStockPostListRepliedModel?
    
    //MARK:关注里用的
    @objc var post_id:String = ""
    @objc var reply_count:Int64 = 0
    @objc var reply_target_user:YXCreateUserModel?
    @objc var status:Int = 0
    @objc var layout:YXSquareCommentHeaderFooterLayout?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "replied_data": YXSquareStockPostListRepliedModel.self,
            "creator_user": YXCreateUserModel.self,
            "reply_target_user":YXCreateUserModel.self
        ]
    }
}

//回复数据模型
class YXSquareStockPostListRepliedModel: YXModel {
    @objc var content: String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var pictures: [String] = []
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["creator_user": YXCreateUserModel.self]
    }
}


//个人信息
class YXCreateUserModel: YXModel {
    @objc var auth_user: Bool = false
    @objc var avatar: String = ""
    @objc var nickName: String = ""
    @objc var pro: Int32 = 0
    @objc var uid: String = ""
    @objc var login_uid: String = ""
    @objc var auth_info: String = ""
    @objc var follow_status: Int32 = 0
}

class YXSquarePostListTokenModel: YXModel {
    @objc var offset: Int32 = 0
    @objc var page: Int32 = 0
    @objc var page_size:Int32 = 0
}


extension YXSquareStockPostListModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}



//单个的model
class YXSquareSingleCommentModel: YXResponseModel {
    
    @objc var post: YXSquareStockPostListModel?
    
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "post": "data.post",
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "post": YXSquareStockPostListModel.self,
        ]
    }

}
