//
//  YXStockAnalyzeService.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXStockAnalyzeService {
    var stockAnalyzeService: YXStockAnalyzeService { get }
}


class YXStockAnalyzeService: YXRequestable {
    
    typealias API = YXStockAnalyzeAPI
    
    var networking: MoyaProvider<API> {
        stockAnalyzeDataProvider
    }

}
