//
//  YXADModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


struct YXADModel: Codable {
    let adList: [YXAdListModel]?
    let area: String?
    
    enum CodingKeys: String, CodingKey {
        case adList = "ad_list"
        case area = "area"
    }
}

enum AdShowPage: Int {
    case userCenter = 2
    case market = 101
    case option = 102
    case stockKing = 103
    case fund = 104
}


struct YXAdListModel: Codable {
    let adID: Int?
    let adType: Int?
    let adName: String?
    let topping: Int?
    let color: String?
    let pictureURL: String?
    let jumpURL: String?
    let jumpType: Int?
    let copywriting: String?
    let buttonwriting: String?
    let effectiveTime: String?
    let titleMain: String?
    let titleVice: String?
    let logoURLWhite: String?
    let logoURLBlack: String?
    let weight: Int?
    var showPage:Int?
    let popRecommendStockList:[RecommendStockModel]?
    
    enum CodingKeys: String, CodingKey {
        case adID = "ad_id"
        case adType = "ad_type"
        case adName = "ad_name"
        case topping = "topping"
        case color = "color"
        case pictureURL = "picture_url"
        case jumpURL = "jump_url"
        case jumpType = "jump_type"
        case copywriting = "copywriting"
        case buttonwriting = "buttonwriting"
        case effectiveTime = "effective_time"
        case titleMain = "title_main"
        case titleVice = "title_vice"
        case logoURLWhite = "logo_url_white"
        case logoURLBlack = "logo_url_black"
        case weight = "weight"
        case showPage = "show_page"
        case popRecommendStockList = "pop_recommend_stock_list"
    }
}
