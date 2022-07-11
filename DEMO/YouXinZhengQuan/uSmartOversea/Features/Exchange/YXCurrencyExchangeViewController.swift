//
//  YXCurrencyExchangeViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YXKit
import TYAlertController

/*
 class type: 货币类型
 description: YXCurrencyType 和 YXCurrencyExchangeModel的属性sourceCurrency、targetCurrency 字符串数字是对应的
 // moneyType: 币种 0：CNH 1:USD 2:HKD
 */
@objc enum YXCurrencyType : Int {
    case sg = 0
    case us = 1
    case hk = 2
    case none = 3
}

extension YXCurrencyType {
    func name() -> String {
        switch self {
        case .sg:
            return YXLanguageUtility.kLang(key: "common_sg_dollar")
        case .us:
            return YXLanguageUtility.kLang(key: "common_us_dollar")
        case .hk:
            return YXLanguageUtility.kLang(key: "common_hk_dollar")
        default:
            return YXLanguageUtility.kLang(key: "order_all_currency")
        }
    }

    func iconName() -> String {
        switch self {
        case .sg:
            return "sg_logo"
        case .us:
            return "us_logo"
        case .hk:
            return "hk_logo"
        default:
            return ""
        }
    }

    var requestParam: String {
        switch self {
        case .sg:
            return "SGD"
        case .us:
            return "USD"
        case .hk:
            return "HKD"
        case .none:
            return ""
        }
    }

    static func currenyType(_ curreny: String) -> YXCurrencyType {
        switch curreny {
        case "SGD":
            return .sg
        case "USD":
            return .us
        case "HKD":
            return .hk
        default:
            return .none
        }
    }
}

class YXCurrencyExchangeViewController: YXHKViewController, HUDViewModelBased {

    var sourceCurrency: YXCurrencyType = .sg
    
    var targetCurrency: YXCurrencyType = .hk
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXCurrencyExchangeViewModel!
    
    var model: YXCurrencyExchangeModel?
    var timer: Timer?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = QMUITheme().backgroundColor()
        return scrollView
    }()
    
    lazy var exchangeView: YXTradeExchangeView = {
        let exchangeView = YXTradeExchangeView(frame: .zero, market: self.viewModel.market)
        return exchangeView
    }()
    
    lazy var currencyView: YXTradeCurrencyView = {
        let currencyView = YXTradeCurrencyView(frame: .zero, market: self.viewModel.market)
        return currencyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = QMUITheme().blockColor()

        if self.viewModel.market.lowercased().elementsEqual(YXMarketType.HK.rawValue) {
            self.sourceCurrency = .hk
            self.targetCurrency = .us
        } else if self.viewModel.market.lowercased().elementsEqual(YXMarketType.US.rawValue) {
            self.sourceCurrency = .us
            self.targetCurrency = .hk
        } else {
            self.sourceCurrency = .sg
            self.targetCurrency = .hk
        }
        
        initUI()
        
        initClosures()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.timer == nil {
            // 固定 10s 一次
            let interval = TimeInterval(10)
            self.timer = Timer.init(timeInterval: interval, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
            if let timer = self.timer {
                RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            }
        } else {
            self.timer?.fireDate = Date.distantPast
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        self.loadData(showLoading: true, applyAmount: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.timer?.invalidate()
        self.timer = nil
    }

    
    @objc func timerAction(_ timer:Timer) -> Void {
        self.loadData(showLoading: false, applyAmount: false)
    }
    
    func initClosures() {
        // 更新汇率
        self.exchangeView.refreshClosure = { [weak self] in
            guard let `self` = self else { return }
            
            self.loadData(showLoading: true, applyAmount: false)
        }
        
        // 进入历史记录
        self.exchangeView.exchangeListClosure = { [weak self] in
            guard let `self` = self else { return }
            
            let context = YXNavigatable(viewModel: YXHistoryViewModel(bizType: .Exchange))
            self.viewModel.navigator.push(YXModulePaths.history.url, context: context)
        }
        
        
        //MARK: 切换市场
        self.currencyView.exchangeMarketClosure = { [weak self] in
            guard let `self` = self else { return }
            let temp = self.targetCurrency
            self.targetCurrency = self.sourceCurrency
            self.sourceCurrency = temp
            self.exchangeView.initData(with: self.sourceCurrency, target: self.targetCurrency)
            self.currencyView.didSelect(with: self.sourceCurrency, target: self.targetCurrency)
            self.loadData(showLoading: true, applyAmount: false)
        }
        self.currencyView.selectCurrencyClosure = {[weak self] (index,currencyType) in
            guard let `self` = self else { return }
            
            ////获取当前的货币表示（1:新币、2:美元、3:港币）
            let currencyNum = 3
            let whiteViewHeight = 52 + CGFloat(currencyNum * 52) + 8 + 52

            let rect = CGRect(x: 0.0, y: 0, width: YXConstant.screenWidth, height: whiteViewHeight)
            let currencyAlertView = YXCurrencyExchangeAlertView(
                frame: rect,
                currencyType: currencyType,
                title: index == 1 ? YXLanguageUtility.kLang(key: "exchange_from") : YXLanguageUtility.kLang(key: "exchange_to")
            )

            let alertVC = QMUIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            alertVC.sheetHeaderBackgroundColor = .clear
            alertVC.isExtendBottomLayout = true
            alertVC.sheetCancelButtonMarginTop = 0
            alertVC.addCustomView(currencyAlertView)
            alertVC.showWith(animated: true)

            currencyAlertView.didSelected = { [weak alertVC, weak self] currencyType in
                guard let `self` = self else { return }
                if currencyType != .none { //【取消】
                    //index:  1---左边 ，2---右边
                    switch currencyType {
                    case .sg: //sg
                        self.resetSourceTarget(with: index, selected: .sg)
                    case .us://us
                        self.resetSourceTarget(with: index, selected: .us)
                    case .hk://hk
                        self.resetSourceTarget(with: index, selected: .hk)
                    default:
                        break
                    }
                    self.exchangeView.initData(with: self.sourceCurrency, target: self.targetCurrency)
                    self.currencyView.didSelect(with: self.sourceCurrency, target: self.targetCurrency)
                    self.loadData(showLoading: true, applyAmount: false)
                }
                alertVC?.hideWith(animated: true)
            }
        }
        
        //MARK: 货币兑换 的响应
        //弹出【兑换确认】
        self.exchangeView.applyExchangeEvent = { [weak self] (amount) in
            guard let `self` = self else { return }
            self.trackViewClickEvent(name: "Confirm_Tab")
            self.showExchangeEnsureAlert(with: amount)
        }
        
        self.exchangeView.refreshData = { [weak self] in
            guard let `self` = self else { return }
            
            self.loadData(showLoading: true, applyAmount: true)
        }
        
        self.exchangeView.applyExchangeClosure = { [weak self] (amount) in
            guard let `self` = self else { return }
            self.verifyTradePassword(amount: amount)
        }
    }
    
    //重置source 和 target
    private func resetSourceTarget(with direction:Int, selected: YXCurrencyType) {
        var notChange = self.targetCurrency //修改了左边，就用右边的币种和左边的去比较
        if direction == 2 {
            notChange = self.sourceCurrency
        }
        if notChange == selected {
            let temp = self.targetCurrency
            self.targetCurrency = self.sourceCurrency
            self.sourceCurrency = temp
        } else {
            if direction == 1 {
                self.sourceCurrency = selected
            }
            else if direction == 2 {
                self.targetCurrency = selected
            }
        }
    }
    
    func initUI() {
        self.strongNoticeView.isCurrencyExchange = true
        
        self.title = YXLanguageUtility.kLang(key: "exchange_title")
        
        let serviceItem = UIBarButtonItem.qmui_item(with: UIImage(named: "service") ?? UIImage(), target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [serviceItem]
        
        serviceItem.rx.tap.bind {[weak self] in
//            self?.serviceAction()
            
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_HELP_URL())
            }.disposed(by: disposeBag)
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.strongNoticeView.snp.bottom)
        }
        
        self.scrollView.addSubview(self.currencyView)
        self.currencyView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.scrollView)
            make.width.equalTo(YXConstant.screenWidth)
            make.height.equalTo(72)
        }

        self.scrollView.addSubview(self.exchangeView)
        self.exchangeView.snp.makeConstraints { (make) in
            make.left.equalTo(self.scrollView)
            make.width.equalTo(YXConstant.screenWidth)
//            make.height.equalTo(348 + 50)
            make.top.equalTo(self.currencyView.snp.bottom).offset(12)
//            make.bottom.equalTo(self.scrollView.snp.bottom)
            make.bottom.equalTo(self.view.bottom)
        }
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func bindViewModel() {
        self.bindHUD()
        //MARK: 监听market
        self.viewModel.rx.observe(String.self, "market").subscribe(onNext: { [weak self] (market) in
            guard let `self` = self else { return }

            if market == YXMarketType.HK.rawValue {
                self.sourceCurrency = .hk
                self.targetCurrency = .us
            }
            else if market == YXMarketType.US.rawValue {
                self.sourceCurrency = .us
                self.targetCurrency = .hk
            }
            else {
                self.sourceCurrency = .sg
                self.targetCurrency = .hk
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func loadData(showLoading: Bool, applyAmount: Bool) {
        if showLoading {
            self.viewModel.hudSubject.onNext(.loading("", false))
        }
        /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
        -> 面向换汇 -> init-currency-exchange-page/v1
        换汇申请页面初始化信息 */
        self.viewModel.services.tradeService.request(.currencyExchange(self.sourceCurrency.requestParam, targetCurrency: self.targetCurrency.requestParam), response: { [weak self] (response) in
            guard let `self` = self else { return }
            if showLoading {
                self.viewModel.hudSubject.onNext(.hide)
            }
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    if let model = result.data {
                        self.model = model
                        self.exchangeView.exchangeModel = model
                        if applyAmount {
                            self.exchangeView.applyAmountData()
                        }
                    }
                default:
                    self.viewModel.hudSubject.onNext(.error(result.msg, false))
                }
            case .failed(_):
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
            } as YXResultResponse<YXCurrencyExchangeModel>).disposed(by: self.disposeBag)
    }

    ///提交换汇
    func commitCurrencyExchange(amount: String) {
        self.viewModel.hudSubject.onNext(.loading("", false))
        
        /* http://jy-dev.yxzq.com/stock-capital-server/doc/doc.html
        -> 面向换汇 -> apply-currency-exchange/v1
        申请兑换币种 */
        self.viewModel.services.tradeService.request(.applyCurrencyExchange(amount, sourceMoneyType: self.sourceCurrency.requestParam, targetMoneyType: self.targetCurrency.requestParam), response: { [weak self] (response) in
            guard let `self` = self else { return }
            
            self.viewModel.hudSubject.onNext(.hide)
            
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    self.showAlertView(
                        withTitle: YXLanguageUtility.kLang(key: "common_submit_success"),
                        message: nil,
                        actionTitle: YXLanguageUtility.kLang(key: "common_ok"),
                        isPush: true
                    )

                    self.exchangeView.currencyText.textField.resignFirstResponder()
                    self.exchangeView.targetText.textField.resignFirstResponder()

                case .tradePwdInvalid?: //交易密码失效
                    self.showPwdView(with: amount)
                case .overMaxLPD?:
                    let message = YXLanguageUtility.kLang(key: "exchange_over")
                    self.showAlertView(
                        withTitle: nil,
                        message: message,
                        actionTitle:YXLanguageUtility.kLang(key: "common_iknow"),
                        isPush: false
                    )
                default:
                    self.viewModel.hudSubject.onNext(.error(result.msg, false))
                }
            case .failed(_):
                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
            }
            } as YXResultResponse<YXNoticeResponseModel>).disposed(by: self.disposeBag)
    }
    
    ///验证交易密码
    func verifyTradePassword(amount: String) {
        if YXUserManager.shared().curLoginUser?.tradePassword ?? false {
            self.showPwdView(with: amount)
        } else {
            ///彈出沒有設置交易密碼的對話框
            YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { [weak self] (_) in
                guard let `self` = self else { return }
                
                self.commitCurrencyExchange(amount: amount)
                }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: true, needToken: false)
        }
    }
    
    //展示【兑换确认】的弹框
    private func showExchangeEnsureAlert(with amount: String) {
        let viewHeight:CGFloat = 315
        let ensureFrame = CGRect(x: 45.0, y: 0.0, width: UIScreen.main.bounds.width - 90, height: viewHeight)
        let ensureAlertView = YXTradeExchangeEnsureAlertView(frame: ensureFrame, sourceType: self.sourceCurrency, targetType: self.targetCurrency, model: self.model, inputText: amount)
        
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewHeight))
        baseView.addSubview(ensureAlertView)
        
        let alertVc = TYAlertController(alert: baseView, preferredStyle: .alert, transitionAnimation: .scaleFade)
        alertVc!.backgoundTapDismissEnable = true
        alertVc?.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        ensureAlertView.didSelected = { [weak alertVc, weak self] (isEnsure) in
            
            alertVc?.dismissViewController(animated: true)
            
            guard let `self` = self else { return }
            
            if isEnsure {
                self.loadData(showLoading: true, applyAmount: true)
            }
        }
        
        self.present(alertVc!, animated: true, completion: nil)
    }
    /// 展示密码输入view
    func showPwdView(with amount: String) {
        /// 驗證交易密碼
        YXUserUtility.validateTradePwd(inViewController: self, successBlock: {
            [weak self] (_) in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                self.commitCurrencyExchange(amount: amount)
            })
            }, failureBlock: nil, isToastFailedMessage: nil)
    }

    func showAlertView(withConfirmAction message: String?, amount: String?) {
        let alertView = YXAlertView(title: nil, message: message, prompt: nil, style: .default)
        alertView.clickedAutoHide = false
        let alertController = YXAlertController(alert: alertView)!
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] action in
            guard let `alertView` = alertView else { return }
            
            alertView.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak alertView, weak self, weak alertController] action in
            guard let `alertView` = alertView else { return }
            alertController?.dismissComplete = {
                guard let `self` = self else { return }
                if let amount = amount {
                    self.verifyTradePassword(amount: amount)
                }
            }
            alertView.hide()
        }))
        
        UIViewController.current().present(alertController, animated: true)
    }

    func showAlertView(withTitle title: String?, message: String?, actionTitle: String?, isPush: Bool) {
        let alertView = YXAlertView(title: title, message: message, prompt: nil, style: .default)
        alertView.addAction(YXAlertAction(title: actionTitle ?? "", style: .default, handler: { [weak self, weak alertView] action in
            guard let `alertView` = alertView else { return }
            guard let `self` = self else { return }
            
            alertView.hide()
            if isPush == true {
                let context = YXNavigatable(viewModel: YXHistoryViewModel(bizType: .Exchange))
                self.viewModel.navigator.push(YXModulePaths.history.url, context: context)
            }
        }))
        
        alertView.showInWindow()
    }
    
    override var pageName: String {
        "Currency Exchange"
    }
}
