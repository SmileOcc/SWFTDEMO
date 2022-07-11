//
//  YXNewStockIPOPurchaseVC.swift
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

class YXNewStockIPOPurchaseVC: YXHKViewController, ViewModelBased, HUDViewModelBased {

    var viewModel: YXNewStockIPOPurchaseViewModel! = YXNewStockIPOPurchaseViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindHUD()
        initUI()
        initClosures()
        bindViewModel()
        viewModel.hudSubject.onNext(.loading(nil, false))
        
        YXUserManager.getProOrderWithComplete {
            self.showProWithTip(tip: YXUserManager.shared().proOrderTip)
        }
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
            
            //认购费用说明
            detailView.purchaseFeeClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_SUBSCRIBE_FEE_INSTRUCTIONS_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            //新股认购说明
            detailView.purchaseDeclareClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_SUBSCRIBE_INSTRUCTIONS_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            //认购金额
            detailView.purchaseButtonClosure = {
                [unowned self] in
                if self.viewModel.model != nil && self.purchaseQtyView.qtyAndCharges.count > 0 {
                    self.purchaseQtyView.applyType = self.detailView.applyType
                    self.purchaseQtyView.show()
                }
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
            
            //了解更多
            detailView.seeMoreClosure = {
                [weak self] in
                guard let `self` = self else { return }
                
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_FINANCE_SUBSCRIBE_URL()
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
            
            //切换模式改变档位
            detailView.changeOptionClosure = {
                [weak self] in
                guard let `self` = self else { return }
                //切换档位到第一档
                self.purchaseQtyView.resetToFirst()
            }
        }

        //认购股数选择回调
        purchaseQtyView.selectBlock = {
            [weak self] model in
            guard let strongSelf = self else { return }
            //更新认购金额
            strongSelf.detailView.refreshPurchaseSelectedData(qtyModel: model)
   
            //更新总金额
            strongSelf.initTotalPurchaseLabelDataWithAmount(amount: strongSelf.detailView.totalAmount)
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
            commitApplyPurcahseData()
        } else {
            networkingHUD.showMessage(String(format: "%@《%@》", YXLanguageUtility.kLang(key: "newStock_read_click"), YXLanguageUtility.kLang(key: "newStock_purchase_instruction1")), in: self.view, hideAfter: 2.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "newStock_public_subscription")
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
        self.initTotalPurchaseLabelDataWithAmount(amount: 0.0)
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
            make.top.equalTo(self.strongNoticeView.snp.bottom)
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
        
        strongNoticeView.selectedBlock = {
            [weak self] in
            guard let `self` = self else { return }
            //高级账户介绍落地页
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_USERCENTER_PRO_INTRO("Notice_PRO-IPO3_HK")]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

        }
        
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = QMUITheme().foregroundColor()
        scrollview.delaysContentTouches = false
        return scrollview
    }()
    
    lazy var detailView: YXNewStockPurcahseView = {
        let view = YXNewStockPurcahseView()
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


extension YXNewStockIPOPurchaseVC {
    
    func showProWithTip(tip: String) {

        if self.viewModel.model?.financingAccountDiff == 1 && tip.count > 0 && YXUserManager.shared().curLoginUser?.userRoleType == YXUserRoleType.common{
            
            let noticeModel = YXNoticeModel(msgId: 0, title: "", content: tip, pushType: YXPushType.none, pushPloy: "", msgType: 0, contentType: 0, startTime: 0, endTime: 0, createTime: 0, newFlag: 0)
            self.strongNoticeView.dataSource = [noticeModel]
            self.strongNoticeView.noticeType = .custom
        } else {
            self.strongNoticeView.dataSource = []
        }
    }
    
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
                    
                    if let model = self.viewModel.model {
                        self.detailView.refreshUI(model: model, sourceParams: self.viewModel.sourceParam, availbleAmount: self.viewModel.availableAmount)
                        if let array = model.qtyAndCharges {
                            array.forEach({ (obj) in
                                obj.moneyType = model.moneyType
                                obj.availableAmount = self.viewModel.availableAmount
                            })
                            let financeModify = self.viewModel.sourceParam.isModify == 1 && self.viewModel.sourceParam.applyType == .financingSubs
                            self.purchaseQtyView.setQtyAndCharges(qtyAndCharges: array, financeModify: financeModify)
                        }
                    } else {
                        self.detailView.refreshEmptyView(availbleAmount: self.viewModel.availableAmount, sourceParams: self.viewModel.sourceParam)
                    }
                    self.initTotalPurchaseLabelDataWithAmount(amount: self.detailView.totalAmount)
            } else {
                if let model = self.viewModel.model {
                    self.detailView.initAvailableAmountData(self.viewModel.availableAmount)
                    if let array = model.qtyAndCharges {
                        array.forEach({ (obj) in
                            obj.moneyType = model.moneyType
                            obj.availableAmount = self.viewModel.availableAmount
                        })
                        let financeModify = self.viewModel.sourceParam.isModify == 1 && self.viewModel.sourceParam.applyType == .financingSubs
                        self.purchaseQtyView.setQtyAndCharges(qtyAndCharges: array, financeModify: financeModify)
                    }
                }
            }
            
            self.showProWithTip(tip: YXUserManager.shared().proOrderTip)

        }).disposed(by: rx.disposeBag)
        
        // 购买或改单回调
        viewModel.applySubject.subscribe(onNext: {
            [weak self] (msg, state) in
            guard let `self` = self else { return }

            if msg.count > 0  {
                self.networkingHUD.showMessage(msg, in: self.view, hideAfter: 2.0 )
            }

            if state == 0 {

                var interval: TimeInterval = 1.5
                if msg.isEmpty {
                    interval = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: {
                    let type: YXExchangeType = YXExchangeType.currentType(self.viewModel.model?.exchangeType)
                    self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
                })
            } else if state == 1 {
                YXUserUtility.validateTradePwd(inViewController: self, successBlock: {
                    [weak self] (_) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        
                        self.commitApplyPurcahseData()
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
        requestIPOInfo(ipoid)
    }

    func requestIPOInfo(_ ipoid: Int64) {
         viewModel.services.request(.ipoInfo(exchangeType: viewModel.sourceParam.exchangeType, ipoId: ipoid, stockCode: viewModel.sourceParam.stockCode), response: (self.viewModel.resultResponse)).disposed(by: rx.disposeBag)
    }
    
    func requestAvailbaleAmount() {
        viewModel.services.request(.accountInfo(moneyType: viewModel.sourceParam.moneyType), response: (viewModel.availbleAmountResponse)).disposed(by: rx.disposeBag)
    }

    // 请求更改认购股数或者购买股票
    func commitApplyPurcahseData() {
        
        if self.detailView.applyType == .cashSubs {
            if viewModel.availableAmount >= detailView.totalAmount {
                tradeToApplyPurchase()
            } else {
                showAmountNotEnoughView()
            }
        } else {
            if viewModel.availableAmount >= detailView.financeSubsTotalAmount() {
                tradeToApplyPurchase()
            } else {
                showAmountNotEnoughView()
            }
        }
    }
    
    func tradeToApplyPurchase() {
        //判断有无设置交易密码
        if let hasTrade = YXUserManager.shared().curLoginUser?.tradePassword, hasTrade == true {
            viewModel.hudSubject.onNext(.loading(nil, false))
            applyPurchase(type: viewModel.sourceParam.isModify)
        } else {
            //没有设置交易密码 -> 设置交易密码
            YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    guard let `self` = self else { return }
                    
                    // 交易密码设置成功
                    self.viewModel.hudSubject.onNext(.loading(nil, false))
                    self.applyPurchase(type: self.viewModel.sourceParam.isModify)
                })
            }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: true, needToken: false)
        }
    }
    
    func applyPurchase(type: Int) {
        
        var cash: String = ""
        var applyType = YXNewStockSubsType.cashSubs.rawValue
        if self.detailView.applyType == .financingSubs, let text = self.detailView.textField.text, let _ = Double(text) {
            cash = text
            applyType = YXNewStockSubsType.financingSubs.rawValue
        }
        if type == 1 { //更改认购
            viewModel.services.request(.modifyIpo(actionType: 0, applyId: viewModel.sourceParam.applyId, applyQuantity: detailView.amount, cash: cash), response: (viewModel.applyResponse)).disposed(by: rx.disposeBag)
        } else {
            //购买股票
            if let ipoId = Int64(viewModel.sourceParam.ipoId) {
                viewModel.services.request(.applyIpo(applyQuantity: detailView.amount, applyType: applyType, ipoId: ipoId, cash: cash), response: (viewModel.applyResponse)).disposed(by: rx.disposeBag)
            }
        }
    }
}

extension YXNewStockIPOPurchaseVC {

    func showAmountNotEnoughView() {
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "newStock_certified_funds_short"), message: nil, prompt: nil, style: .default)
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { _ in }))
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "newStock_save_cash"), style: .default, handler: { [weak self](action) in
            guard let `self` = self else { return }

            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_DEPOSIT_URL()
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }))
        alertView.addCustomView(self.setUpAlertContentView(applyType: self.detailView.applyType))
        alertView.showInWindow()
    }
    
    //applyType  1-现金认购， 2-融资认购
    func setUpAlertContentView(applyType: YXNewStockSubsType) -> UIView {
        let view = UIView()
        let viewWidth: CGFloat = 285
        let labelHeight: CGFloat = 24
        var titles: [String] = []
        var values: [String] = []
        var unitString: String = YXToolUtility.moneyUnit(2)
        if let moneyType = self.viewModel.model?.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        if applyType == .cashSubs {
            
            titles = [YXLanguageUtility.kLang(key: "newStock_total_purechase"),
                      YXLanguageUtility.kLang(key: "newStock_certified_funds"),
                      YXLanguageUtility.kLang(key: "newStock_funds_balance")]
            
            values.append(String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(detailView.totalAmount), unitString))
            values.append(String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(viewModel.availableAmount), unitString))
            values.append( String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(detailView.totalAmount - viewModel.availableAmount), unitString))

        } else {
            
            titles = [YXLanguageUtility.kLang(key: "newStock_use_availble_cash"),
                      YXLanguageUtility.kLang(key: "newStock_finance_interest"),
                      YXLanguageUtility.kLang(key: "newStock_certified_funds"),
                      YXLanguageUtility.kLang(key: "newStock_funds_balance")]
            
            values.append(String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(detailView.financeSubsInputAmount()), unitString))
            values.append(String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(detailView.financeInterestAmount), unitString))
            values.append(String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(viewModel.availableAmount), unitString))
            values.append( String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(detailView.financeSubsTotalAmount() - viewModel.availableAmount), unitString))
        }
        view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: CGFloat(titles.count) * labelHeight)
        for (index, keyText) in titles.enumerated() {
            let keyLabel = UILabel()
            keyLabel.textColor = QMUITheme().textColorLevel1()
            keyLabel.font = UIFont.systemFont(ofSize: 12)
            view.addSubview(keyLabel)
            keyLabel.text = keyText
            
            let valueLabel = UILabel()
            valueLabel.textColor = QMUITheme().textColorLevel1()
            valueLabel.font = UIFont.systemFont(ofSize: 12)
            if index == titles.count - 1 {
                valueLabel.textColor = QMUITheme().themeTextColor()
            }
            view.addSubview(valueLabel)
            valueLabel.text = values[index]
            
            keyLabel.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(16)
                make.height.equalTo(24)
                make.width.lessThanOrEqualTo(180)
                make.top.equalToSuperview().offset(24 * index)
            })
            
            valueLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(keyLabel.snp.centerY)
                make.height.equalTo(24)
                make.right.equalToSuperview().offset(-16)
            })
        }
        return view
    }
    
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
