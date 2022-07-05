//
//  HCUserService.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

protocol HasHCUserService {
    var userService: HCUserService { get }
}

class HCUserService: HCRequestable {

    typealias API = HCUserAPI
    
    var networking: MoyaProvider<API> {
        userProvider
    }
    
}
