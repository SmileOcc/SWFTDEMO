//
//  YXStockIntroduceService.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXIntroduceService {
    var introduceDataProvider: YXStockIntroduceService { get }
}


class YXStockIntroduceService: YXRequestable {
    
    typealias API = YXStockIntroduceAPI
    
    var networking: MoyaProvider<API> {
        introduceDataProvider
    }

}
