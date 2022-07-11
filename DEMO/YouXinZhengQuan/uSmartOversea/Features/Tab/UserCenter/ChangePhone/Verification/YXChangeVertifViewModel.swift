//
//  YXChangePhoneVertifViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum YXChangeVertifType {
    case email
    case phone
    func title() -> String {
        switch self {
        case .email:
            return YXLanguageUtility.kLang(key: "user_resetEmail_title")
        default:
            return YXLanguageUtility.kLang(key: "user_resetPhone_title")
        }
    }
}

class YXChangeVertifViewModel: HUDServicesViewModel {
    var navigator: NavigatorServicesType!
    typealias Services = HasYXUserService & HasYXLoginService
    var type : YXChangeVertifType = .phone
    var title:String = ""
    var services: Services!
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    init( _ type:YXChangeVertifType) {
        self.type = type
        self.title = type.title()
    }
}
