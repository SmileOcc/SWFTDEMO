//
//  YXBondHistoryOrderListResponseModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

class YXBondHistoryOrderListResponseModel: Codable {
    var list : [YXBondOrderModel]? = []
    var pageNum : Int? = 0
    var pageSize : Int? = 0
    var total : Int? = 0
}
