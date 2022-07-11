//
//  YXStockDetailHSAnnounceModel.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/9/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator

class YXStockDetailHSAnnounceModel: Codable {
    let annDt, titleTxt, columnCode, digestTxt, annLink, annLinkYx, collectDt: String?
    let annId: Double?
    enum CodingKeys: String, CodingKey {
        case annDt = "ann_dt"
        case titleTxt = "title_txt"
        case columnCode = "column_code"
        case digestTxt = "digest_txt"
        case annLink = "ann_link"
        case annLinkYx = "ann_link_yx"
        case collectDt = "collect_dt"
        case annId = "ann_id"
    }
}

struct YXStockDetailHSAnnounceListModel: Codable {
    let list: [YXStockDetailHSAnnounceModel]?
}


//Bond
struct YXStockDetailBondModel: Codable {
    let bondInfo: YXStockDetailBondInfo?
}

struct YXStockDetailBondInfo: Codable {
    let bondId: Int?
    let bondName: String?
    //let bondCode: String?
    let bondStockCode: String?
    //let minFaceValue: Int?
    //let currency: YXStockDetailBondCurrency?
    //let bondMarket: YXStockDetailBondMarket?
}

struct YXStockDetailBondCurrency: Codable {
    let type: Int?
    let name: String?
    let symbol: String?
    let shortSymbol: String?
}

struct YXStockDetailBondMarket: Codable {
    let type: Int?
    let name: String?
    let displayName: String?
}
