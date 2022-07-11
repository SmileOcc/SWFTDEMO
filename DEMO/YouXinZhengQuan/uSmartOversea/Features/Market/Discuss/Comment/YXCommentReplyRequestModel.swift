//
//  YXCommentRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentPostRequestModel: YXHZBaseRequestModel {
    @objc var content: String = ""
    @objc var pictures: [String] = []
    @objc var stock_id_list: [String] = []
    @objc var post_id: String = ""
    @objc var post_type:Int = 0
    @objc var review_content:String = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/create-post-comment"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXReplyCommentRequestModel: YXHZBaseRequestModel {
    @objc var content: String = ""
    @objc var pictures: [String] = []
    @objc var stock_id_list: [String] = []
    @objc var reply_id: String = ""
    @objc var reply_target_uid: String = ""
    @objc var comment_id: String = ""
    @objc var post_type:Int = 0
    @objc var review_content:String = ""
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/create-comment-reply"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

@objcMembers
class YXStockDetailGuessUpOrDownInfo : NSObject {
    var downCount:NSNumber?
    var guessChange:NSNumber?
    var code: String?
    var transDate: String?
    var upCount: NSNumber?
    var market:String?
}

extension YXStockDetailGuessUpOrDownInfo: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
   
        guard let object = object as? YXStockDetailGuessUpOrDownInfo else { return false }
        return isEqual(object)
    }
}

class YXGuessUpOrDownInfoLists : YXResponseModel {
    
    @objc var list: [YXStockDetailGuessUpOrDownInfo] = []

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["list": "data.list"];
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXStockDetailGuessUpOrDownInfo.self]
    }
}
