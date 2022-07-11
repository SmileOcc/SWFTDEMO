//
//  YXStockSTReturnRateModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit

@objcMembers class YXStockSTReturnRateModel: NSObject, Codable {

    let start, end: Int64?
    let list: YXStockSTReturnRateListModel?
    enum CodingKeys: String, CodingKey {
        case start, end
        case list
    }

}

@objcMembers class YXStockSTReturnRateListModel: NSObject, Codable {

    let strategy: YXStockSTReturnRateListStrategyModel?
    let indexList: [YXStockSTReturnRateListIndexModel]?

    enum CodingKeys: String, CodingKey {
        case strategy
        case indexList = "index_list"
    }

}

@objcMembers class YXStockSTReturnRateListStrategyModel: NSObject, Codable {

    let index: [Int]?
    let returnRate: Int?

    enum CodingKeys: String, CodingKey {
        case index
        case returnRate = "return_rate"
    }
}

@objcMembers class YXStockSTReturnRateListIndexModel: NSObject, Codable {

    let name: String?
    let index: [Int]?
    let returnRate: Int?

    enum CodingKeys: String, CodingKey {
        case index
        case name 
        case returnRate = "return_rate"
    }

}


@objcMembers class YXStockSTColumnList: NSObject, Codable {

    let list: [YXStockSTColumnListInfo]?
}

@objcMembers class YXStockSTColumnListInfo: NSObject, Codable {

    var name: String?
    var logourl: String?
    var jumpurl: String?
    var isLocal: NumberBool?
    var imageName: String?
    var isNative: NumberBool?
    var trackPropName: String?

    init(name: String? = nil, logourl: String? = nil, jumpurl: String? = nil, isLocal: NumberBool? = nil, imageName: String? = nil, isNative: NumberBool? = nil, trackPropName: String? = "") {
        self.name = name
        self.logourl = logourl
        self.jumpurl = jumpurl
        self.isLocal = isLocal
        self.imageName = imageName
        self.isNative = isNative
        self.trackPropName = trackPropName
    }
}
