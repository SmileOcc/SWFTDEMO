//
//  YXNewStockDeliveredListModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Differentiator

struct YXNewStockDeliveredListModel: Codable {
    
    let list: [YXNewStockDeliveredInfo]?
    let pageNum: Int?
    let pageSize: Int?
    let total: Int?

}

struct YXNewStockDeliveredInfo: Codable {
    
    let applyCompnay: String?
    let applyDate: String?
    let board: Int?
    let boardName: String?
    let booked: Bool?
    let status: Int?
    let statusName: String?
    let subscribeFlag: Int?
    let subscribeId: String?
    let subscribeStatus: Int?

}

extension YXNewStockDeliveredInfo: IdentifiableType {
    typealias Identity = String

    var identity: String {
        subscribeId ?? ""
    }
}

