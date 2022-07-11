//
//  YXStockDetailAnnounceModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator

class YXStockDetailAnnounceModel: Codable {
    let infoTitle, media, infoPubDate, website: String?
    enum CodingKeys: String, CodingKey {
        case infoTitle = "info_title"
        case infoPubDate = "info_pub_date"
        case website
        case media
    }
}

struct YXStockDetailAnnounceListModel: Codable {
    let list: [YXStockDetailAnnounceModel]?
}
