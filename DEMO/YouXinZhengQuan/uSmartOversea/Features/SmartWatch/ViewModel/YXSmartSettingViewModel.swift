//
//  YXSmartSettingViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import URLNavigator

class YXSmartSettingViewModel: HUDServicesViewModel  {
    
    typealias Services = YXSmartService
    var navigator: NavigatorServicesType!

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    typealias settingResult = (model: YXSmartPushSettingsModel?, error: Error?)
    typealias configResult = (model: YXSmartSettingConfigModel?, error: Error?)
    var stockSettingResultResponse: YXResultResponse<YXSmartPushSettingsModel>?
    var stockSettingConfigResultResponse: YXResultResponse<YXSmartSettingConfigModel>?
    let settingResultSubject = PublishSubject<settingResult>()
    let settingConfigSubject = PublishSubject<configResult>()

    var isRefeshing: Bool = false
    var isPulling: Bool = false
    
    var services: Services! {
        didSet {
            addBlockResponse()
        }
    }

    func addBlockResponse() {
        addStockSettingResultResponse()
        addStockSettingConfigResultResponse()
    }
    
    func addStockSettingResultResponse() {
        stockSettingResultResponse = { [weak self] (response) in
            
            self?.hudSubject.onNext(.hide)
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success {
                    strongSelf.settingResultSubject.onNext((result.data, nil))
                } else if let _ = result.msg  {
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            case .failed(let error):
                
                log(.error, tag: kNetwork, content: "\(error)")
                self?.settingResultSubject.onNext((nil, error))
                self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
        }
    }
    
    func addStockSettingConfigResultResponse() {
        stockSettingConfigResultResponse = { [weak self] (response) in

            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success {

                } else if let msg = result.msg  {
                    self?.hudSubject.onNext(.error(msg, false))
                    strongSelf.settingConfigSubject.onNext((nil, NSError(domain: msg, code: -1, userInfo: nil)))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.settingConfigSubject.onNext((nil, error))
            }
        }
    }
}
