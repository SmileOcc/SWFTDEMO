//
//  YXNewStockECMListDetailVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXNewStockECMListDetailVC: YXHKViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockECMListDetailViewModel! = YXNewStockECMListDetailViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var applyID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        handleActionEvent()
        addRereshHeader()
        viewModel.hudSubject.onNext(.loading(nil, false))
        headerRereshing()
    }
    
    func handleActionEvent() {
        cancelPurcahseButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.cancelPurchaseEvent()
            }).disposed(by: rx.disposeBag)
        
        changeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if let model = self.viewModel.model {
                    let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: Int64(self.applyID) ?? 0, isModify: 1, shared_applied: model.applyQuantity ?? 0, applied_amount: model.totalAmount ?? 0, moneyType: model.moneyType ?? 2, applyType: YXNewStockSubsType.subscriptionType(model.applyType), ipoType: .onlyInternal, ecmApplyAmount: model.applyAmount ?? 0.0)
                        
                    if self.viewModel.exchangeType == .hk {
                        self.viewModel.navigator.push(YXModulePaths.newStockECMPurchase.url, context: source)
                    } else {
                        self.viewModel.navigator.push(YXModulePaths.newStockUSConfirm.url, context: source)
                    }
                    
                }
            }).disposed(by: rx.disposeBag)
        
        if self.viewModel.exchangeType == .us {
            confirmButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if let model = self.viewModel.model {
                    let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: Int64(self.applyID) ?? 0, isModify: 1, shared_applied: model.applyQuantity ?? 0, applied_amount: model.totalAmount ?? 0, moneyType: model.moneyType ?? 2, applyType: YXNewStockSubsType.subscriptionType(model.applyType), ipoType: .onlyInternal, ecmApplyAmount: model.applyAmount ?? 0.0)
                        
                    self.viewModel.navigator.push(YXModulePaths.newStockUSConfirm.url, context: source)
                    
                }
            }).disposed(by: rx.disposeBag)
        }
        
        viewModel.resultSubject.subscribe(onNext: {
            [weak self] (isSuccess, message) in
            guard let strongSelf = self else { return }
            
            if let msg = message, strongSelf.viewModel.isRefeshing {
                strongSelf.networkingHUD.showError(msg, in: strongSelf.view, hideAfter: 2)
            }
            
            if strongSelf.viewModel.isRefeshing {
                strongSelf.viewModel.isRefeshing = false
                strongSelf.scrollview.mj_header?.endRefreshing()
            }
            
            if isSuccess, let model = strongSelf.viewModel.model {
                strongSelf.purchaseView.refreshUI(model: model)
                strongSelf.adjustButtons(with: model)
                
                strongSelf.requestEcmCompensation(applyAmount: model.applyAmount ?? 0.0, moneyType: model.moneyType ?? 2, stockCode: model.stockCode ?? "")
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel.cancelSubject.subscribe (onNext: { [weak self] (result, message) in
            guard let strongSelf = self else { return }
            if let msg = message {
                strongSelf.networkingHUD.showMessage(msg, in: strongSelf.view, hideAfter: 2.0)
            }
            if let success = result {
                if success == 1 {
                    strongSelf.headerRereshing()
                } else if success == 0 {
                    YXUserUtility.validateTradePwd(inViewController: strongSelf, successBlock: {
                        [weak self] (_) in
                        guard let `self` = self else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            
                            self.cancelPurchase()
                        })
                        }, failureBlock: nil, isToastFailedMessage: nil)
                }
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel.compensateSubject.subscribe(onNext: {
            [weak self] compensateModel in
            guard let `self` = self else { return }
            if let model = compensateModel {
                self.purchaseView.refreshCompensateView(model)
            }
            
        }).disposed(by: rx.disposeBag)
        
        purchaseView.compensateBlock = {
            [weak self] in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_AWARD_CENTER_URL()
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        
    }
    
    func adjustButtons(with purchaseModel: YXNewStockPurchaseDetailModel) {
        

        changeButton.isHidden = true
        cancelPurcahseButton.isHidden = true

        if purchaseModel.channel == 2 {
            return
        }
        
        guard YXNewStockDateFormatter.timeGreater(left: purchaseModel.ecmEndTime, right: purchaseModel.serverTime) else {
            return
        }
        
        if self.viewModel.exchangeType == .us {
            confirmButton.isHidden = true
            if purchaseModel.status == YXNewStockPurchaseType.reconfirmed.rawValue, purchaseModel.ecmStatus == YXNewStockPurcahseStatus.ecmReconfirm.rawValue {
                confirmButton.isHidden = false
                return
            }
        }
        
        if (purchaseModel.status == YXNewStockPurchaseType.purchased.rawValue ||
            purchaseModel.status == YXNewStockPurchaseType.financeApplying.rawValue) &&
            (purchaseModel.ecmStatus == YXNewStockPurcahseStatus.purchasing.rawValue || purchaseModel.ecmStatus == YXNewStockPurcahseStatus.ecmReconfirm.rawValue ) {
            
            let scale: CGFloat = YXConstant.screenWidth / 375.0
            let buttonWidth = (YXConstant.screenWidth - 80 * scale) / 2.0
            let leftX = (YXConstant.screenWidth - buttonWidth) / 2.0
            if purchaseModel.accountCanCancel == true, purchaseModel.accountCanModify == true {
                changeButton.isHidden = false
                changeButton.isEnabled = true
                cancelPurcahseButton.isHidden = false
                cancelPurcahseButton.isEnabled = true
                
                changeButton.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(uniHorLength(25))
                }
                
                cancelPurcahseButton.snp.remakeConstraints { (make) in
                    make.height.equalTo(44)
                    make.top.equalTo(changeButton.snp.top)
                    make.width.equalTo(buttonWidth)
                    make.left.equalTo(changeButton.snp.right).offset(30 * scale)
                }
            } else if purchaseModel.accountCanCancel == true {
                
                cancelPurcahseButton.isHidden = false
                cancelPurcahseButton.isEnabled = true
                cancelPurcahseButton.snp.remakeConstraints { (make) in
                    make.height.equalTo(44)
                    make.top.equalTo(changeButton.snp.top)
                    make.width.equalTo(buttonWidth)
                    make.left.equalToSuperview().offset(leftX)
                }
            } else if purchaseModel.accountCanModify == true {
                
                changeButton.isHidden = false
                changeButton.isEnabled = true
                changeButton.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(leftX)
                }
            }
  
        }
     
    }
    
    func cancelPurchaseEvent() {
         
        let message = YXLanguageUtility.kLang(key: "newStock_purchase_cancel_msg")
        let alertView = YXAlertView.alertView(message: message)
        let alertController = YXAlertController(alert: alertView)
        alertView.clickedAutoHide = false
        
        let cancelAction = YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { [weak alertView] (action) in
            alertView?.hide()
        }
        
        alertView.addAction(cancelAction)
        
        let confirmAction = YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default) { [weak alertController, weak alertView](action) in
            
            alertController?.dismissComplete = { [weak self] in
                guard let strongSelf = self else { return }
                
                strongSelf.cancelPurchase()
            }
            
            alertView?.hide()
        }
        alertView.addAction(confirmAction)
        
        UIViewController.current().present(alertController!, animated: true, completion: nil)
    }
    
    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "newStock_purchase_detail")
        navigationItem.rightBarButtonItems = [messageItem]
        
        view.addSubview(scrollview)
        scrollview.addSubview(purchaseView)
        scrollview.addSubview(changeButton)
        scrollview.addSubview(cancelPurcahseButton)
        
        scrollview.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        purchaseView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.right.equalTo(self.view.snp.right)
        }
        
        let scale: CGFloat = YXConstant.screenWidth / 375.0
        let buttonWidth = (YXConstant.screenWidth - 80 * scale) / 2.0
        changeButton.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.top.equalTo(purchaseView.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(25 * scale)
            make.width.equalTo(buttonWidth)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        cancelPurcahseButton.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.top.equalTo(changeButton.snp.top)
            make.width.equalTo(buttonWidth)
            make.left.equalTo(changeButton.snp.right).offset(30 * scale)
        }
        
        changeButton.isHidden = true
        cancelPurcahseButton.isHidden = true
        
        if self.viewModel.exchangeType == .us {
            scrollview.addSubview(confirmButton)
            confirmButton.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.top.equalTo(purchaseView.snp.bottom).offset(25)
                make.centerX.equalTo(self.view)
                make.width.equalTo(buttonWidth)
            }
            confirmButton.isHidden = true
        }
        
    }
    
    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.alwaysBounceVertical = true
        scrollview.delaysContentTouches = false
        return scrollview
    }()
    
    lazy var purchaseView: YXNewStockECMPurchaseDetailView = {
        let view = YXNewStockECMPurchaseDetailView(exchangeType: self.viewModel.exchangeType)
        return view
    }()
    
    lazy var changeButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_purchase_change"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor
        return button
    }()
    
    lazy var cancelPurcahseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_cancel_purchase"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor
        return button
    }()
    
    lazy var confirmButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "ecm_reconfirmed"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor
        return button
    }()
    
}


extension YXNewStockECMListDetailVC {
    //下拉更新
    func addRereshHeader() {
        scrollview.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
    }
    
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
        
        requestEcmInfo()
    }
    
    func requestEcmInfo() {
        guard let applyId = Int64(applyID) else { return }
        viewModel.services.request(.ecmDetail(applyId: applyId), response: (self.viewModel.resultResponse)).disposed(by: rx.disposeBag)
    }
    
    func requestEcmCompensation(applyAmount: Double, moneyType: Int, stockCode: String) {
         viewModel.services.request(.ecmCompensate(applyAmount: applyAmount, moneyType: moneyType, stockCode: stockCode), response: (self.viewModel.compensateResponse)).disposed(by: rx.disposeBag)
    }
    
    func cancelPurchase() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        guard let applyId = Int64(applyID) else { return }
        
        viewModel.services.request(.ecmCancel(applyId: applyId), response: (self.viewModel.cancelResponse)).disposed(by: rx.disposeBag)
        
    }
}
