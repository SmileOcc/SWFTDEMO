//
//  YXMarketService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/3/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import YXKit
import NSObject_Rx

protocol HasYXQuotesDataService {
    var quotesDataService: YXQuotesDataService { get }
}

class YXQuotesDataService: YXRequestable {
    typealias API = YXQuotesDataAPI

    var networking: MoyaProvider<API> {
        quotesDataProvider
    }
}
