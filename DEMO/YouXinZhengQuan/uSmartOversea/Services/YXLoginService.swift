//
//  YXLoginService.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

protocol HasYXLoginService {
    var loginService: YXLoginService { get }
}

class YXLoginService: YXRequestable {
    typealias API = YXLoginAPI
    
    var networking: MoyaProvider<API> {
        loginProvider
    }
}
