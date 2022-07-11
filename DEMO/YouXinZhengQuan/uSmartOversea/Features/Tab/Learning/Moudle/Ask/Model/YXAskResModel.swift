//
//  YXAskResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXAskResModel: YXModel {
    @objc var items : [YXAskItemResModel] = []
    @objc var pageCount : Int = 0
    @objc var pageNum : Int = 0
    @objc var pageSize : Int = 0
    @objc var total : Int = 0
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["items": YXAskItemResModel.self]
    }
}

class YXAskItemResModel: YXModel {
    
    /// 提问人头像
    @objc var askImg : String?
    /// 提问人昵称
    @objc var askName : String?
    /// 提问人ID
    @objc var askUid : String?
    /// 删除标记 true-可删，false-不允许删除
    @objc var deleteFlag : Bool = false
    ///问题内容
    @objc var questionDetail : String?
    /// 问题id
    @objc var questionId : String?
    /// 提问时间
    @objc var questionTime : String?
    ///总回复数量
    @objc var replyAllNum : Int = 0
    ///回复集合
    @objc var replyDTOList : [YXAskReplyResModel]?
    /// 回答标记 true-可回答，false-不允许回答 详情接口需要
    @objc var replyFlag : Bool = false
    ///回复类型(1-所有人，2-KOL，3-单个KOL) Waiting列表使用
    @objc var replyType : Int = 0
    ///KOL回复数量
    @objc var replyKolNum : Int = 0
    ///涉及股票信息
    @objc var stockInfoDTOList : [YXAskStockResModel]?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["replyDTOList": YXAskReplyResModel.self,
         "stockInfoDTOList":YXAskStockResModel.self]
    }
    
}

class YXAskReplyResModel: YXModel {
    
    @objc var replyId : String?
    
    //删除标记 true-可删，false-不允许删除
    @objc var deleteFlag : Bool = false
    
    //是否关注，详情页需要根据该字段展示，其他可忽略
    @objc var followFlag : Bool = false
    //是否点赞
    @objc var likeFlag : Bool = false
    
    //KOL认证标签
    @objc var kolTag : [String]?

    ///点赞数量
    @objc var likeNum : Int = 0

    /// 回复内容
    @objc var replyDetail : String?

    /// 回复人头像
    @objc var replyImg : String?
    
    /// 回复人昵称
    @objc var replyName : String?
    
    /// 回复角色(1-普通用户，2-KOL)
    @objc var replyRole : Int = 1
    
    /// 回复时间
    @objc var replyTime : String?
    
    /// 回复人ID
    @objc var replyUid : String?
    @objc var tags : [NSNumber]?

}

class YXAskStockResModel: YXModel {
    
    ///股票代码
    @objc var stockCode : String?

    ///股票名称
    @objc var stockName : String?
    @objc var market : String? { //后端不愿意增加这个字段，需要前端从stockname去拆分出来(stockname是market_code的拼接)
        get {
            if let market_code = stockCode {
                let splitedArray = market_code.components(separatedBy: "_")
                if splitedArray.count > 1 {
                    return splitedArray[0]
                }
            }
            return nil
        }
    }
    @objc var symbol : String? {
        get {
            if let market_code = stockCode {
                let splitedArray = market_code.components(separatedBy: "_")
                if splitedArray.count > 1 {
                    return splitedArray[1]
                }
            }
            return nil
        }
    }

    @objc var count : Int = 0
}
