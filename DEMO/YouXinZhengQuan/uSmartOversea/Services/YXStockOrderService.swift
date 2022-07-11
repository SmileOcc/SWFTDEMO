//
//  YXStockOrderService.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

protocol HasYXStockOrderService {
    var stockOrderService: YXStockOrderService { get }
}

class YXStockOrderService: YXRequestable {
    typealias API = YXStockOrderAPI
    
    var networking: MoyaProvider<API> {
        stockOrderProvider
    }
    
}
