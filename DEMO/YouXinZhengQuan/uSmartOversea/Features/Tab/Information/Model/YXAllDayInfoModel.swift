//
//  YXAllDayInfoModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - YXSpecialColumnListModel
class YXAllDayInfoListModel: Codable {
    let offset: Int?
    let newsletterList: [YXAllDayInfoModel]?
    
    enum CodingKeys: String, CodingKey {
        case offset
        case newsletterList = "newsletter_list"
    }
}

// MARK: - YXAllDayInfoModel
class YXAllDayInfoModel: Codable {
    let newsid: String?
    let releaseTime: Int?
    let column: String?
    let title, content, linkURL: String?
    let source: String?
    var relatedStocks: String?
    let pctchng: String?
    let markedRed: Bool?
    
    var isShow = false
    var isRead = false
    
    enum CodingKeys: String, CodingKey {
        case newsid
        case releaseTime = "release_time"
        case column, title, content
        case linkURL = "link_url"
        case source
        case relatedStocks = "related_stocks"
        case pctchng
        case markedRed = "marked_red"
    }
    
    var stockArr = [YXAllDayInfoStockModel]()
    
    func resetStcokArr() {
//        self.relatedStocks = "sz000001|"
        self.stockArr.removeAll()
        if let stockStr = self.relatedStocks, !stockStr.isEmpty {
            let stockArr = stockStr.components(separatedBy: "|")
            if stockArr.count > 0 {
                for str in stockArr {
                    if str.count > 2 {
                        let quoteStr = str as NSString
                        let market = quoteStr.substring(to: 2)
                        let symbol = quoteStr.substring(from: 2)
                        let model = YXAllDayInfoStockModel.init()
                        model.market = market
                        model.symbol = symbol
                        self.stockArr.append(model)
                    }
                }
            }
        }
    }
}


class YXAllDayInfoStockModel: NSObject {
    
    var name: String?
    var roc: Int32?
    var symbol: String?
    var market: String?
}
