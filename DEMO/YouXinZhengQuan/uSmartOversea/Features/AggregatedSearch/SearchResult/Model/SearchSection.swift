//
//  SearchSection.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

enum SearchSectionItem {
    case secuItem(model: SearchSecuModel)
    case strategyItem(model: SearchStrategyModel)
    case beeRichMasterItem(model: SearchBeeRichMasterModel)
    case newsItem(model: SearchNewsModel)
    case postItem(model: SearchPostModel)
    case beeRichCourseItem(model: SearchBeeRichCourseModel)
    case helpItem(model: SearchHelpModel)
}

class SearchSection: NSObject {
    let searchType: SearchType
    var items: [SearchSectionItem]

    init(searchType: SearchType, items: [SearchSectionItem]) {
        self.searchType = searchType
        self.items = items
        super.init()
    }
}
