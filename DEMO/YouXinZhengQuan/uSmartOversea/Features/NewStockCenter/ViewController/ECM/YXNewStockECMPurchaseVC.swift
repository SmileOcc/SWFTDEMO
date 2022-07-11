//
//  YXNewStockECMPurchaseVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import SnapKit

class YXNewStockECMPurchaseVC: YXHKViewController, ViewModelBased, HUDViewModelBased {

    var viewModel: YXNewStockECMPurchaseViewModel! = YXNewStockECMPurchaseViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var isFirstLoad: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        initClosures()
        bindViewModel()
        setPurchaseButtonEnable(false)
        viewModel.hudSubject.onNext(.loading(nil, false))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPurchaseInfo()
    }

    func initClosures() {

       
        do {
            internalView.updateTotalAmountClosure = {
                [unowned self] amount in
                //更新总金额
                self.initTotalPurchaseLabelDataWithAmount(amount: amount)
            }
            
            //认购按钮可点击状态改变
            internalView.purchaseEnableClosure = {
                [unowned self] isEnable in
                self.setPurchaseButtonEnable(isEnable)
            }
            
            //入金
            internalView.saveValueClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            //新股认购说明
            internalView.purchaseDeclareClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_SUBSCRIBE_INSTRUCTIONS_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            internalView.agreeDeclareClosure = {
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
            
            self.internalView.snp.updateConstraints { (make) in
                make.top.equalTo(self.bannerView.snp.bottom).offset(6)
            }
        }
        
    }
    
    func setPurchaseButtonEnable(_ isEnable: Bool) {
        self.purchaseButton.isEnabled = isEnable
    }

    @objc func purchaseButtonEvent() {
        
        if internalView.hasReadDeclares {
            commitApplyPurcahseData()
        } else {
            networkingHUD.showMessage(YXLanguageUtility.kLang(key: "ipo_ecm_read_statement"), in: self.view, hideAfter: 2.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "newStock_internal_placement")
        navigationItem.rightBarButtonItems = [messageItem]
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(bannerView)
        scrollView.addSubview(internalView)
        self.view.addSubview(lineView)
        self.view.addSubview(totalLabel)
        self.view.addSubview(purchaseButton)
       
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
        self.initTotalPurchaseLabelDataWithAmount(amount: 0.0)
        
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
        
        internalView.snp.makeConstraints { (make) in
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
    
    lazy var internalView: YXNewStockInternalSubsView = {
        let view = YXNewStockInternalSubsView()
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

    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        return view
    }()
}


extension YXNewStockECMPurchaseVC {
    
    func bindViewModel() {
        
        
        viewModel.groupOberver.subscribe (onNext: { [unowned self] (result) in
            self.viewModel.hudSubject.onNext(.hide)
            
            var msgArray: [String] = []
        
            result.forEach({ (isSuccess, msg) in
                if let message = msg, message.count > 0 {
                    msgArray.append(message)
                }
            })
            
            if msgArray.count >= 1  {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
            
            if self.isFirstLoad {
                self.isFirstLoad = false
                self.setPurchaseButtonEnable(false) //优先执行
                //国际配售，初始时总金额置为0.0
        
                if let model = self.viewModel.ecmModel {
                    self.internalView.refreshUI(model: model, sourceParams: self.viewModel.sourceParam, availbleAmount: self.viewModel.availableAmount)
                } else {
                    self.internalView.refreshEmptyView(availbleAmount: self.viewModel.availableAmount, sourceParams: self.viewModel.sourceParam)
                }
            } else {
                self.internalView.initAvailableAmountData(self.viewModel.availableAmount)
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
        viewModel.services.request(.ecmOrderInfo(ipoId: ipoid), response: self.viewModel.ecmResponse).disposed(by: rx.disposeBag)
    }
    
    func requestAvailbaleAmount() {
        viewModel.services.request(.accountInfo(moneyType: viewModel.sourceParam.moneyType), response: (viewModel.availbleAmountResponse)).disposed(by: rx.disposeBag)
    }

    // 请求更改认购股数或者购买股票
    func commitApplyPurcahseData() {
        
        if let text = self.internalView.textField.text, let amount = Double(text) {
            self.viewModel.sourceParam.applied_amount = amount
        }
        
        self.viewModel.sourceParam.shared_applied = self.internalView.caculateStocks
        //服务器需要的是输入金额，不是总金额
        self.viewModel.navigator.push(YXModulePaths.newStockSignature.url, context: self.viewModel.sourceParam)
    }

}

extension YXNewStockECMPurchaseVC {


    func initTotalPurchaseLabelDataWithAmount(amount: Double) {

        var unitString = self.viewModel.unitString
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
