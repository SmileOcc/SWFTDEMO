//
//  YXYGCCommentAPI.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//MARK:广场页股票精选讨论
class YXQueryFeaturedPostModel: YXHZBaseRequestModel {
    
    @objc var page: Int = 0
    @objc var limit: Int = 20
    @objc var query_token = ""
    @objc var local = false    //false 全部 true 新加坡
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-selected-post"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXSquareHotCommentV2Model.self
    }
}

//获取股票讨论列表
class YXQueryStockCommentListModel: YXHZBaseRequestModel {
    @objc var post_id:String?
    @objc var query_token:[String:Any] = [:]
    @objc var stock_id: String?
    @objc var local = false    //false 全部 true 新加坡

    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-post-list"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXSquareHotCommentModel.self
    }

}

//点（取消）赞
class YXQueryLikeOperationModel: YXHZBaseRequestModel {

    @objc var item_type: Int = 0  //1：post、2：comment、3：reply
    @objc var like_item_id: String = ""
    @objc var operation: Int = 0  //1：点赞、-1：取消点赞
     
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/like-operation"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}

//删除（恢复）讨论
class YXQueryUpdatePostStatus: YXHZBaseRequestModel {

//    @objc var ignore_push:Bool = false
//    @objc var ignore_white_list = false
    @objc var post_id:String = ""
    @objc var status:Int = 4 // 3：删除、4：举报
   
     
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/update-post-status"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}


//获取单条股票讨论
class YXQuerySinglePostData: YXHZBaseRequestModel {

    @objc var post_id:String = ""
    @objc var source_type:String = ""
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-post-list-data"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXSquareSingleCommentModel.self
    }
    
}



//MARK: 个股讨论详情API
//获取讨论详情
class YXQueryPostDetailData: YXHZBaseRequestModel {

    @objc var post_id:String = ""
    @objc var limit:Int = 5
    @objc var offset:Int = 0

    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/query-post-detail"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXCommentDetailModel.self
    }
    
}

//对回复的删除与举报
class YXCommentDetailReplyDeleteOrReporeReq: YXHZBaseRequestModel {

    //    @objc var ignore_push:Bool = false
    //    @objc var ignore_white_list = false
    @objc var reply_id:String = ""
    @objc var status:Int = 4 // 3：删除、4：举报

    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/update-post-reply-status"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}

//获取评论下回复列表
class YXQueryReplyListReq: YXHZBaseRequestModel {

    @objc var comment_id:String = ""
    @objc var limit:Int = 5
    @objc var offset:Int = 0

    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/v1/query-reply-list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXCommentDetailReplyListModel.self
    }
    
}


