//
//  YXLearningService.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXLearningService {
    var learningService: YXLearningService { get }
}

class YXLearningService: YXRequestable {
    
    typealias API = YXLearningAPI
    
    var networking: MoyaProvider<API> {
        learningProvider
    }
}
