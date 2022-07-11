//
//  YXNewStockECMSignatureVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import SnapKit
import WebKit

class YXNewStockECMSignatureVC: YXHKViewController, ViewModelBased, HUDViewModelBased {

    var viewModel: YXNewStockSignatureViewModel! = YXNewStockSignatureViewModel()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var hasReadDeclares: Bool = false
    
    let kWebViewMaxWHeight: CGFloat = 320
    
    let webVC = YXNewStockECMWebVC()
    var riskView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = YXLanguageUtility.kLang(key: "newStock_internal_placement")
   
        webVC.viewModel = YXWebViewModel(dictionary: [YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_ECM_RISK_URL()])
        riskView = webVC.view
        initUI()
        bindHUD()
        bindViewModel()
        headerRereshing()
    }
 
    func refreshUI() {
        
        if let defineName = viewModel.model?.defineName, defineName.count > 0 {
            let placeholderString = YXLanguageUtility.kLang(key: "newStock_signature_input_tip") + ":" +  defineName
            signatureTextField.attributedPlaceholder = NSAttributedString.init(string: placeholderString, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        }
        
        do {
            var linkStrings: [String] = []
            var urlStrings: [String] = []
            var webTitles: [String] = []
            
            var protocolString = ""
            if let protocolArray = viewModel.model?.ecmLetterList, protocolArray.isEmpty == false {
                for model in protocolArray {
                    if let name = model.placeLetterName, name.count > 0,
                        let url = model.placeLetterUrl, url.count > 0 {

                        var nameString = ""
                        if YXUserManager.isENMode() {
                            nameString = String(format: "\"%@\"", name)
                            protocolString.append(nameString)
                            protocolString.append(" and ")
                        } else {
                            nameString = String(format: "《%@》", name)
                            protocolString.append(nameString)
                            protocolString.append("、")
                        }
                        linkStrings.append(nameString)
                        urlStrings.append(url)
                        webTitles.append(name)
                    }
                }
            }
            
            var independentName: String = ""
            var independentUrl: String = YXH5Urls.NEW_STOCK_ECM_INDEPENDENT_URL()
            independentUrl.append(String(format: "ecmId=%@", self.viewModel.model?.ecmId ?? ""))
            independentUrl.append(String(format: "&handlingFee=%.02f", self.viewModel.model?.ecmFee ?? 0.0))
            independentUrl.append(String(format: "&applyQuantity=%ld", self.viewModel.sourceParam.shared_applied))
            independentUrl.append(String(format: "&applyAmount=%.02f", self.viewModel.sourceParam.applied_amount))
            if YXUserManager.isENMode() {
                independentName = String(format: "\"%@\"", YXLanguageUtility.kLang(key: "newStock_ecm_independent_name"))
            } else {
                independentName = String(format: "《%@》",  YXLanguageUtility.kLang(key: "newStock_ecm_independent_name"))
            }
            protocolString.append(independentName)
            linkStrings.append(independentName)
            urlStrings.append(independentUrl)
            webTitles.append(YXLanguageUtility.kLang(key: "newStock_ecm_independent_name"))
            
            let formatString: String = YXLanguageUtility.kLang(key: "newStock_internal_agree_declare")
            let agreeString = String(format: formatString, protocolString)
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 4
            let attributeString = NSMutableAttributedString.init(string: agreeString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.paragraphStyle : paragraph])
            
            for (index, string) in linkStrings.enumerated() {
                let range = (agreeString as NSString).range(of: string)
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], range: range)
                
                attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTextColor(), backgroundColor: UIColor.clear, tapAction: { [weak self] (view, attstring, range, rect) in
                    guard let `self` = self else { return }
                    
                    self.signatureTextField.resignFirstResponder()
                    let dic: [String: Any] = [
                        YXWebViewModel.kWebViewModelUrl: urlStrings[index]
                    ]
                    let webModel = YXWebViewModel(dictionary: dic)
                    if index < webTitles.count {
                        webModel.webTitle = webTitles[index]
                    }
                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: webModel)
                })
            }
            
            declareLabel.attributedText = attributeString
            let height = (agreeString as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 36 - 17, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle : paragraph], context: nil).size.height
            declareLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(declareButton.snp.right).offset(3)
                make.top.equalTo(declareButton.snp.top).offset(-2)
                make.right.equalTo(self.view.snp.right).offset(-18)
                make.bottom.equalToSuperview().offset(-20)
                make.height.equalTo(height)
            }
        }
    }
    
    func bindViewModel() {
        
        purchaseButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [unowned self] (_) in
                self.signatureTextField.resignFirstResponder()
                self.tradeToApplyPurchase(needInputPwd: true)
            }).disposed(by: rx.disposeBag)
        
        //MARK: 接口返回的响应
        viewModel.resultSubject.subscribe(onNext: {
            [weak self] (isSuccess, message) in
            guard let strongSelf = self else { return }
            
            if let msg = message, msg.count > 0 {
                strongSelf.networkingHUD.showError(msg, in: strongSelf.view, hideAfter: 2)
            }
            
            if strongSelf.viewModel.isRefeshing {
                strongSelf.viewModel.isRefeshing = false
                //strongSelf.scrollView.mj_header.endRefreshing()
            }
            
            if isSuccess {
                strongSelf.refreshUI()
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
                    let type: YXExchangeType = YXExchangeType.currentType(self.viewModel.model?.exchangeType)
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
        
        bannerView.requestSuccessBlock = {
            [weak self]  in
            guard let `self` = self else { return }
            let bannerWidth = YXConstant.screenWidth - 18 * 2
            let bannerHeight = bannerWidth/4.0 //4:1
            self.bannerView.snp.updateConstraints { (make) in
                make.height.equalTo(bannerHeight)
                make.top.equalToSuperview().offset(14)
            }
        }
        
    }
    @objc func declareButtonEvent() {
        self.declareButton.isSelected = !self.declareButton.isSelected
        hasReadDeclares = !hasReadDeclares
    }
    
    func tradeToApplyPurchase(needInputPwd: Bool) {
        
        guard hasReadDeclares else {
            networkingHUD.showMessage(String(format: "%@", YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sign_tip")), in: self.view, hideAfter: 2.0)
            return
        }
        
        guard let signatureText = signatureTextField.text, signatureText.count > 0 else {
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
            if let signatureText = self.signatureTextField.text {
                self.viewModel.services.request(.ecmModify(applyAmount: String(self.viewModel.sourceParam.applied_amount), applyId: self.viewModel.sourceParam.applyId, applyQuantity: Int64(self.viewModel.sourceParam.shared_applied), custSignature: signatureText, inputPwd: needInputPwd, subscripSelect: nil), response: (self.viewModel.applyResponse)).disposed(by: self.rx.disposeBag)
            }
            
        } else {
            //购买股票
            if let signatureText = self.signatureTextField.text,let tempECMID = self.viewModel.model?.ecmId, let ecmId = Int64(tempECMID) {
                self.viewModel.services.request(.ecmApply(applyAmount: String(self.viewModel.sourceParam.applied_amount), custSignature: signatureText, ecmId: ecmId, applyQuantity: Int64(self.viewModel.sourceParam.shared_applied), applyType: 3, inputPwd: needInputPwd, subscripSelect: nil), response: (self.viewModel.applyResponse)).disposed(by: self.rx.disposeBag)
            }
        }
        
    }
    
    func initUI() {
        
        let leftMargin: CGFloat = 18.0
        
        view.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            
            make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            make.left.right.equalToSuperview()
            make.bottom.equalTo(purchaseButton.snp.top)
        }
        
        scrollView.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalTo(self.view.snp.right).offset(-leftMargin)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(0)
        }
        
        //风险提示
        do {
            scrollView.addSubview(riskWarningLabel)
            scrollView.addSubview(riskView)
            
            riskWarningLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftMargin)
                make.right.equalTo(self.view.snp.right).offset(-leftMargin)
                make.top.equalTo(bannerView.snp.bottom).offset(26)
            }
            
            riskView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.right.equalTo(self.view.snp.right).offset(-15)
                make.top.equalTo(riskWarningLabel.snp.bottom).offset(18)
                make.height.equalTo(kWebViewMaxWHeight)
            }
        }
        
        
        //确认输入签名界面
        do {
            scrollView.addSubview(signatureLabel)
            scrollView.addSubview(signatureTextField)
            scrollView.addSubview(lineView)
            
            signatureLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftMargin)
                make.right.equalTo(self.view.snp.right).offset(-leftMargin)
                make.top.equalTo(riskView.snp.bottom).offset(40)
            }
            
            signatureTextField.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftMargin)
                make.right.equalTo(self.view.snp.right).offset(-leftMargin)
                make.top.equalTo(signatureLabel.snp.bottom).offset(10)
                make.height.equalTo(25)
            }
            
            lineView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftMargin)
                make.right.equalTo(self.view.snp.right).offset(-leftMargin)
                make.top.equalTo(signatureTextField.snp.bottom).offset(8)
                make.height.equalTo(1)
            }
            
        }
        
        //同意协议声明
        do {
            scrollView.addSubview(declareButton)
            scrollView.addSubview(declareLabel)
            
            declareButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftMargin)
                make.top.equalTo(lineView.snp.bottom).offset(13)
                make.width.height.equalTo(14)
            }
            
            declareLabel.snp.makeConstraints { (make) in
                make.left.equalTo(declareButton.snp.right).offset(3)
                make.top.equalTo(declareButton.snp.top).offset(-2)
                make.right.equalTo(self.view.snp.right).offset(-leftMargin)
                make.bottom.equalToSuperview().offset(-20)
                make.height.equalTo(100)
            }
        }
    }

    lazy var purchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.backgroundColor = QMUITheme().themeTextColor()
        return button
    }()
    

    @objc lazy var declareButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        button.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .selected)
        button.addTarget(self, action: #selector(declareButtonEvent), for: .touchUpInside)
        return button
    }()
    
    lazy var declareLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.delaysContentTouches = false
        return scrollview
    }()
    
    lazy var riskWarningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_internal__subs_risk_tip")
        return label
    }()
    
    lazy var signatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sign")
        return label
    }()
    
    lazy var signatureTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = QMUITheme().textColorLevel1()
        textField.textAlignment = .left
        textField.attributedPlaceholder = NSAttributedString.init(string: YXLanguageUtility.kLang(key: "newStock_signature_input_tip"), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        return textField
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
}


extension YXNewStockECMSignatureVC {
  
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
       
        viewModel.hudSubject.onNext(.loading(nil, false))
        requestPurchaseInfo()
    }
    
    func requestPurchaseInfo() {
        //请求股票详细信息数据
        guard let ipoid = Int64(viewModel.sourceParam.ipoId) else { return }
        
        viewModel.services.request(.ecmOrderInfo(ipoId: ipoid), response: self.viewModel.resultResponse).disposed(by: rx.disposeBag)
    }
    
}

