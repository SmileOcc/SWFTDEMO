//
//  YXNewStockUSConfirmVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import SnapKit

class YXNewStockUSConfirmVC: YXHKViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockUSConfirmViewModel! = YXNewStockUSConfirmViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        initClosures()
        bindViewModel()
        requestPurchaseInfo()
        viewModel.hudSubject.onNext(.loading(nil, false))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initClosures() {
        
        detailView.subscribeRulesBlock = {
            [weak self] (url, title) in
            guard let `self` = self else { return }
            if url.count > 0 {
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: url
                ]
                let webModel = YXWebViewModel(dictionary: dic)
                webModel.webTitle = title
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: webModel)
            }
        }
        
        detailView.purchaseButtonEnabled = {
            [weak self] isEnable in
            guard let `self` = self else { return }
            self.purchaseButton.isEnabled = isEnable
        }
        
        bannerView.requestSuccessBlock = {
            [weak self]  in
            guard let `self` = self else { return }
            let bannerWidth = self.view.frame.width - 18 * 2
            let bannerHeight = bannerWidth/4.0 //4:1
            self.bannerView.snp.updateConstraints { (make) in
                make.height.equalTo(bannerHeight)
                make.top.equalToSuperview().offset(14)
            }
            
            self.detailView.snp.updateConstraints { (make) in
                make.top.equalTo(self.bannerView.snp.bottom).offset(6)
            }
        }
    }
    
    func setPurchaseButtonEnable(_ isEnable: Bool) {
        self.purchaseButton.isEnabled = isEnable
    }
    
    let riskTips = (String(format: YXLanguageUtility.kLang(key: "us_stock_subscribe_declare_tip"), YXLanguageUtility.kLang(key: "us_rule_5130"), YXLanguageUtility.kLang(key: "us_rul3_5131")) + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule1") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule2") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule3") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule4") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule5") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule6") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule7") + "\n" + YXLanguageUtility.kLang(key: "stock_subscribe_rule8") )
    @objc func purchaseButtonEvent() {
        
        verifySignature()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "stock_subscribe_comfirm_tip")
        navigationItem.rightBarButtonItems = [messageItem]
        
        self.view.addSubview(purchaseButton)
        self.view.addSubview(scrollView)
        scrollView.addSubview(bannerView)
        scrollView.addSubview(detailView)
        
        purchaseButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
            make.height.equalTo(48)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(purchaseButton.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
        }
        
        bannerView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(18)
            make.right.equalTo(self.view.snp.right).offset(-18)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(0)
        }
        
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerView.snp.bottom).offset(0)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.delaysContentTouches = false
        return scrollview
    }()
    
    lazy var detailView: YXNewStockUSConfirmView = {
        let view = YXNewStockUSConfirmView()
        return view
    }()
    
    lazy var purchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "confirm_and_sub"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonEvent), for: .touchUpInside)
        button.setDisabledTheme(0)
        button.isEnabled = false
        return button
    }()
    
    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        return view
    }()
}


extension YXNewStockUSConfirmVC {
    
    func bindViewModel() {
        
        viewModel.resultSubject.subscribe (onNext: { [unowned self] (userName, message) in
            self.viewModel.hudSubject.onNext(.hide)
            if userName == nil, let msg = message, msg.count > 0 {
                self.networkingHUD.showMessage(msg, in: self.view, hideAfter: 1.5)
            }
            if let name = userName {
                self.detailView.refreshUI(name)
            }
            
            
        }).disposed(by: rx.disposeBag)
        
        viewModel.signatureSubject.subscribe (onNext: { [unowned self] (success, message) in
            self.viewModel.hudSubject.onNext(.hide)
            if success == false, let msg = message, msg.count > 0 {
                self.networkingHUD.showMessage(msg, in: self.view, hideAfter: 1.5)
            }
            if success {
                self.viewModel.navigator.push(YXModulePaths.newStockUSPurchase.url, context: self.viewModel.sourceParam)
            }
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func requestPurchaseInfo() {
        viewModel.userService.request(.getCurrentUser, response: self.viewModel.resultResponse).disposed(by: rx.disposeBag)
    }
    
    func verifySignature() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        
        let agreementName = YXLanguageUtility.kLang(key: "us_rule_5130") + "," + YXLanguageUtility.kLang(key: "us_rul3_5131")
        let agreementUrl = USRuleUrl5130 + "," + USRuleUrl5131
        
   
        viewModel.userService.request(.verifySignature(agreementName: agreementName, agreementUrl: agreementUrl, autograph: detailView.signatureTextField.text ?? "", riskTips: riskTips, stockId: self.viewModel.sourceParam.ipoId, stockName: self.viewModel.sourceParam.stockCode), response: self.viewModel.signatureResponse).disposed(by: rx.disposeBag)
    }

}


