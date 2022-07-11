//
//  YXUGCFeedAttentionListModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCFeedAttentionPostListModel: YXResponseModel {
    @objc var feed_list:[YXUGCFeedAttentionModel] = []
    @objc var query_token:String = ""
    @objc var has_attention:Bool = false

    /// 专栏内是否有付费文章
    @objc var pay_type: Bool = false

    /// 是否已订阅专栏
    @objc var subscribed: Bool = false

    @objc var expire_time: String?

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "feed_list": "data.feed_list",
            "has_attention":"data.has_attention",
            "query_token":"data.query_token",
            "pay_type":"data.pay_type",
            "subscribed":"data.subscribed",
            "expire_time":"data.expire_time"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "feed_list": YXUGCFeedAttentionModel.self
           
        ]
    }

}

class YXUGCFeedAttentionModel: YXModel {
    @objc var cid:String = "" // 内容id

    @objc var content:String = "" // 内容
    
    @objc var content_type:YXInformationFlowType =  .stockdiscuss// 内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论

    @objc var cover_images:[YXUGCFeedCoverImagesModel] = [] 
    @objc var creator_info:YXCreateUserModel?
    @objc var feed_tag:String = "" //信息流标签(要闻资讯需要展示)

    @objc var is_original:Bool = false //    integer是否原创

    @objc var like_info:YXUGCFeedLikeInfoModel?
    @objc var show_time:String = ""  //展示时间

    @objc var stock_info:YXUGCFeedStockInfoModel?
    @objc var subject_info:YXUGCFeedSubjectInfoModel?
    @objc var text_live_info: YXFCHotFeedListTextliveInfo?
    @objc var title:String = ""  //标题

    @objc var video:YXUGCFeedVedioInfoModel?
    
    @objc var link_type : Int = 0 // 1 h5 2 app
    @objc var link_url : String?
    @objc var total_comment : Int = 0
    
    @objc var layout:YXSquareCommentHeaderFooterLayout?

    /// 是否是付费文章
    @objc var pay_type: Bool = false
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "cover_images": YXUGCFeedCoverImagesModel.self,
            "creator_info": YXCreateUserModel.self,
            "like_info": YXUGCFeedLikeInfoModel.self,
            "stock_info":YXUGCFeedStockInfoModel.self,
            "subject_info":YXUGCFeedSubjectInfoModel.self,
            "video":YXUGCFeedVedioInfoModel.self,
            "text_live_info": YXFCHotFeedListTextliveInfo.self
        ]
    }
}

class YXUGCFeedCoverImagesModel: YXModel {
    @objc var cover_height:String = "" // 封面图长

    @objc var cover_images:String = ""  //封面图url

    @objc var cover_width:String = "" //封面图宽
}

class YXUGCFeedLikeInfoModel: YXModel {
    @objc var like_count:Int64 = 0 //    integer点赞数

    @objc var like_flag:Bool = false // 点赞标识
}

class YXUGCFeedStockInfoModel: YXModel {
    @objc var market:String = "" //    string市场

    @objc var name:String = "" //    string股票名称

    @objc var pctchng:Double = 0.0 //    integer涨跌幅

    @objc var symbol:String = ""  //股票代码
}

class YXUGCFeedSubjectInfoModel: YXModel {
    @objc var details_url:String = "" //    string专题url

    @objc var subject_id:String = "" //    string专题id

    @objc var subject_summary:String = "" //    string专题简介

    @objc var subject_title:String = "" //    string专题title
}

class YXUGCFeedVedioInfoModel: YXModel {
    @objc var duration:String = "" //    integer 时长
    @objc var cover_image:String = ""
    @objc var url:String = "" //    string视频url
}

