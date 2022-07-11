//
//  YXCommentListResModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXShortVideoCommentListResModel: YXModel {
    @objc var pageCount : Int = 0
    @objc var pageNum : Int = 1
    @objc var pageSize : Int = 20
    @objc var total : Int = 0
    @objc var items : [YXShortVideoCommentItem] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["items": YXShortVideoCommentItem.self]
    }
}

class YXShortVideoCommentItem: YXModel {
    @objc var childrenNodeList : [YXShortVideoCommentItem] = []
    @objc var commentId : String?
    @objc var delFlag : Bool = false
    @objc var discuss : String?
    @objc var displayReplyUid : Bool = false
    @objc var discussDate : String?
    @objc var nick : String?
    @objc var photoUrl : String?
    @objc var replyNick : String?
    @objc var replyPhotoUrl : String?
    @objc var replyUid : String?
    @objc var systemDate : String?
    @objc var uid : String?
    @objc var like : Bool = false
    @objc var likeCount : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["childrenNodeList": YXShortVideoCommentItem.self]
    }
}

extension YXShortVideoCommentItem {
    
    private struct AssociatedKeys {
        static var isExpandKey = "isExpandKey"
        static var displayCountKey = "displayCountKey"
    }

    ///增加是否展开显示属性
    var isExpand: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isExpandKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isExpandKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///显示评论数量
    var displayReplyCount: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.displayCountKey) as? Int ?? 3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.displayCountKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //显示评论
    var displayChildrenNodeList: [YXShortVideoCommentItem] {
        if isExpand {
            return self.childrenNodeList
        } else {
            if self.childrenNodeList.count > displayReplyCount {
                return Array(self.childrenNodeList[0...displayReplyCount-1])
            } else {
                return self.childrenNodeList
            }
            
        }
    }
    
    ///是否显示展开
    var shouldDisplayMore: Bool {
        return self.childrenNodeList.count > displayReplyCount
    }
    
}
