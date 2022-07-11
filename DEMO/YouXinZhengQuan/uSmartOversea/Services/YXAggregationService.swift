//
//  YXLoginService.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

protocol HasYXAggregationService {
    var aggregationService: YXAggregationService { get }
}

class YXAggregationService: YXRequestable {
    typealias API = YXAggregationAPI
    
    var networking: MoyaProvider<API> {
        aggregationProvider
    }

}
