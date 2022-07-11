//
//  YXTradeService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

protocol HasYXTradeService {
    var tradeService: YXTradeService { get }
}

class YXTradeService: YXRequestable {
    
    typealias API = YXTradeAPI
    
    var networking: MoyaProvider<API> {
        tradeProvider
    }
}
