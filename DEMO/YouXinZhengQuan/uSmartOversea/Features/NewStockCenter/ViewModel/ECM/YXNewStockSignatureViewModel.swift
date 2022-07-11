//
//  YXNewStockSignatureViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa
import YXKit

class YXNewStockSignatureViewModel: HUDServicesViewModel {
    
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
    var sourceParam: YXPurchaseDetailParams!

    //更新状态
    var isRefeshing: Bool = false
    var isPulling: Bool = false

    //响应回调
    var resultResponse: YXResultResponse<YXNewStockECMOrderInfoModel>?
    var applyResponse: YXResultResponse<YXNewStockApplyPurchaseModel>?
  
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, String?)
    let resultSubject = PublishSubject<resultType>()
    let applySubject = PublishSubject<(String, Int)>()
    
    var services: Services! = YXNewStockService()
    var model: YXNewStockECMOrderInfoModel?
    
    var quoteService: YXQuotesDataService = YXQuotesDataService()
    
    init() {
        resultResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    strongSelf.model = model
                    strongSelf.resultSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.resultSubject.onNext((false, msg))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.resultSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        applyResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success {
                    strongSelf.applySubject.onNext((YXLanguageUtility.kLang(key: "newStock_ecm_purchase_submitted"), 0))
                } else if code == .tradePwdInvalid  {
                    strongSelf.applySubject.onNext(("", 1))
                } else if (code == .tradeFrozenError || code == .accountFreeze || code == .userFrozenError), let msg = result.msg {
                    strongSelf.applySubject.onNext(("", -1))
                    strongSelf.showFreezeAlertWithMsg(msg: msg)
                } else if let msg = result.msg {      //if code == .newStockNotEnoughFunds   资金不足可以用这个判断
                    strongSelf.applySubject.onNext((msg, -1))
                } else {
                    strongSelf.applySubject.onNext((YXLanguageUtility.kLang(key: "common_net_error"), -1))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.applySubject.onNext((YXLanguageUtility.kLang(key: "common_net_error"), -1))
            }
        }
        
    }
    
    
    func showFreezeAlertWithMsg(msg: String) {
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] action in
            
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
}
