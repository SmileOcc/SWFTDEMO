//
//  SearchRecommendSection.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

enum SearchRecommendType {
    case stock

    var title: String {
        switch self {
        case .stock:
            return YXLanguageUtility.kLang(key: "hot_stocks")
        }
    }
}

enum SearchRecommendItem {
    case stockItem(_ model: SearchSecuModel)
}

class SearchRecommendSection: NSObject {
    let type: SearchRecommendType
    var items: [SearchRecommendItem]

    init(type: SearchRecommendType, items: [SearchRecommendItem]) {
        self.type = type
        self.items = items
        super.init()
    }
}
