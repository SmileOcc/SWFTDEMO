//
//  YXMarketService.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXMarketService {
    var marketService: YXMarketService { get }
}


class YXMarketService: YXRequestable {
    
    typealias API = YXMarketAPI
    
    var networking: MoyaProvider<API> {
        marketProvider
    }
}
