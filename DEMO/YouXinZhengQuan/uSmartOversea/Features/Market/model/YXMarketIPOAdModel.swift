//
//  YXMarketIPOAdModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//


struct YXMarketIPOAdModel: Codable {
    let recommendList: [YXMarketIPOAdItem]?
    
    enum CodingKeys: String, CodingKey {
        case recommendList = "recommend_list"
    }
}

struct YXMarketIPOAdItem: Codable {
    let stockCode: String?
    let companyName: String?
    let pictureUrl: String?
    let secuCode: String?
    let exchangeId: Int?
    
    func symbolText() -> String {
        var market = ""
        if exchangeId == 0 {
            market = "HK"
        }else if exchangeId == 5 {
            market = "US"
        }
        
        return "\(secuCode ?? "--").\(market)"
    }
    
    enum CodingKeys: String, CodingKey {
        case stockCode = "stock_code"
        case companyName = "company_name"
        case pictureUrl = "picture_url"
        case secuCode = "secu_code"
        case exchangeId = "exchange_id"
    }
}


