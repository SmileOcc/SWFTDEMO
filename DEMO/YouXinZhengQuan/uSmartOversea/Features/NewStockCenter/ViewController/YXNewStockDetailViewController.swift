//
//  YXNewStockDetailViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXNewStockDetailViewController: YXHKTableViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXNewStockDetailViewModel! = YXNewStockDetailViewModel()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var exchangeType: Int = 0
    var ipoId: Int64? = 0
    var stockCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "newStock_purchase_detail_title")
        initUI()
        bindHUD()
        bindViewModel()
        initClosures()
        addRereshHeader()
        addFocusToServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerRereshing()
        // 神策事件：开始记录
        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    func initUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()
        
        navigationItem.rightBarButtonItems = [messageItem]
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.tableHeaderView = tableHeaderView
        tableView.register(YXStockDetailArticleCell.self, forCellReuseIdentifier: NSStringFromClass(YXStockDetailArticleCell.self))
        
        tableHeaderView.addSubview(bannerView)
        bannerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(0)
        }
        
        tableHeaderView.addSubview(purchaseView)
        purchaseView.snp.makeConstraints { (make) in
            make.left.equalTo(tableHeaderView.snp.left).offset(18)
            make.width.equalTo(YXConstant.screenWidth - 36)
            make.top.equalTo(bannerView.snp.bottom).offset(0)
            make.height.equalTo(224)
        }
        
        tableHeaderView.addSubview(stockInfoView)
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalTo(tableHeaderView.snp.left).offset(18)
            make.width.equalTo(YXConstant.screenWidth - 36)
            make.top.equalTo(purchaseView.snp.bottom).offset(40)
            make.height.equalTo(340)
        }
        
        tableHeaderView.addSubview(introduceTitleLabel)
        introduceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tableHeaderView.snp.left).offset(18)
            make.width.equalTo(YXConstant.screenWidth - 36)
            make.top.equalTo(stockInfoView.snp.bottom).offset(30)
        }
        
        tableHeaderView.addSubview(introduceLabel)
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tableHeaderView.snp.left).offset(18)
            make.width.equalTo(YXConstant.screenWidth - 36)
            make.top.equalTo(introduceTitleLabel.snp.bottom).offset(14)
        }
        
        view.addSubview(shadowBgView)
        shadowBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(48 + 14 + (YXConstant.deviceScaleEqualToXStyle() ? YXConstant.tabBarPadding() : 10))
            make.bottom.equalToSuperview()
        }
        shadowBgView.isHidden = true
        
        view.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
        }
        purchaseButton.isHidden = true
        
        view.addSubview(ipoPurchaseButton)
        view.addSubview(ecmPurchaseButton)
        ipoPurchaseButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset((YXConstant.deviceScaleEqualToXStyle() ? -YXConstant.tabBarPadding() : -10))
            make.width.equalTo(uniSize(161))
        }
        
        ecmPurchaseButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset((YXConstant.deviceScaleEqualToXStyle() ? -YXConstant.tabBarPadding() : -10))
            make.width.equalTo(uniSize(161))
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(purchaseButton.snp.top)
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
    }
    
    override func layoutTableView() {
        
    }
    
    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 630)
        return view
    }()
    
    lazy var purchaseView: YXNewStockDetailPurchaseView = {
        let view = YXNewStockDetailPurchaseView()
        view.exchangeType = YXExchangeType.currentType(self.exchangeType)
        return view
    }()
    
    lazy var stockInfoView: YXNewStockDetailInfoView = {
        let view = YXNewStockDetailInfoView()
        return view
    }()
    
    lazy var introduceTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_detail_introduce")
        label.isHidden = true
        return label
    }()
    
    lazy var introduceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var purchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.setDisabledTheme(0)
        return button
    }()
    
    lazy var ipoPurchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_public_subscription"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.setDisabledTheme(6)
        button.titleLabel?.numberOfLines = 0
        button.isHidden = true
        return button
    }()
    
    lazy var ecmPurchaseButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_internal_placement"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.setDisabledTheme(6)
        button.titleLabel?.numberOfLines = 0
        button.isHidden = true
        return button
    }()
    
    lazy var shadowBgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 6.0
        return view
    }()
    
    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        return view
    }()
    
    override func viewDidLayoutSubviews() {
        
    }
}

extension YXNewStockDetailViewController {
    
    func initClosures() {
        purchaseView.pdfClosure = {
            [weak self] pdfString in
            guard let `self` = self else { return }
            if pdfString.count > 0 {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: pdfString]
                let webModel = YXWebViewModel(dictionary: dic)
                 webModel.webTitle = YXLanguageUtility.kLang(key: "newStock_detail_stockpdf")
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: webModel)
            }
        }
        
        purchaseView.stockDetailClosure = {
            [weak self] (exchangeType, symbol, name) in
            guard let `self` = self else { return }

            let input = YXStockInputModel()
            input.market = (exchangeType == 5) ? YXMarketType.US.rawValue : YXMarketType.HK.rawValue
            input.symbol = symbol
            input.name = name
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }
        
        purchaseView.expanseClosure = {
            [weak self]  in
            guard let `self` = self else { return }
            
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.NEW_STOCK_SUBSCRIBE_FEE_INSTRUCTIONS_URL()]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        
        purchaseView.refreshHeightClosure = {
            [weak self] externHeight in
            guard let `self` = self else { return }
            self.purchaseView.snp.updateConstraints { (make) in
                make.height.equalTo(224 + externHeight)
            }
            self.refreshTableHeaderView()
        }
        
        purchaseView.moreButtonClosure = {
            [weak self] url in
            guard let `self` = self else { return }
            if YXGoToNativeManager.shared.schemeHasPrefix(string: url) {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: url)
            } else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }
        
        bannerView.requestSuccessBlock = {
            [weak self]  in
            guard let `self` = self else { return }
            let bannerWidth = self.view.frame.width - 18 * 2
            let bannerHeight = bannerWidth/4.0 //4:1
            self.bannerView.snp.updateConstraints { (make) in
                make.height.equalTo(bannerHeight)
            }
            
            self.purchaseView.snp.updateConstraints { (make) in
                make.top.equalTo(self.bannerView.snp.bottom).offset(18)
            }
            self.refreshTableHeaderView()
        }
    }
    
    func refreshTableHeaderView() {
        self.tableHeaderView.setNeedsUpdateConstraints()
        self.tableHeaderView.layoutIfNeeded()
        if self.introduceTitleLabel.isHidden == false {
            self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.introduceLabel.frame.maxY + 30)
        } else {
            self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.stockInfoView.frame.maxY + 25)
        }
        self.tableView.tableHeaderView = self.tableHeaderView
    }
    
    func bindViewModel() {
        purchaseButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [unowned self] (_) in
                self.handlePurchaseButtonEvent()
            }).disposed(by: rx.disposeBag)
        
        ipoPurchaseButton.rx.controlEvent(.touchUpInside)
        .subscribe(onNext: { [unowned self] (_) in
            //未认购 ---> 立即认购（剩余X天）
            if let model = self.viewModel.model {
                let applyType: YXNewStockSubsType = .cashSubs
                let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: 0, isModify: 0, shared_applied: 0, applied_amount: 0.0, moneyType: model.moneyType ?? 2, applyType: applyType, ipoType: self.purchaseView.ipoType)
                
                if self.exchangeType == YXExchangeType.hk.rawValue {
                    self.viewModel.navigator.push(YXModulePaths.newStockIPOPurchase.url, context: source)
                } else {
                    self.viewModel.navigator.push(YXModulePaths.newStockUSConfirm.url, context: source)
                }
                
            }
            
        }).disposed(by: rx.disposeBag)
        
        ecmPurchaseButton.rx.controlEvent(.touchUpInside)
        .subscribe(onNext: { [unowned self] (_) in
            
            if self.viewModel.model?.piFlag == 1, !YXUserManager.isHighWorth() {
                self.handleProfessionalAlert()
            } else {
                //未认购 ---> 立即认购（剩余X天）
                if let model = self.viewModel.model {
                    let applyType: YXNewStockSubsType = .internalSubs
                    let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: 0, isModify: 0, shared_applied: 0, applied_amount: 0.0, moneyType: model.moneyType ?? 2, applyType: applyType, ipoType: self.purchaseView.ipoType)
                    
                    self.viewModel.navigator.push(YXModulePaths.newStockECMPurchase.url, context: source)
                }
            }
       
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
                strongSelf.tableView.mj_header?.endRefreshing()
            }
            
            if isSuccess {
                strongSelf.refreshSubView()
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel.newsInfoSubject.subscribe(onNext: {
            [weak self] (isSuccess) in
            guard let strongSelf = self else { return }
            
            if strongSelf.viewModel.isPulling == true && strongSelf.tableView.mj_footer != nil {
                strongSelf.viewModel.isPulling = false
                strongSelf.tableView.mj_footer?.endRefreshing()
            }
            
            if isSuccess {
                if strongSelf.tableView.mj_footer == nil {
                    strongSelf.addRefreshFooter()
                }
                strongSelf.tableView.reloadData()
            } else {
                if strongSelf.tableView.mj_footer != nil {
                    strongSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func requestStockDetailInfo() {
        
        viewModel.hudSubject.onNext(.loading(nil, false))
        viewModel.services.request(.ipoInfo(exchangeType: self.exchangeType, ipoId: self.ipoId, stockCode: self.stockCode), response: (self.viewModel.resultResponse)).disposed(by: rx.disposeBag)
    }
    
    func addFocusToServer() {
        viewModel.services.request(.addFocus(exchangeType: self.exchangeType, ipoId: self.ipoId, stockCode: self.stockCode), response: (self.viewModel.addFocusResponse)).disposed(by: rx.disposeBag)
    }
    
    func requestNewsInfo(articleId: String) {
        if self.stockCode.count > 0 {
            let market: String = YXExchangeType.init(rawValue: self.exchangeType)?.market ?? YXExchangeType.hk.market

            viewModel.quoteService.request(.articleInfo(market + self.stockCode, articleId, 30, nil), response: (self.viewModel.newsInfoResponse)).disposed(by: rx.disposeBag)
        }
    }
    
    func refreshSubView() {
        if let model = viewModel.model {
            purchaseView.refreshUI(model)
            stockInfoView.refreshUI(model)
        }
        if let stockIntroduction = viewModel.model?.stockIntroduction, stockIntroduction.count > 0,
            let attributeText = try? NSAttributedString.init(data: stockIntroduction.data(using: String.Encoding.unicode)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil) {
            introduceLabel.attributedText = attributeText
            introduceTitleLabel.isHidden = false
            introduceLabel.isHidden = false
        }
        self.refreshTableHeaderView()
        initButtonStatus()
    }
    
    //专业投资者弹窗
    func handleProfessionalAlert() {
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "newStock_finance_declare"),message: YXLanguageUtility.kLang(key: "certification_note"), messageAlignment: .left)
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_go_back"), style: .cancel, handler: { (action) in
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "go_to_certification"), style: .default, handler: { (action) in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_PROFESSIONAL_URL()
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }))
        
        alertView.showInWindow()
    }
    
    func initButtonStatus() {
        
        purchaseButton.isHidden = false
        purchaseButton.isEnabled = false
        ipoPurchaseButton.isHidden = true
        ecmPurchaseButton.isHidden = true
        shadowBgView.isHidden = true
        
        self.viewModel.ecmType = .onlyPublic
        //先判断是否认购过
        if let applied = viewModel.model?.applied, applied == true {
            purchaseButton.isEnabled = true
            purchaseButton.setTitle(YXLanguageUtility.kLang(key: "newStock_see_purchase_list"), for: .normal)
            return
        }
        //在判断是否认购结束
        guard let model = viewModel.model, let remainingTime = viewModel.model?.remainingTime, remainingTime > 0 else {
            purchaseButton.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_purchase_end"), for: .normal)
            purchaseButton.isEnabled = false
            return
        }
        
        let serverUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.serverTime)
        let cashUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.endTime) //现金认购截止日期
        let financeUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.financingEndTime) //融资认购截止日期
        let ecmUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.ecmEndTime) //国际认购截止日期
        var subscribeWayArray: [String] = []
        //认购方式，多种认购用,隔开
        if let subscribeWay =  model.subscribeWay {
            subscribeWayArray = subscribeWay.components(separatedBy: ",")
        }
        
        let ipoStatus: YXNewStockPurcahseStatus = YXNewStockPurcahseStatus.currentStatus(viewModel.model?.status)
        let ecmStatus: YXNewStockPurcahseStatus = YXNewStockPurcahseStatus.currentStatus(viewModel.model?.ecmStatus)

        var canCash = false
        if subscribeWayArray.contains(String(YXNewStockSubsType.cashSubs.rawValue)), cashUnixTime > 0, cashUnixTime > serverUnixTime {
            canCash = true
        }

        var canFiance = false
        if subscribeWayArray.contains(String(YXNewStockSubsType.financingSubs.rawValue)), financeUnixTime > 0, financeUnixTime > serverUnixTime {
            canFiance = true
        }
        
        var canEcm = false
        if subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)), ecmUnixTime > 0, ecmUnixTime > serverUnixTime {
            canEcm = true
        }
        
        if (canFiance || canCash), canEcm, ipoStatus == .purchasing, ecmStatus == .purchasing {
            //同时存在公开认购和国际认购
            purchaseButton.isHidden = true
            ipoPurchaseButton.isHidden = false
            ecmPurchaseButton.isHidden = false
            shadowBgView.isHidden = false
            self.viewModel.ecmType = .both
            var timeString = leftTimeString(seconds: viewModel.model?.ipoRemainingTime ?? 0, endTime: viewModel.model?.publicEndTime ?? "", serverTime: viewModel.model?.serverTime ?? "")
            ipoPurchaseButton.setAttributedTitle(purhcaseButtonAttributeString(YXLanguageUtility.kLang(key: "newStock_public_subscription"), suffix: String(format: "(%@)", timeString)), for: .normal)
         
            timeString = leftTimeString(seconds: viewModel.model?.ecmRemainingTime ?? 0, endTime: viewModel.model?.ecmEndTime ?? "", serverTime: viewModel.model?.serverTime ?? "")

            ecmPurchaseButton.setAttributedTitle(purhcaseButtonAttributeString(YXLanguageUtility.kLang(key: "newStock_internal_placement"), suffix: String(format: "(%@)", timeString)), for: .normal)
        } else if (canFiance || canCash), ipoStatus == .purchasing {
            //只存在公开认购
            purchaseButton.isEnabled = true
            
            let timeString = leftTimeString(seconds: remainingTime, endTime: viewModel.model?.latestEndtime ?? "", serverTime: viewModel.model?.serverTime ?? "")
            purchaseButton.setTitle(String(format: "%@ (%@)", YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), timeString), for: .normal)
            
        } else if canEcm, ecmStatus == .purchasing {
            //只存在国际认购
            purchaseButton.isEnabled = true
            self.viewModel.ecmType = .onlyInternal
            let timeString = leftTimeString(seconds: remainingTime, endTime: viewModel.model?.latestEndtime ?? "", serverTime: viewModel.model?.serverTime ?? "")
            purchaseButton.setTitle(String(format: "%@ (%@)", YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), timeString), for: .normal)
        } else  {
            //if (canCash || canFiance || canEcm), (ipoStatus == .waited || ecmStatus == .waited)
            //都不在认购中，有一种是未开始，显示未开始， 都结束的情况在函数头remainingTime有判断
            purchaseButton.isEnabled = false
            purchaseButton.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_will_begin"), for: .normal)
        }
    }
    
    func purhcaseButtonAttributeString(_ prefix: String, suffix: String) -> NSAttributedString {
        let mutString = NSMutableAttributedString.init(string: prefix, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        mutString.append(NSAttributedString.init(string: "\n" + suffix, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 3
        mutString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraph], range: NSRange(location: 0, length: prefix.count + suffix.count))
        return mutString
    }
    
    func leftTimeString(seconds: NSInteger, endTime: String, serverTime: String) -> String {
        
        var value: Int = 0
        var timeString = YXLanguageUtility.kLang(key: "newStock_detail_purchase_now")
        if endTime.count < 10 || serverTime.count < 10 {
            return timeString
        }
        if seconds >= 24 * 3600 {
            value = 1 //默认给1天
            if serverTime.count >= 10 {
                value = YXDateToolUtility.numberOfDaysWith(fromDate: (serverTime as NSString).substring(with: NSMakeRange(0, 10)), toDate: (endTime.count >= 10 ? (endTime as NSString).substring(with: NSMakeRange(0, 10)) : endTime))
            }
            timeString = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_day_unit"))
            
        } else if seconds > 0 {
            
            if seconds >= 3600 {
                value = seconds / 3600
                timeString = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_hour"))
                
            } else if seconds < 3600, seconds >= 60 {
                value = seconds / 60
                timeString = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_minute"))
            } else {
                value = 1
                timeString = String(format: YXLanguageUtility.kLang(key: "newStock_detail_remaining"), value, YXLanguageUtility.kLang(key: "common_minute"))
            }
            
        }
        return timeString
    }
    
    func handlePurchaseButtonEvent() {
        
        if self.viewModel.ecmType == .onlyInternal, self.viewModel.model?.piFlag == 1, !YXUserManager.isHighWorth() {
            self.handleProfessionalAlert()
            return
        }
        
        if let model = self.viewModel.model {
    
            //认购已截止
            if let remainingTime = model.remainingTime, remainingTime <= 0,
                let applied = model.applied, applied == true {
                //已认购
                let type: YXExchangeType = YXExchangeType.currentType(self.viewModel.model?.exchangeType)
                self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
            } else {
                //认购中
                if YXUserManager.isLogin() {
                    //已登陆
                    if YXUserManager.canTrade() == true {
                        //已开户
                        if let applied = model.applied, applied == true {
                            //已认购  ---> 认购历史记录页面
                            let type: YXExchangeType = YXExchangeType.currentType(self.viewModel.model?.exchangeType)
                            self.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url, context: type)
                        } else {
                            //未认购 ---> 立即认购（剩余X天）
                            let applyType: YXNewStockSubsType = (self.purchaseView.ipoType == .both || self.purchaseView.ipoType == .onlyInternal) ? .internalSubs : .cashSubs
                            let source = YXPurchaseDetailParams.init(exchangeType: model.exchangeType ?? 0, ipoId: model.ipoID ?? "", stockCode: model.stockCode ?? "", applyId: 0, isModify: 0, shared_applied: 0, applied_amount: 0.0, moneyType: model.moneyType ?? 2, applyType: applyType, ipoType: self.purchaseView.ipoType)
                            
                            if self.exchangeType == YXExchangeType.hk.rawValue {
                                if applyType == .internalSubs {
                                    self.viewModel.navigator.push(YXModulePaths.newStockECMPurchase.url, context: source)
                                } else {
                                    self.viewModel.navigator.push(YXModulePaths.newStockIPOPurchase.url, context: source)
                                }
                            } else {
                                self.viewModel.navigator.push(YXModulePaths.newStockUSConfirm.url, context: source)
                            }
                            
                        }
                    } else {
                        //未开户 ---> 去开户
                        let context = YXNavigatable(viewModel: YXOpenAccountWebViewModel(dictionary: [:]))
                        self.viewModel.navigator.push(YXModulePaths.openAccount.url, context: context)
                    }
                } else {
                    //未登录
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                    self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
            }
        }
    }
    
}

extension YXNewStockDetailViewController {
    //下拉更新
    func addRereshHeader() {
        tableView.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
    }
    
    @objc func headerRereshing() {
        
        guard !self.viewModel.isRefeshing else { return }
        self.viewModel.isRefeshing = true
        requestStockDetailInfo()
        viewModel.resetNewsList = true
        requestNewsInfo(articleId: "0")
        bannerView.requestBannerInfo(.newStockDetail)
    }
    
    //上拉更新
    func addRefreshFooter() {
        tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(footerRereshing))
    }
    
    @objc func footerRereshing() {
        
        guard !self.viewModel.isPulling else { return }
        if YXNetworkUtil.sharedInstance().reachability.currentReachabilityStatus() == .notReachable {
            tableView.mj_footer?.endRefreshing()
            return
        }
        self.viewModel.isPulling = true
        if let model = viewModel.newsList.last, let articleId = model.newsId {
            requestNewsInfo(articleId: articleId)
        }
    }
}

extension YXNewStockDetailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.newsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXStockDetailArticleCell.self), for: indexPath)
        if let tableCell = cell as? YXStockDetailArticleCell, indexPath.row < viewModel.newsList.count {
            tableCell.stockArticleData = viewModel.newsList[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.qmui_heightForCell(withIdentifier: NSStringFromClass(YXStockDetailArticleCell.self), cacheBy: indexPath, configuration: { [weak self] (cell) in
            guard let strongSelf = self else { return }
            if let tableCell = cell as? YXStockDetailArticleCell, indexPath.row < strongSelf.viewModel.newsList.count {
                tableCell.stockArticleData = strongSelf.viewModel.newsList[indexPath.row]
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if viewModel.newsList.count > 0 {
            let headerView = UIView()
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 28)
            headerView.backgroundColor = QMUITheme().foregroundColor()
            
            let webTitleLabel = UILabel()
            webTitleLabel.textColor = QMUITheme().textColorLevel1()
            webTitleLabel.font = UIFont.systemFont(ofSize: 20)
            webTitleLabel.textAlignment = .left
            webTitleLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_news_title")
            
            headerView.addSubview(webTitleLabel)
            webTitleLabel.frame = CGRect(x: 18, y: 0, width: view.frame.width - 36, height: 28)
            return headerView
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.newsList.count > 0, indexPath.row < viewModel.newsList.count {
            let model = viewModel.newsList[indexPath.row]
            let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: [
                "newsId" : model.newsId ?? "",
                "type" : YXInfomationType.Normal,
                "source" : YXPropInfoSourceValue.infoStock,
                "newsTitle" : model.title ?? ""
                ]))
            self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
        }
    }
}
