//
//  YXNewStockService.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXNewStockService {
    var newStockService: YXNewStockService { get }
}

class YXNewStockService: YXRequestable {
    
    typealias API = YXNewStockAPI
    
    var networking: MoyaProvider<API> {
        NewStockDataProvider
    }
}
