//
//  YXNewStockIPOPurchaseViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockIPOPurchaseViewModel: HUDServicesViewModel {
    typealias Services = YXNewStockService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
    var sourceParam: YXPurchaseDetailParams!
    //响应回调
    var resultResponse: YXResultResponse<YXNewStockDetailInfoModel>?
    var availbleAmountResponse: YXResultResponse<YXNewStockAvailbleAmountModel>?
    var applyResponse: YXResultResponse<YXNewStockApplyPurchaseModel>?
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, msg: String?)
    let resultSubject = PublishSubject<resultType>()
    let amountSubject = PublishSubject<resultType>()
    let applySubject = PublishSubject<(String, Int)>()
    lazy var groupOberver: Observable<[resultType]> = { [unowned self] in
        Observable.zip([self.resultSubject, self.amountSubject])
    }()

    var services: Services! = YXNewStockService()
    var model: YXNewStockDetailInfoModel?
    
    var availableAmount: Double = 0.0
    var subsType: YXNewStockSubsType = .cashSubs

    init() {
        resultResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    if let qtyAndCharges = model.qtyAndCharges {
                        qtyAndCharges.forEach({ (obj) in
                            obj.purchaseNum = strongSelf.sourceParam.shared_applied
                            obj.purchaseAmount = strongSelf.sourceParam.applied_amount
                            obj.cashHandlingFee = model.bookingFee
                            obj.financeHandlingFee = model.financingFee
                        })
                    }
                    strongSelf.model = model
                    strongSelf.resultSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.resultSubject.onNext((false, msg))
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.resultSubject.onNext((false,  YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        availbleAmountResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    if let yxIpoBalance = model.yxIpoBalance, let amount = Double(yxIpoBalance) {
                        strongSelf.availableAmount = amount + strongSelf.sourceParam.applied_amount + strongSelf.sourceParam.interestAmount
                        strongSelf.amountSubject.onNext((true,nil))
                    } else {
                        strongSelf.amountSubject.onNext((false,nil))
                    }
                    
                } else if let _ = result.msg {
                    strongSelf.amountSubject.onNext((false,nil))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.amountSubject.onNext((false,nil))
            }
        }

        applyResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                var addResult = false
                if code != .tradePwdInvalid, strongSelf.sourceParam.isModify != 1  {
                    addResult = strongSelf.addStockToOptional()
                }
                if code == .success {
                    if let model = result.data, model.status == 20, let msg = result.msg {
                        strongSelf.showAlertWithMsg(msg: msg, isApply: true)
                    } else {
                        var msg = YXLanguageUtility.kLang(key: "newStock_purchase_submitted")
                        if addResult {
                            msg = msg + "\n" + YXLanguageUtility.kLang(key: "newStock_purchase_add_optional")
                            strongSelf.applySubject.onNext((msg, 0))
                        } else {
                            strongSelf.applySubject.onNext((msg, 0))
                        }
                    }

                } else if code == .tradePwdInvalid  {
                    strongSelf.applySubject.onNext(("", 1))
                } else if (code == .tradeFrozenError || code == .accountFreeze || code == .userFrozenError), let msg = result.msg {
                    strongSelf.applySubject.onNext(("", -1))
                    strongSelf.showAlertWithMsg(msg: msg)
                } else if let msg = result.msg {      //if code == .newStockNotEnoughFunds   资金不足可以用这个判断
                    strongSelf.applySubject.onNext((msg, -1))
                } else {
                    strongSelf.applySubject.onNext((YXLanguageUtility.kLang(key: "common_net_error"), -1))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                if strongSelf.sourceParam.isModify != 1 {
                    strongSelf.addStockToOptional()
                }
                strongSelf.applySubject.onNext((YXLanguageUtility.kLang(key: "common_net_error"), -1))
            }
        }
    }
    
    func showAlertWithMsg(msg: String, isApply: Bool = false) {
        
        let alertView = YXAlertView(message: msg)
        alertView.clickedAutoHide = false
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView, weak self] action in
            guard let `self` = self else { return }
            if isApply {
                self.applySubject.onNext(("", 0))
            }
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    @discardableResult
    func addStockToOptional() -> Bool {
        let symbol = self.sourceParam.stockCode
        let market = YXExchangeType.market(self.sourceParam.exchangeType)
        let secu = YXOptionalSecu()
        secu.market = market
        secu.symbol = symbol
        if YXSecuGroupManager.shareInstance().containsSecu(secu) {
            return false
        } else if YXSecuGroupManager.shareInstance().append(secu) == true {
            return true
        }
        return false
    }
}
