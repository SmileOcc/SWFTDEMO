//
//  YXTodayHotStockResModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/12/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

class YXTodayHotStockResModel: YXModel {
    @objc var hotStockListData: [YXTodayHotStockItem] = []
    @objc var updateTime: String?
    @objc var updateFormatTime: String?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["hotStockListData": YXTodayHotStockItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["hotStockListData": "hot_stock_list_data", "updateTime": "update_time", "updateFormatTime": "update_format_time"];
    }
}

class YXTodayHotStockItem: YXModel {
    @objc var postInfo : YXTodayHotStockPostInfo?
    @objc var stockInfo : YXTodayHotStockInfo?
    @objc var userInfo : YXTodayHotStockUserInfo?
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["postInfo": YXTodayHotStockPostInfo.self, "stockInfo": YXTodayHotStockInfo.self, "userInfo": YXTodayHotStockUserInfo.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["postInfo": "post_info", "stockInfo": "stock_info", "userInfo": "user_info"];
    }
}

class YXTodayHotStockInfo: YXModel {
    @objc var lastPrice : Double = 0
    @objc var market : String?
    @objc var stockName : String?
    @objc var symbolId : String?
    @objc var todayGain : Double = 0
    @objc var msStatus : NSInteger = 0
    @objc var sQuote : YXTodayHotStockSquote?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["lastPrice": "last_price", "stockName": "stock_name", "symbolId": "symbol_id", "todayGain": "today_gain", "msStatus": "ms_status", "sQuote": "s_quote"];
    }
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["sQuote": YXTodayHotStockSquote.self]
    }
}

class YXTodayHotStockPostInfo: YXModel {
    @objc var content : String?
    @objc var postId : String?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["postId": "post_id"];
    }
}

class YXTodayHotStockUserInfo : YXModel {
    @objc var headShotUrl : String?
    @objc var nick : String?
    @objc var tag : [String]?
    @objc var userId : String?
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["headShotUrl": "head_shot_url", "userId": "user_id"]
    }
}

class YXTodayHotStockSquote: YXModel {
    @objc var lastPrice : Double = 0
    @objc var pctchng : Double = 0
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["lastPrice": "last_price"];
    }
}


extension YXTodayHotStockResModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
