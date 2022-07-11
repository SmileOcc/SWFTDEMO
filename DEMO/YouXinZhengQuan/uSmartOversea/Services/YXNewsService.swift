//
//  YXNewsService.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

protocol HasYXNewsService {
    var newsService: YXNewsService { get }
}

class YXNewsService: YXRequestable {

    typealias API = YXNewsAPI
    
    var networking: MoyaProvider<API> {
        newsProvider
    }
}
