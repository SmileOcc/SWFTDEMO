//
//  HCLoginService.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

protocol HasHCLoginService {
    var loginService: HCLoginService { get }
}

class HCLoginService: HCRequestable {    
    typealias API = HCLoginAPI
    
    var networking: MoyaProvider<API> {
        loginProvider
    }

}
