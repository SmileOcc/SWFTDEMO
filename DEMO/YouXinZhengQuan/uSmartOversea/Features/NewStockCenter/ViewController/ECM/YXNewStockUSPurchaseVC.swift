//
//  YXNewStockUSPurchaseVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import SnapKit

class YXNewStockUSPurchaseVC: YXHKViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockUSPurchaseViewModel! = YXNewStockUSPurchaseViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        initClosures()
        bindViewModel()
        viewModel.hudSubject.onNext(.loading(nil, false))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPurchaseInfo()
    }
    
    func initClosures() {
        
        do {
            //入金
            detailView.saveValueClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            detailView.updateTotalAmountClosure = {
                [unowned self] amount in
                //更新总金额
                self.initTotalPurchaseLabelDataWithAmount(amount: amount)
            }
            
            //认购按钮可点击状态改变
            detailView.purchaseEnableClosure = {
                [unowned self] isEnable in
                self.setPurchaseButtonEnable(isEnable)
            }
            
            detailView.agreeDeclareClosure = {
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
    
    @objc func purchaseButtonEvent() {
        
        if detailView.hasReadDeclares {
            let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "usStock_subs_risk_tip"), message: YXLanguageUtility.kLang(key: "usStock_subs_risk_message"), messageAlignment: .left)
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_go_back"), style: .cancel, handler: { (action) in
                
            }))
            
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "continue_subscribe"), style: .default, handler: { [weak self] (action) in
                guard let `self` = self else { return }
                self.tradeToApplyPurchase(needInputPwd: true)
            }))
            alertView.showInWindow()
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "us_stock_subscribe_title")
        navigationItem.rightBarButtonItems = [messageItem]
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(bannerView)
        scrollView.addSubview(detailView)
        self.view.addSubview(lineView)
        self.view.addSubview(totalLabel)
        self.view.addSubview(purchaseButton)
        if let window = UIApplication.shared.delegate?.window {
            window!.addSubview(purchaseQtyView)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding() - 49)
            make.height.equalTo(1)
        }
        
        purchaseButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
            make.top.equalTo(lineView.snp.bottom)
            make.width.equalTo(155 * YXConstant.screenWidth / 375.0)
        }
        
        self.totalLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
            make.right.equalTo(purchaseButton.snp.left)
        }
        self.initTotalPurchaseLabelDataWithAmount(amount: 0.00)
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
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
    
    lazy var detailView: YXNewStockUSPurchaseView = {
        let view = YXNewStockUSPurchaseView()
        return view
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 22.0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var purchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonEvent), for: .touchUpInside)
        button.setDisabledTheme(0)
        return button
    }()
    
    lazy var purchaseQtyView: YXNewStockPurchaseQtyView = {
        let view = YXNewStockPurchaseQtyView.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight))
        return view
    }()
    
    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        return view
    }()
}


extension YXNewStockUSPurchaseVC {
    
    func bindViewModel() {
        
        
        viewModel.groupOberver.subscribe (onNext: { [unowned self] (result) in
            self.viewModel.hudSubject.onNext(.hide)
            
            if self.isFirstLoad {
                self.isFirstLoad = false
                
                var msgArray: [String] = []
                
                result.forEach({ (isSuccess, msg) in
                    if let message = msg, message.count > 0 {
                        msgArray.append(message)
                    }
                })
                
                if msgArray.count >= 1  {
                    self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
                }
                
                if let model = self.viewModel.ecmModel {
                    self.detailView.refreshUI(model: model, sourceParams: self.viewModel.sourceParam, availbleAmount: self.viewModel.availableAmount)
     
                } else {
                    self.detailView.refreshEmptyView(availbleAmount: self.viewModel.availableAmount, sourceParams: self.viewModel.sourceParam)
                }
            } else {
                if let _ = self.viewModel.ecmModel {
                    self.detailView.initAvailableAmountData(self.viewModel.availableAmount)
                }
            }
            
        }).disposed(by: rx.disposeBag)
        
        // 购买或改单回调
        viewModel.applySubject.subscribe(onNext: {
            [weak self] (msg, state) in
            guard let `self` = self else { return }
            
            if msg.count > 0  {
                self.networkingHUD.showMessage(msg, in: self.view, hideAfter: 2.0 )
            }
            
            if state == 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    let type: YXExchangeType = YXExchangeType.currentType(self.viewModel.ecmModel?.exchangeType)
                    self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
                })
            } else if state == 1 { //认购时每次都需要校验密码
                YXUserUtility.validateTradePwd(inViewController: self, successBlock: {
                    [weak self](_) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {

                        self.tradeToApplyPurchase(needInputPwd: false)
                    })
                }, failureBlock: nil, isToastFailedMessage: nil)
            }
        }).disposed(by: rx.disposeBag)

    }
    
    func requestPurchaseInfo() {
        //请求股票详细信息数据
        guard let ipoid = Int64(viewModel.sourceParam.ipoId) else { return }
        
        requestAvailbaleAmount()
        bannerView.requestBannerInfo(.newStockApply)
        requestECMInfo(ipoid)
    }
    
    func requestECMInfo(_ ipoid: Int64) {
        viewModel.services.request(.ecmOrderInfo(ipoId: ipoid), response: self.viewModel.resultResponse).disposed(by: rx.disposeBag)
    }
    
    func requestAvailbaleAmount() {
        viewModel.services.request(.accountInfo(moneyType: viewModel.sourceParam.moneyType), response: (viewModel.availbleAmountResponse)).disposed(by: rx.disposeBag)
    }
    
    func tradeToApplyPurchase(needInputPwd: Bool) {
        
        guard detailView.hasReadDeclares else {
            networkingHUD.showMessage(String(format: "%@", YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sign_tip")), in: self.view, hideAfter: 2.0)
            return
        }
   
        //判断有无设置交易密码
        if let hasTrade = YXUserManager.shared().curLoginUser?.tradePassword, hasTrade == true {
            
            applyPurchase(type: viewModel.sourceParam.isModify, needInputPwd: needInputPwd)
        } else {
            //没有设置交易密码 -> 设置交易密码
            YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    guard let `self` = self else { return }
                    
                    // 交易密码设置成功
                    self.applyPurchase(type: self.viewModel.sourceParam.isModify, needInputPwd: needInputPwd)
                })
            }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: true, needToken: false)
        }
    }
       
       //ECM认购每次都需要输入密码
    func applyPurchase(type: Int, needInputPwd: Bool) {
        
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        
   
        if type == 1 { //更改认购
            if let signatureText = self.viewModel.ecmModel?.defineName {
            
                self.viewModel.services.request(.ecmModify(applyAmount: String(detailView.calculateAmount), applyId: self.viewModel.sourceParam.applyId, applyQuantity: detailView.calculateQuantity, custSignature: signatureText, inputPwd: needInputPwd, subscripSelect: detailView.isCashType ? 2 : 1), response: (self.viewModel.applyResponse)).disposed(by: self.rx.disposeBag)
            }
            
        } else {
            //购买股票
            if let signatureText = self.viewModel.ecmModel?.defineName, let tempECMID = self.viewModel.ecmModel?.ecmId, let ecmId = Int64(tempECMID) {
                self.viewModel.services.request(.ecmApply(applyAmount: String(detailView.calculateAmount), custSignature: signatureText, ecmId: ecmId, applyQuantity: detailView.calculateQuantity, applyType: 3, inputPwd: needInputPwd, subscripSelect: detailView.isCashType ? 2 : 1), response: (self.viewModel.applyResponse)).disposed(by: self.rx.disposeBag)
            }
        }
        
    }
}

extension YXNewStockUSPurchaseVC {

    func initTotalPurchaseLabelDataWithAmount(amount: Double) {
        
        var unitString = detailView.unitString
        if unitString.count <= 0 {
            unitString = YXToolUtility.moneyUnit(viewModel.sourceParam.moneyType)
        }
        let prefixString = YXLanguageUtility.kLang(key: "newStock_total_funds")
        if amount >= 0 {
            
            let suffixString = YXNewStockMoneyFormatter.shareInstance.formatterMoney(amount)
            let titelString = String(format: "%@%@%@", prefixString, suffixString, unitString)
            
            let array = suffixString.components(separatedBy: ".")
            let numString = array.first!
            let pointString = array.count > 1 ? array.last! : ""
            
            let mutString = NSMutableAttributedString.init(string: titelString)
            mutString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1(), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: 0, length: prefixString.count))
            var bigFont: UIFont = .systemFont(ofSize: 26, weight: .medium)
            var bigPointFont: UIFont = .systemFont(ofSize: 18, weight: .medium)
            if YXToolUtility.is4InchScreenWidth() {
                bigFont = .systemFont(ofSize: 22, weight: .medium)
                bigPointFont = .systemFont(ofSize: 15, weight: .medium)
            }
            mutString.addAttribute(.font, value: bigFont, range: NSRange(location: prefixString.count, length: numString.count))
            mutString.addAttribute(.font, value: bigPointFont, range: NSRange(location: prefixString.count + numString.count, length: pointString.count + 1))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: mutString.length - unitString.count, length: unitString.count))
            
            totalLabel.attributedText = mutString
        } else {
            totalLabel.text = String(format: "%@    %@", prefixString, unitString)
        }
    }
}

