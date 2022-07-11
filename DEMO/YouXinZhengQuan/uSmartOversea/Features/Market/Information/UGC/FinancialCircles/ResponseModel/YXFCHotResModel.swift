//
//  YXFCHotResModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFCHotResModel: YXModel {
    
    @objc var feed_list : [YXFCHotFeedListItem] = []
    @objc var query_token : String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["feed_list": YXFCHotFeedListItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListItem: YXModel {

    @objc var cid : String?
    @objc var content_type : YXInformationFlowType = .news
    @objc var cover_images : YXFCHotFeedListCoverImage?
    @objc var creator_info : YXFCHotFeedListCreatorInfo?
    @objc var like_info : YXFCHotFeedListLikeInfo?
    @objc var text_live_info: YXFCHotFeedListTextliveInfo?
    @objc var show_time : String?
    @objc var title : String?
    @objc var video : YXFCHotFeedListVideo?
    @objc var link_type : Int = 0 // 1 h5 2 app
    @objc var link_url : String?
    var itemSizeInfo: (imageHeight: CGFloat, cellHeight: CGFloat, cellWidth: CGFloat) = (0.0, 0.0, 0.0)
    var stockDiscussLayout: YYTextLayout?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListVideo: YXModel {

    @objc var duration : Int = 0
    @objc var url : String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListLikeInfo: YXModel {
    @objc var like_count : Int64 = 0
    @objc var like_flag : Bool = false
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListCreatorInfo: YXModel {
    @objc var auth_user : Bool = false
    @objc var avatar : String?
    @objc var nickName : String?
    @objc var pro : Int = 0
    @objc var uid : String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListCoverImage: YXModel {
    @objc var cover_height : String?
    @objc var cover_images : String?
    @objc var cover_width : String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXFCHotFeedListTextliveInfo: YXModel {
    @objc var hot_degree = 0
    @objc var broadcast_id: String?
    @objc var messages: String?
    @objc var status: YXChatRoomStatus = .unlive
}
