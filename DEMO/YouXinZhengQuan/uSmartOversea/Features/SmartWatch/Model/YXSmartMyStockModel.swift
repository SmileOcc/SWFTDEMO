//
//  YXSmartMyStockModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartMyStockModel: Codable {
    let uid: String?
    let list: YXSmartMyStockList?
}

class YXSmartMyStockList: Codable {
    var smartStare: [YXSmartMyStockSmartStare]?
    
    enum CodingKeys: String, CodingKey {
        case smartStare = "SmartStare"
    }
}

class YXSmartMyStockSmartStare: Codable {
    let seqNum: Int64
    let signalID: Int?
    let signalName, stockCode, stockName: String?
    let color: Int?
    let unixTime: Int64
    let describe: String?
    
    enum CodingKeys: String, CodingKey {
        case seqNum = "SeqNum"
        case signalID = "SignalId"
        case signalName = "SignalName"
        case stockCode = "StockCode"
        case stockName = "StockName"
        case color = "Color"
        case unixTime = "UnixTime"
        case describe = "Describe"
    }
}
