//
//  YXInfoNoteHomeModel.swift
//  uSmartOversea
//
//  Created by Mac on 2020/3/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

struct YXInfoNoteHomeModel: Codable {
    let noteList: [YXInfoNoteHomeNoteListModel]?
    
    enum CodingKeys: String, CodingKey {
        case noteList = "note_list"
        
    }
}

struct YXInfoNoteHomeNoteListModel: Codable {
    let newsId: String?
    let source: String?
    let title: String?
    let stockList: [YXInfoNoteHomeStockListModel]?
    let releaseTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case newsId = "news_id"
        case source = "source"
        case title = "title"
        case stockList = "stock_list"
        case releaseTime = "release_time"
    }
}

// MARK: - NewsList
struct YXInfoNoteHomeStockListModel: Codable {
    let code, name: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}
