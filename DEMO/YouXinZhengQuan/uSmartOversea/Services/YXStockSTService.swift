//
//  YXStockSTService.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

protocol HasYXStockSTService {
    var stockSTService: YXStockSTService { get }
}

class YXStockSTService: YXRequestable {
    typealias API = YXStockSTAPI
    
    var networking: MoyaProvider<API> {
        StockSTProvider
    }
}

