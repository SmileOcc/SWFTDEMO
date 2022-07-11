//
//  YXInformationService.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXInformationService {
    var infomationService: YXInformationService { get }
}



class YXInformationService: YXRequestable {
    
    typealias API = YXInformationApi
    
    var networking: MoyaProvider<API> {
        infoDataProvider
    }
    
}
