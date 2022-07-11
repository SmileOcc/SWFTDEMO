//
//  YXInfomationCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXInfomationModelListModel: Codable {
    let flag: Int?
    let newsList: [YXInfomationModel]?
    
    enum CodingKeys: String, CodingKey {
        case flag
        case newsList = "news_list"
    }
}


// MARK: - YXSpecialColumnListModel
class YXInfomationModel: Codable {
    let newsid, tag, title, source,postid: String?
    let author: String?
    let pictureURL: [String]?
    let releaseTime: Int?   //发布日期
//    let relatedStocks: [YXInfomationStockModel]?
    let linkURL: String?
    let pictureShowmode, dailyType: Int?
    let stocks: [YXInfomationStockModel]?
    var alg: String?                        //算法名称
    var isRecommend = true
    var isRead = false
    let score: Int?
    let news_tag: String?

    enum CodingKeys: String, CodingKey {
        case newsid, tag, title, source, author,postid
        case pictureURL = "picture_url"
        case releaseTime = "release_time"
//        case relatedStocks = "related_stocks"
        case linkURL = "link_url"
        case pictureShowmode = "picture_showmode"
        case dailyType = "daily_type"
        case stocks
        case alg
        case score
        case news_tag
    }
    
    var refreshFlag = false
}

// MARK: - RelatedStock
//struct YXInfomationStockModel: Codable {
//    let code, name: String?
//}

// MARK: - Stock
class YXInfomationStockModel: Codable {
    var market, symbol, name: String?
    var roc, type2: Int32? // type2 = 202,场外基金
}

//class YXKolModel: Codable {
//    var postId: String?
//    var tags : [YXNewsKOLTagResModel]?
//    var user_icon_url: String?
//}
//
//class YXNewsKOLTagResModel: Codable {
//    var id : String?
//    var name : String?
//}

@objcMembers class YXKolModel: YXModel {
    var postId: String?
    var tags : [YXNewsKOLTagResModel]?
    var user_icon_url: String?
    
    class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["tags": YXNewsKOLTagResModel.self]
    }

}

// MARK: - YXCYQColumn
@objcMembers class YXNewsKOLTagResModel: YXModel {
    var id : String?
    var name : String?
}
