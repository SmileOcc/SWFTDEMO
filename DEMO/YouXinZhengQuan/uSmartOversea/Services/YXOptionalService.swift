//
//  YXOptionalService.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

protocol HasYXOptionalService {
    var optionalService: YXOptionalService { get }
}

class YXOptionalService: YXRequestable{
    typealias API = YXOptionalAPI
    
    var networking: MoyaProvider<API> {
        optionalProvider
    }
    
}
