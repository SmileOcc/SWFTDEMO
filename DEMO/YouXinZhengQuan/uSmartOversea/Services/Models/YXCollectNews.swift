//
//  YXCollectNews.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXCollectNews: Codable {
    var collectionList: [CollectionList]
    
    enum CodingKeys: String, CodingKey {
        case collectionList = "collection_list"
    }
}

struct CollectionList: Codable, Equatable {
    let jumpType: Int
    let newsid: String
    let pictureURL: [String]?
    let releaseTime: Int
    let showApp, showArea: String?
    let source, title: String
    var isSelected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case jumpType = "jump_type"
        case newsid
        case pictureURL = "picture_url"
        case releaseTime = "release_time"
        case showApp = "show_app"
        case showArea = "show_area"
        case source, title
    }
    
    static func == (lhs: CollectionList, rhs: CollectionList) -> Bool {
        lhs.jumpType == rhs.jumpType
            && lhs.newsid == rhs.newsid
            && lhs.releaseTime == rhs.releaseTime
            && lhs.source == rhs.source
            && lhs.title == rhs.title
            && lhs.isSelected == rhs.isSelected
            && lhs.showApp == rhs.showApp
            && lhs.showArea == rhs.showArea
            && lhs.pictureURL == rhs.pictureURL
    }
}

