//
//  YXUserCenterViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

enum userCenterRow {
    case quotation
    case message
    case rewards
    case setting
    case help
    case about
    case activity
    case invite
    case subscribes
    
    func title() -> String {
        switch self {
        case .quotation:
            return YXLanguageUtility.kLang(key: "mine_quotation")
        case .message:
            return YXLanguageUtility.kLang(key: "mine_message")
        case .rewards:
            return YXLanguageUtility.kLang(key: "mine_rewards")
        case .setting:
            return YXLanguageUtility.kLang(key: "mine_setting")
        case .help:
            return YXLanguageUtility.kLang(key: "user_help")
        case .about:
            return YXLanguageUtility.kLang(key: "mine_about")
        case .activity:
            return YXLanguageUtility.kLang(key: "mine_activity")
        case .invite:
            return YXLanguageUtility.kLang(key: "mine_invite")
        case .subscribes:
            return YXLanguageUtility.kLang(key: "mine_subscribe")
        }
    }
    
    func imageName() -> String {
        switch self {
        case .quotation:
            return "mine_quotation"
        case .message:
            return "mine_message"
        case .rewards:
            return "mine_rewards"
        case .setting:
            return "mine_setting"
        case .help:
            return "mine_help"
        case .about:
            return "mine_about"
        case .activity:
            return "mine_activity"
        case .invite:
            return "mine_invite"
        case .subscribes:
            return "mine_subscribe"
        }
    }
    
    func lineHidden() -> Bool {
        switch self {
        case .quotation,
             .setting,
             .help,
             .activity,
             .invite,
             .subscribes,
             .about:
            return true
        case .rewards,
             .message:
            return false
        }
    }
}


class YXUserCenterViewModel: ServicesViewModel, HUDServicesViewModel  {
    static let userCenterAd = "userCenterAd"

    var hudSubject: PublishSubject<HUDType>! =  PublishSubject<HUDType>()
    
    typealias Services = HasYXUserService & HasYXGlobalConfigService
    
    var navigator: NavigatorServicesType!
    
    var actCenterResponse: YXResultResponse<YXADModel>?
    let actCenterListRelay = BehaviorRelay<[YXAdListModel]>(value: [])
    var actList = [YXAdListModel]()
    
    var wordResponse: YXResultResponse<YXQueryCopywritingList>?
    let wordListRelay = BehaviorRelay<[YXQueryCopywritListModel]>(value: [])
    var wordList = [YXQueryCopywritListModel]()
    
    var configTool = YXMineConfigTool.init()
    var rows : [userCenterRow] = [.quotation, .subscribes, .message, .invite,. activity, .rewards, .setting,.help, .about]
    var hasCheckMessage = false
    
    var accountTypeSubject = BehaviorRelay<YXAccountLevelType>(value: .unkonw)
    
    
    var services: Services! {
        didSet {
            actCenterResponse = { [weak self] (response) in
                guard let `self` = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let adList = result.data?.adList, adList.count > 0 {
                            self.actList = adList
                            self.actCenterListRelay.accept(adList)
                        } else {
                            self.actList = []
                            self.actCenterListRelay.accept([])
                        }
                    default:
                        break
                    }
                case .failed(_):
                    break
                }
            }
            
            
            wordResponse = { [weak self] (response) in
                guard let `self` = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let dataList = result.data?.dataList, dataList.count > 0 {
                            self.wordList = dataList
                            self.wordListRelay.accept(dataList)
                        } else {
                            self.wordList = []
                            self.wordListRelay.accept([])
                        }
                    default:
                        break
                    }
                case .failed(_):
                    break
                }
            }
        }
    }
    
    func closeOtherAd() {
        MMKV.default().set(Double(NSDate.beginOfToday().timeIntervalSince1970), forKey: YXUserCenterViewModel.userCenterAd)
    }
    
    func getAccountType() {
        if YXUserManager.canTrade() {
            let requestMode = YXAccountLevelTypeRequestModel()
            let request = YXRequest.init(request: requestMode)
            request.startWithBlock {[weak self] res in
                if res.code == .success{
                    if let type = res.data?["accountType"] as? Int,let ty = YXAccountLevelType.init(rawValue: type) {
                        self?.accountTypeSubject.accept(ty)
                    }else {
                        self?.accountTypeSubject.accept(.unkonw)
                    }
                }
            } failure: {[weak self] request in
                self?.accountTypeSubject.accept(.unkonw)
            }

        }else {
            self.accountTypeSubject.accept(.unkonw)
        }
    }
}
