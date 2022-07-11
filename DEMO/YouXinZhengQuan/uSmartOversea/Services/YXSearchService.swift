//
//  YXSearchService.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXSearchService {
    var searchService: YXSearchService { get }
}



class YXSearchService: YXRequestable {
    
    typealias API = YXSearchAPI
    
    var networking: MoyaProvider<API> {
        searchProvider
    }
    
}
