//
//  YXUGCCommentApi.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//用户信息流
class YXQueryPersonFeedListReq: YXHZBaseRequestModel {

    @objc var page_size: Int = 20
    @objc var query_token: String = ""
    @objc var person_uid: String = ""
    @objc var tab_type: NSInteger = 1 // 1：动态 2：专栏 3：视频 4：聊天室

    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v2/query-person-feed-list"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXUGCFeedAttentionPostListModel.self
    }
}

//关注 信息流
class YXQueryAttentionFeedListReq: YXHZBaseRequestModel {
    
    @objc var page_size: Int = 20
    @objc var query_token:String = ""
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/query-attention-feed-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUGCFeedAttentionPostListModel.self
    }
}

//获取推荐关注用户列表
class YXQueryRecommendUserListReq: YXHZBaseRequestModel {
    
    @objc var limit: Int = 4
    @objc var query_token:String = ""
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/get-recommend-user-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUGCRecommandUserListModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
//获取推荐关注用户列表
class YXQueryRecommendUserListReqHK: YXHZBaseRequestModel {
    
    @objc var limit: Int = 4
    @objc var query_token:String = ""
    
    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v2/get-recommend-user-list-hk"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUGCRecommandUserListModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


//获取评论列表(关注界面中用)
class YXQueryCommentListReq: YXHZBaseRequestModel {
    
    @objc var post_ids:String = ""  //拼接的json字符串
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/v1/query-comment-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXUGCAttentionCommentListModel.self
    }
}

//获取单个post下的评论
class YXQuerySingleCommentListDataReq: YXHZBaseRequestModel {
    
    @objc var post_id:String = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-comment-list-data"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return  YXUGCSingleCommentListCommentModel.self
    }
}

//获取文章、资讯下的获取评论详情
class YXQueryNewsAndLiveCommentListDataReq: YXHZBaseRequestModel {
    
    @objc var post_id:String = ""
    @objc var limit:Int = 10
    @objc var offset:Int = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-comment-detail"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return  YXNewsOrLiveCommentListModel.self
    }
}

//获取单条评论数据
class YXQuerySingleCommentDataReq: YXHZBaseRequestModel {
    
    @objc var comment_id:String = ""
    @objc var limit:Int = 10
    @objc var offset:Int = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-comment-data"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return  YXSingleCommentModel.self
    }
}

//删除（举报）评论v3
class YXQueryDeleteOrReportCommentReq: YXHZBaseRequestModel {
    
    @objc var comment_id:String = ""
    @objc var post_type:Int = 0 //评论类型：2：直播、3：回放、5：个股讨论 6：文章讨论、7：资讯讨论
    @objc var status:Int = 0 //2=恢复、3=删除、4=举报
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/update-post-comment-status"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return  YXResponseModel.self
    }
    
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

//删除（举报）回复v3
class YXQueryDeleteOrReportReplyReq: YXHZBaseRequestModel {
    
    @objc var reply_id:String = ""
    @objc var post_type:Int = 0 //评论类型：2：直播、3：回放、5：个股讨论 6：文章讨论、7：资讯讨论
    @objc var status:Int = 0 //2=恢复、3=删除、4=举报
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/update-post-reply-status"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return  YXResponseModel.self
    }
    
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


//MARK:点赞相关
//（取消）点赞 通用的
/*
 common    liked_server_pb.ThumbUpData{
 bizId    string
 @inject_tag: form:"bizId" comment:"点赞的业务数据id，如果是雪花算法id，那么业务前缀推荐使用统一的：like"
 bizPreFix    string
 @inject_tag: form:"bizPreFix" comment:"业务前缀"  (原点赞接口现在兼容个股了，但是点赞的时候个股正文、评论、回复数据的时候，bizPrefix得用：postLikeUids、commentLikeUids、replyLikeUids)
 }
 content    string
 direction    integer
 @inject_tag: form:"direction" comment:"操作方向 1-点赞 0-取消"
 needPush    boolean
 post_id    string
 example: 0
 @inject_tag: json:"post_id,string" form:"post_id" comment:"帖子id 推送跳转用 非必填"
 post_type    integer
 @inject_tag: json:"post_type" form:"post_type" comment:"点赞业务数据类型：1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论""
 target_uid    string
 @inject_tag: form:"target_uid" comment:"被点赞用户uid"
 user_id    integer
 @inject_tag: form:"user_id"
 */
class YXQueryLikeThumbUpOPReq: YXHZBaseRequestModel {
    @objc var common:[String:String] = [:]  //["bizId": "string", "bizPreFix": "string"
    /*（正文 = "postLikeUids"
    comment = "commentLikeUids"
    reply = "replyLikeUids"）  ]
     
     biz_id、和bizPrefix、contentType这三个参数我能查到具体的正文（文章、直播）数据
     */
      
    @objc var direction:Int = 0
    @objc var needPush:Bool = true

    @objc var content_type:Int = 0

    
    override func yx_requestUrl() -> String {
        return "/like-server/api/v1/thumb-up-op"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.PUT
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

//是否关注某个用户接口
class YXQueryHadAttentionedUserReq: YXHZBaseRequestModel {
    
    @objc var target_uid:String = "" //关注目标 这里是字符串
    
    override func yx_requestUrl() -> String {
        return "/zt-friend-server/api/v1/friend-server/has-concern"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}

