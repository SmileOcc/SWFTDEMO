//
//  YXSmartService.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXSmartService {
    var smartService: YXSmartService { get }
}

class YXSmartService: YXRequestable {
    
    typealias API = YXSmartAPI

    var networking: MoyaProvider<API> {
        SmartDataProvider
    }
    
    //http://szshowdoc.youxin.com/web/#/23?page_id=238 接口地址
    
}
