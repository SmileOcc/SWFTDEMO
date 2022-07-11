//
//  YXMineService.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

protocol HasYXUserService {
    var userService: YXUserService { get }
}

class YXUserService: YXRequestable {

    typealias API = YXUserAPI
    
    var networking: MoyaProvider<API> {
        userProvider
    }
    
    
    
//    /*获取用户banner*/
//    var userBannerResponse: ((YXResult<JSONAny>?, Error?) -> Void)? = nil
//    func userBanner() -> Single<YXResult<JSONAny>> {
//        return networking.rx.request(MultiTarget(YXUserAPI.userBanner)).map(YXResult<JSONAny>.self)
//    }
//    
//    var changePwdResponse: ((YXResult<JSONAny>?, Error?) -> Void)? = nil
//    func changePwd(oldPassword: String, password: String) -> Single<YXResult<JSONAny>> {
//        return networking.rx.request(MultiTarget(YXUserAPI.changePwd(oldPassword, password: password))).map(YXResult<JSONAny>.self)
//    }
}
