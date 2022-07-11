//
//  YXNewStockIPOListDetailVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXNewStockIPOListDetailVC: YXHKViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockIPOListDetailViewModel! = YXNewStockIPOListDetailViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var applyID: String!
    var ipoProTip: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        handleActionEvent()
        addRereshHeader()
        viewModel.hudSubject.onNext(.loading(nil, false))

        if #available(iOS 11.0, *) {

        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    let applyAmount = model.applyType == YXNewStockSubsType.financingSubs.rawValue ? (model.cash ?? 0.0) : (model.applyAmount ?? 0.0)
                    let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: Int64(self.applyID) ?? 0, isModify: 1, shared_applied: model.applyQuantity ?? 0, applied_amount: applyAmount, moneyType: model.moneyType ?? 2, applyType: YXNewStockSubsType.subscriptionType(model.applyType), financeAmount: model.financingBalance ?? 0.0, interestAmount: model.financingAmount ?? 0.0)
                    
                    if self.viewModel.exchangeType == .hk {
                        self.viewModel.navigator.push(YXModulePaths.newStockIPOPurchase.url, context: source)
                    } else {
                        self.viewModel.navigator.push(YXModulePaths.newStockUSPurchase.url, context: source)
                    }
                    
                }
            }).disposed(by: rx.disposeBag)
        
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
        
    }
    
    func adjustButtons(with purchaseModel: YXNewStockPurchaseDetailModel) {
        
       
        changeButton.isHidden = true
        cancelPurcahseButton.isHidden = true

        if purchaseModel.channel == 2 {
            return
        }
        
        guard YXNewStockDateFormatter.timeGreater(left: purchaseModel.endTime, right: purchaseModel.serverTime) else {
            return
        }

        guard purchaseModel.ipoStatus == YXNewStockPurchaseType.purchased.rawValue else {
            return
        }
        
        if purchaseModel.status == YXNewStockPurchaseType.purchased.rawValue ||
            purchaseModel.status == YXNewStockPurchaseType.financeApplying.rawValue {
            
            if purchaseModel.proCancelGuide == true {
                self.handleProTip()
            } else if self.marqueeView.isHidden == false {
                self.marqueeView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
                self.marqueeView.isHidden = true
            }
            let scale: CGFloat = YXConstant.screenWidth / 375.0
            let buttonWidth = (YXConstant.screenWidth - uniHorLength(80)) / 2.0
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
        
        var message = YXLanguageUtility.kLang(key: "newStock_purchase_cancel_msg")
        var confirmText = YXLanguageUtility.kLang(key: "common_confirm")
        if let model = self.viewModel.model, model.cancelDeductInterest == 1 {
            message = YXLanguageUtility.kLang(key: "newStock_purchase_cancel_msg2")
            confirmText = YXLanguageUtility.kLang(key: "newStock_confirm_cancellation")
        }
        let alertView = YXAlertView.alertView(message: message)
        let alertController = YXAlertController(alert: alertView)
        alertView.clickedAutoHide = false
        
        let cancelAction = YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { [weak alertView] (action) in
            alertView?.hide()
        }
        
        alertView.addAction(cancelAction)
        
        let confirmAction = YXAlertAction.action(title: confirmText, style: .default) { [weak alertController, weak alertView](action) in
            
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

        view.addSubview(marqueeView)
        view.addSubview(scrollview)
        scrollview.addSubview(purchaseView)
        scrollview.addSubview(changeButton)
        scrollview.addSubview(cancelPurcahseButton)

        marqueeView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            }
        }

        scrollview.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(marqueeView.snp.bottom)
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
        
    }

    lazy var marqueeView: YXMarqueeNoticeView = {
        let view = YXMarqueeNoticeView()
        view.isHidden = true
        view.clickBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.goProButtonAction()
        }
        return view
    }()
    
    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.alwaysBounceVertical = true
        scrollview.delaysContentTouches = false
        return scrollview
    }()
    
    lazy var purchaseView: YXNewStockPurchaseDetailView = {
        let view = YXNewStockPurchaseDetailView(applyType: self.viewModel.applyType, exchangeType: self.viewModel.exchangeType)
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


    @objc func goProButtonAction() {

        //高级账户介绍落地页
        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_USERCENTER_PRO_INTRO("Notice_PRO-IPO4_HK")]
        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

    }
    
}


extension YXNewStockIPOListDetailVC {
    //下拉更新
    func addRereshHeader() {
        scrollview.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
    }
    
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
        
        requestDetailInfo()
    }
    
    func requestDetailInfo() {
        guard let applyId = Int64(applyID) else { return }
        viewModel.services.request(.recordInfo(applyId: applyId), response: (self.viewModel.resultResponse)).disposed(by: rx.disposeBag)
    }
    
    func cancelPurchase() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        guard let applyId = Int64(applyID) else { return }
        
        var cash: Double = 0.0
        if let tempCash = viewModel.model?.cash {
            cash = tempCash
        }
        viewModel.services.request(.modifyIpo(actionType: 1, applyId: applyId, applyQuantity: viewModel.model?.applyQuantity ?? 0, cash: String(cash)), response: (self.viewModel.cancelResponse)).disposed(by: rx.disposeBag)
        
    }

    func handleProTip() {
        guard YXUserManager.shared().curLoginUser?.userRoleType == YXUserRoleType.common else {
            return
        }
        YXUserManager.getIPOProWithComplete(["PRO-IPO4"], complete: {
            [weak self] ipoTip in
            guard let `self` = self else { return }
            self.ipoProTip = ipoTip ?? ""
            if self.ipoProTip.count > 0 {
                self.marqueeView.isHidden = false
                self.marqueeView.detailLabel.text = self.ipoProTip
                self.marqueeView.snp.updateConstraints { (make) in
                    make.height.equalTo(20)
                }
            }
        })
    }
}
