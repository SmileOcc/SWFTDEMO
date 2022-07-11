//
//  YXAssetsDescriptionViewModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXStatementSettingViewModel: YXViewModel {
    
    var statementLanguage:TradeStatementLanguageType = .chinese
    
    override func initialize() {
        super.initialize()
    }

    func reqLanguageSingle() -> Single<String?> {
        
        let single = Single<String?>.create { single in
            let requestModel = YXTradeStatementQueryLanguangeReqModel()
            let request = YXRequest.init(request: requestModel)
            request.startWithBlock {[weak self] response in
                guard let `self` = self else { return }
                if let data = response.data,  response.code == .success {
                    if let language = data["statementLanguage"] as? Int {
                        self.statementLanguage = TradeStatementLanguageType.init(rawValue: language) ?? .chinese
                        single(.success(""))
                    }
                }else{
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_failed"))
                }
            } failure: { request in
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_failed"))
            }
            return Disposables.create()
        }
        
        return single
    }
    
    func reqChangeLanguageSingle(type:TradeStatementLanguageType) -> Single<String?> {
        
        let single = Single<String?>.create { single in
            let requestModel = YXTradeStatementChangeLanguangeReqModel()
            requestModel.statementLanguage = type
            
            let request = YXRequest.init(request: requestModel)
            let loadingHud = YXProgressHUD.showLoading("")
            request.startWithBlock {[weak self] response in
                loadingHud.hide(animated: true)
                if response.code == .success {
                    single(.success("success"))
                }else{
                    single(.success(nil))
                }
            } failure: { request in
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_failed"))
                loadingHud.hide(animated: true)
            }
            return Disposables.create()
        }
        
        return single
    }
}
