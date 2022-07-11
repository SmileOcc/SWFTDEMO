//
//  YXOptionalListViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxDataSources
import NSObject_Rx

import TYAlertController

class YXOptionalListViewController: YXHKViewController, RefreshViweModelBased {
    typealias ViewModelType = YXOptionalListViewModel
    
    private var timeFlag : YXTimerFlag?
    
    var scrollCallback: YXTabPageScrollBlock?
    
    var viewModel: ViewModelType!

    var networkingHUD: YXProgressHUD = YXProgressHUD()
    var showNoticeView = false
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var gvc: YXGroupListViewController = {
        let vm = self.gvcViewModel
        let vc = YXGroupListViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services as! YXGroupManageViewModel.Services, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    lazy var gvcViewModel:YXGroupManageViewModel = {
        let vm = YXGroupManageViewModel()
        return vm
    }()
    
    lazy var headerView: YXOptionalHeaderView = {
        let headerView = YXOptionalHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 35))
        headerView.sortType.accept(viewModel.quoteType.value)
        headerView.sortState.accept(viewModel.sortState.value)
        headerView.selectButton.setTitle(defultGroupName(), for: .normal)
        headerView.selectButton.rx.tap.subscribe {[weak self] event in
            guard let `self` = self else { return }
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "market_watchlist_title")
            self.bottomSheet.showViewController(vc: self.gvc)
        }.disposed(by: disposeBag)
        return headerView
    }()
    
    
    fileprivate func defultGroupName()->String{
        var name = YXSecuGroupManager.shareInstance().allGroupsForShow.first?.name ?? ""
        
        if let groupId = YXDefaultGroupID(rawValue: YXSecuGroupManager.shareInstance().allGroupsForShow.first?.id ?? 0) {
            switch groupId {
            case .idAll:
                name = YXLanguageUtility.kLang(key: "common_all")
            case .IDHK:
                name = YXLanguageUtility.kLang(key: "community_hk_stock")
            case .IDUS:
                name = YXLanguageUtility.kLang(key: "community_us_stock")
            case .IDCHINA:
                name = YXLanguageUtility.kLang(key: "community_cn_stock")
            case .IDHOLD:
                name = YXLanguageUtility.kLang(key: "hold_holds")
            case .IDUSOPTION:
                name = YXLanguageUtility.kLang(key: "options_options")
            case .IDSG:
                name = YXLanguageUtility.kLang(key: "community_sg_stock")
            default:
                break
            }
        }
        return name
    }
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightButton.isHidden = true
       // sheet.leftButton.setTitleColor(QMUITheme().themeName(), for: .normal)
        sheet.leftButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true)
            }
        }
        return sheet
    }()
    
    var refreshFooter: YXRefreshAutoNormalFooter?
    
    override var pageName: String {
        return "Watchlists"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("YXCrossMarketDragNoti"), object: nil, queue: OperationQueue.main) { [weak self](noti) in
            self?.customButtonToastView.show(inView: self?.view)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("YXHoldSecuGroupDragNoti"), object: nil, queue: OperationQueue.main) { [weak self](noti) in
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "position_list_not_support_sort"))
            self?.tableView.reloadData()
        }
        
        headerView.sortState.skip(1).subscribe(onNext: { [weak self] (state) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sortState.accept(state)
            strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
            }).disposed(by: disposeBag)
        
        viewModel.timeLineSubject.subscribe(onNext: { [weak self] (list) in
            guard let strongSelf = self else { return }

            let secuIdList = strongSelf.viewModel.secuGroup.value?.list ?? []
            var timeLinePool = [String: YXTimeLineModel]()
            secuIdList.forEach({ (secuId) in
        
                for item in list {
                    if secuId.symbol == item.symbol && secuId.market == item.market {
                        let timeLineModel = YXTimeLineModel()
                        timeLineModel.price_base = "\(item.priceBase ?? 0)"
                        timeLineModel.market = item.market ?? ""
                        timeLineModel.delay = item.delay ?? true
                        timeLineModel.type = item.type ?? 0
                        let timeLineList =  item.data?.map({ (simpleTimeLine) -> YXTimeLineSingleModel in
                            let singleModel = YXTimeLineSingleModel()
                            singleModel.time = "\(simpleTimeLine.latestTime ?? 0)"
                            singleModel.pclose = "\(simpleTimeLine.preClose ?? 0)"
                            singleModel.price = "\(simpleTimeLine.price ?? 0)"
                            return singleModel
                        }) ?? []
                        timeLineModel.list = NSMutableArray(array: timeLineList)
                        timeLinePool[secuId.description()] = timeLineModel
                        continue
                    }
                }
            })
            var timeLineData = strongSelf.viewModel.timeLineDataSource.value
            for (key, value) in timeLinePool {
                timeLineData[key] = value
            }
            strongSelf.viewModel.timeLineDataSource.accept(timeLineData)
        }).disposed(by: disposeBag)
        
        viewModel.quoteType.asDriver().skip(1).drive(onNext: { [weak self] (type) in
            guard let strongSelf = self else { return }
            strongSelf.headerView.sortType.accept(type)
            strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
        }).disposed(by: disposeBag)
        
        viewModel.quoteSubject.subscribe(onNext: { [weak self] (list,scheme) in
            guard let strongSelf = self else { return }
            guard list.count > 0 else { return }

            var dataSource = strongSelf.viewModel.dataSource.value
            if list.count > 1 {
                let array = dataSource.map({ (quote) -> YXV2Quote in
                    for item in list {
                        if quote.symbol == item.symbol && quote.market == item.market {
                            return item
                        }
                    }
                    return quote
                })
                strongSelf.viewModel.updateOriginList(list: array)
                strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
            } else {
                var row: Int?
                guard let quote = list.first else { return }
                for index in 0 ..< dataSource.count {
                    let item = dataSource[index]
                    if item.market == quote.market, item.symbol == quote.symbol {
                        row = index
                        break
                    }
                }
                if let row = row {
                    if let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? YXOptionalListCell {
                        cell.quote.accept(quote)
                    }
                    strongSelf.viewModel.updateOriginList(list: [quote])
                    if scheme == .http {
                        strongSelf.viewModel.dataSource.accept(strongSelf.viewModel.reloadedList())
                    }
                }
            }
         
        }).disposed(by: disposeBag)
        
        initTableView()

        if let group = self.viewModel.secuGroup.value {
            if group.id == YXDefaultGroupID.idAll.rawValue ||
                group.id == YXDefaultGroupID.IDUS.rawValue ||
                group.id == YXDefaultGroupID.IDHK.rawValue {
                var market = ""
                if group.id == YXDefaultGroupID.IDUS.rawValue {
                    market = kYXMarketUS
                } else if group.id == YXDefaultGroupID.IDHK.rawValue {
                    market = kYXMarketHK
                }
                self.showNoticeView = YXQuoteKickTool.shared.isQuoteLevelKickToDelay(market)
                addQuoteKickNotification()
            }
        }
        
        gvcViewModel.secuGroup.subscribe {[weak self] secuGroup in
            guard let `self` = self,let secuGroupValue = secuGroup.element as? YXSecuGroup  else { return }
            self.bottomSheet.hide()
            var name = secuGroupValue.name
            if let groupId = YXDefaultGroupID(rawValue: secuGroupValue.id) {
                switch groupId {
                case .idAll:
                    name = YXLanguageUtility.kLang(key: "common_all")
                case .IDHK:
                    name = YXLanguageUtility.kLang(key: "community_hk_stock")
                case .IDUS:
                    name = YXLanguageUtility.kLang(key: "community_us_stock")
                case .IDCHINA:
                    name = YXLanguageUtility.kLang(key: "community_cn_stock")
                case .IDHOLD:
                    name = YXLanguageUtility.kLang(key: "hold_holds")
                case .IDUSOPTION:
                    name = YXLanguageUtility.kLang(key: "options_options")
                case .IDSG:
                    name = YXLanguageUtility.kLang(key: "community_sg_stock")
                default:
                    break
                }
            }
            self.headerView.selectButton.setTitle(name, for: .normal)
            self.gvcViewModel.selectGroup = secuGroupValue
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
            self.viewModel.secuGroup.accept(secuGroupValue)
            self.updateFootViewUI()
            self.refresh()
        }.disposed(by: disposeBag)
    }
    
    lazy var customButtonToastView: YXCustomButtonToastView = {
        let view = YXCustomButtonToastView()
        return view
    }()
    
    lazy var footerView: UIView = {
        let view = UIView()
        let line = UIView.line()
        
        view.addSubview(self.addStockView)
        view.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }

        self.addStockView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(34)
        }
        return view
    }()
    
    lazy var guideItemView: YXOpenAccountGuideItemView = {
        let view = YXOpenAccountGuideItemView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44)) {
            self.cyl_tabBarController.selectedIndex = 4;
        }
        return view
    }()
    
    lazy var addStockView: UIView = {
        return self.creatAddStockView()
    }()
    
    lazy var addStockButton: QMUIButton = {
        return addButton()
    }()
    
    lazy var importPicButton: QMUIButton = {
        return importButton()
    }()
    
    func addButton() -> QMUIButton {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "common_add_stock")
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        
        let b = QMUIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        b.setImage(UIImage(named: "add_stock_new")?.qmui_image(withTintColor: QMUITheme().textColorLevel4()), for: .normal)
        b.contentHorizontalAlignment = .right
        
        b.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        b.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            guard let secuGroup = self.viewModel.secuGroup.value else { return }
            self.trackViewClickEvent(name: "Add Stock_Tab")
            self.viewModel.navigator.present(YXModulePaths.search.url, context: ["secuGroup": secuGroup], animated: false)
        }).disposed(by: disposeBag)
        
        return b
    }
    
    func importButton() -> QMUIButton {
        let b = button()
        b.setImage(UIImage(named: "import_stock_new"), for: .normal)
        b.setTitle(YXLanguageUtility.kLang(key: "import_optional"), for: .normal)
        b.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.viewModel.navigator.push(YXModulePaths.importPic.url)
        }).disposed(by: disposeBag)
        return b
    }
    
    func button() -> QMUIButton {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "common_add_stock")
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        let button = QMUIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        button.contentHorizontalAlignment = .right
        button.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        return button
    }
    
    lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.isHidden = true
        
        label.rx.tapGesture().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (tap) in
            guard let strongSelf = self else { return }
            guard YXUserManager.hkLevel() == .hkBMP else { return }
            
            if tap.state == .ended {
                strongSelf.userAuthUpgradeAlert()
            }
        }).disposed(by: rx.disposeBag)
        
        return label
    }()
    
    func userAuthUpgradeAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "online_buy_tip"))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
        }))

        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "depth_order_get"), style: .default, handler: { (action) in
            YXWebViewModel.pushToWebVC(YXH5Urls.myQuotesUrl(tab: 2, levelType: 0))
        }))

        alertView.showInWindow()
    }
    
    //登录  、 了解详情
    lazy var loginButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.font = .systemFont(ofSize: 10)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.layer.cornerRadius = 4
        button.layer.borderColor = QMUITheme().holdMark().cgColor
        button.layer.borderWidth = 0.5
        button.isHidden = true
        return button
    }()
    
    lazy var headerTipView: UIView = {
        let view = UIView()
        var tipView: YXOptionalTipsView = YXOptionalTipsView.init(frame: CGRect.zero, type: .unLoginWhenALL)
        var h: CGFloat = 0
        if let secuGroup = viewModel.secuGroup.value, let groupId = YXDefaultGroupID(rawValue: secuGroup.id) {
            if groupId == .IDHK || groupId == .idAll || groupId == .IDUS {
                tipView = YXOptionalTipsView.init(frame: CGRect.zero, type: .unLoginWhenALL)
                h = 90
            }
            tipView.button.rx.tap.subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                
            }).disposed(by: disposeBag)
            
            view.addSubview(tipView)
            tipView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(12)
                make.bottom.equalToSuperview().offset(-12)
            }
            view.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: h)
        }
        
        return view
    }()
    
    lazy var footerTipView: YXOptionalTipsView = {
        let view = YXOptionalTipsView.init(frame: CGRect.zero, type: .loginedWhenUS)
        view.button.rx.tap.subscribe(onNext: {
            if let url = URL(string: YXH5Urls.goBuyOnLineUrl()) {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)
        return view
    }()
    
    enum YXOptionalLoginBtnType {
        case common
        case delay  //延时
        case bmp    //bm
    }
    lazy var loginBtnType: YXOptionalLoginBtnType = .common //登录  、 了解详情 的显示类型
    
    
    var refreshTimer: Timer?
    var startRow: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFootViewUI()

        tableView.reloadData()
    }
    
    @objc func refresh() {
        refreshHeader.refreshingBlock?()
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    //更新底部view
    func updateFootViewUI() {
        tableView.tableHeaderView = UIView()
        var market: String? = nil
        if let secuGroup = viewModel.secuGroup.value, let groupId = YXDefaultGroupID(rawValue: secuGroup.id) {
            addStockButton.isHidden = false

            footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 110)
            tipsLabel.isHidden = true

            loginBtnType = .common
            tipsLabel.attributedText = nil
            tipsLabel.text = nil

            tipsLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(footerView).offset(18)
                make.right.equalTo(footerView).offset(-18)
                make.top.equalTo(footerView).offset(58)
            }
            
            let shouldHiddeAddButton = YXSecuGroupManager.shareInstance().allSecuGroup.list.count >= YXGlobalConfigManager.configFrequency(.optStocksMaxNum)

            switch groupId {
            case .idAll, .IDHK:
                
                if !YXUserManager.isLogin() {
                    tableView.tableHeaderView = headerTipView
                }
                self.addStockView.isHidden = shouldHiddeAddButton
                
                let hkSecuGroup = YXSecuGroupManager.shareInstance().defaultGroupPool[NSNumber(value: YXDefaultGroupID.IDHK.rawValue)] as! YXSecuGroup
                
                market = kYXMarketHK
                if groupId == .idAll {
                    if hkSecuGroup.list.count > 0, YXQuoteTipHelper.isShowTip(kYXMarketHK) {
                        market = kYXMarketHK
                    } else {
                        market = kYXMarketUS
                    }
                }
                
                if YXUserManager.hkLevel() == .hkBMP {
                    var hkSecuId = [YXSecuID]()
                    hkSecuGroup.list.forEach { (secuId) in
                        if secuId.marketType() == .hongKong {
                            hkSecuId.append(secuId)
                        }
                    }
                    if hkSecuId.count > 0 {
                        let text = YXLanguageUtility.kLang(key: "tip_quote_permission_bmp") + "\n" + YXLanguageUtility.kLang(key: "tip_quote_permission_upgrade")
                        let attributeString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 12)])
                        
                        attributeString.append(NSAttributedString(string: "\n" + YXLanguageUtility.kLang(key: "newStock_see_more"), attributes: [.foregroundColor: QMUITheme().themeTextColor(), .font: UIFont.systemFont(ofSize: 12), .baselineOffset: -5]))
                        

                        
                        let height = attributeString.boundingRect(with: CGSize.init(width: YXConstant.screenWidth - 36, height: CGFloat.greatestFiniteMagnitude), options:[ .usesLineFragmentOrigin, .usesFontLeading], context: nil).height
                        
                        footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 54 + 58 + height + 10)

                        
                        tipsLabel.attributedText = attributeString
                        
                    }
                    
                    
                    tipsLabel.isHidden = false
                    loginBtnType = .bmp
                } else if YXUserManager.hkLevel() == .hkDelay {
                    footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200)
                    tipsLabel.isHidden = false
                    //common_delaytips
                    tipsLabel.text = YXLanguageUtility.kLang(key: "tip_quote_permission_delay_no_login")
                    loginBtnType = .delay
                }
                
            case .IDHOLD, .IDLATEST:
                if groupId == .IDLATEST {
                    YXSecuGroupManager.shareInstance().checkLatestTrade()
                }
                tableView.emptyDataSetSource = nil
                self.addStockView.isHidden = shouldHiddeAddButton

            case .IDUSOPTION:
                self.addStockView.isHidden = true
            case .IDUS:
//                if YXUserManager.isLogin(), YXUserManager.shared().curLoginUser?.openedAccount == false {
//                    tableView.tableHeaderView = guideItemView
//                    guideItemView.label.requestToStartAnimation()
//                }
                if !YXUserManager.isLogin() {
                    tableView.tableHeaderView = headerTipView
                }else {
                    if YXUserManager.usLevel() == .usDelay {
                        footerTipView.removeFromSuperview()
                        footerView.addSubview(footerTipView)
                        footerTipView.snp.makeConstraints { (make) in
                            make.left.equalToSuperview().offset(12)
                            make.right.equalToSuperview().offset(-12)
                            make.top.equalToSuperview().offset(48)
                            make.height.equalTo(73)
                        }
                        footerView.frame = CGRect.init(x: 0, y: 0, width: view.width, height: 120)
                    }
                }
                self.addStockView.isHidden = shouldHiddeAddButton
            default:
                self.addStockView.isHidden = shouldHiddeAddButton
                
            }
        }

        tableView.tableFooterView = footerView
    }
    
    @objc func pollingTimeLineData() {
        viewModel.pollingTimeLineData()
    }
    
    func startPollingTimeLine() {
        stopPollingTimeLine()
        
        self.timeFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] flag in
            guard let `self` = self else { return }
            self.viewModel.pollingTimeLineData()
        }, timeInterval: TimeInterval(60.0), repeatTimes: Int.max, atOnce: false)

    }
    
    func stopPollingTimeLine() {
        if self.timeFlag != nil {
            YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.timeFlag!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let timer = refreshTimer {
            timer.invalidate()
            refreshTimer = nil
        }
        refreshTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refresh), userInfo: nil, repeats: false)
        startPollingTimeLine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        refreshTimer?.invalidate()
        refreshTimer = nil

        viewModel.services.v2QuoteService.unSubOptional(with: viewModel.quoteRequests)
        
        stopPollingTimeLine()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.rowHeight = 72
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    func creatAddStockView() -> UIView {
        let view = UIView()
        let addButton = self.addButton()
        view.addSubview(addButton)

        addButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(54)
        }
        
//        addButton.rx.tap.subscribe(onNext: { [weak self] (_) in
//            guard let `self` = self else { return }
//            guard let secuGroup = self.viewModel.secuGroup.value else { return }
//            self.viewModel.navigator.present(YXModulePaths.search.url, context: ["secuGroup": secuGroup], animated: false)
//        }).disposed(by: disposeBag)
        
        return view
    }
    
    lazy var customEmptyView: UIView = {
        let view = UIView()
        let emptybutton = QMUIButton()
        emptybutton.setTitle(YXLanguageUtility.kLang(key: "common_string_of_emptyPicture"), for: .normal)
        emptybutton.titleLabel?.font = .systemFont(ofSize: 16)
        emptybutton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        emptybutton.spacingBetweenImageAndTitle = 20
        emptybutton.imagePosition = .top
        emptybutton.setImage(UIImage(named: "empty_noData"), for: .normal)
        
        let addButton = QMUIButton()
        addButton.layer.cornerRadius = 4
        addButton.backgroundColor = QMUITheme().mainThemeColor()
        addButton.imagePosition = .left
        addButton.spacingBetweenImageAndTitle = 2
        addButton.setTitle(YXLanguageUtility.kLang(key: "common_add_stock"), for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        let image = UIImage(named: "optional_empty_add")?.qmui_image(withTintColor: .white)
        addButton.setImage(image, for: .normal)
        addButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            guard let secuGroup = self.viewModel.secuGroup.value else { return }
            self.viewModel.navigator.present(YXModulePaths.search.url, context: ["secuGroup": secuGroup], animated: false)
        }).disposed(by: disposeBag)
        
        view.addSubview(emptybutton)
        view.addSubview(addButton)
        
        emptybutton.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(195)
//            make.top.equalTo(button.snp.bottom).offset(10)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.width.equalTo(118)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(emptybutton.snp.bottom).offset(12)
        }
        
        
        if let secuGroup = viewModel.secuGroup.value, let groupId = YXDefaultGroupID(rawValue: secuGroup.id) {
            if groupId == .IDUSOPTION || groupId == .IDHOLD {
                addButton.isHidden = true
            }else {
                addButton.isHidden = false
            }
        }
        
        return view
    }()
    
    func initTableView() {
        
        view.backgroundColor = .clear
        let line = UIView.line()
        view.addSubview(line)
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view)
            make.height.equalTo(35)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
            make.top.equalTo(headerView.snp.bottom)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(line.snp.bottom)
            make.bottom.equalTo(view)
        }
        
        footerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 130)
        tableView.tableFooterView = footerView
        
        
        footerView.addSubview(tipsLabel)
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(footerView).offset(18)
            make.right.equalTo(footerView).offset(-18)
            make.top.equalTo(footerView).offset(98)
        }
        //MARK: 底部的 登录 、 了解详情
        footerView.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel)
            make.right.equalTo(footerView).offset(-18)
            make.left.equalTo(tipsLabel.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 60, height: 20))
        }
        loginButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        loginButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            switch self.loginBtnType {
            case .delay:
                
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: UIViewController.current()))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            default:
                break
            }
            
        }).disposed(by: disposeBag)
        
        setupRefreshHeader(tableView)
        
        let CellIdentifier = NSStringFromClass(YXOptionalListCell.self)
        
        viewModel.dataSource.subscribe(onNext: { [weak self] (dataSource) in
            if dataSource.count == 0 {
                self?.footerView.isHidden = true
            } else {
                self?.footerView.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        viewModel.dataSource.bind(to: tableView.rx.items) { [weak self] (tableView, row, item) in
            guard let strongSelf = self else { return YXOptionalListCell(style: .default, reuseIdentifier: CellIdentifier) }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? YXOptionalListCell {
                cell.quote.accept(item)
                cell.longPressHandler = { [weak self, weak item] (ges) in
                    guard let strongSelf = self else { return }
                    guard let secuGroup = strongSelf.viewModel.secuGroup.value else { return }
                    guard let groupId = YXDefaultGroupID(rawValue: secuGroup.id) else { return }
                    
                    let menuView = YXOptionalMenuView()
                    menuView.name = item?.symbol ?? ""
                    if groupId == .IDHOLD || groupId == .IDLATEST {
                        menuView.itemType = .manage
                    } else {
                        menuView.itemType = [.stick, .delete, .manage, .edit]
                    }
                    
                    let contentView = ges.view;
                    let point = ges.location(in: contentView)
                    let targetRectInWindow = contentView?.convert(contentView?.frame ?? .zero, to: UIApplication.shared.keyWindow)
                    menuView.delegate = strongSelf
                    let secuId = YXSecuID(market: cell.quote.value?.market ?? "", symbol: cell.quote.value?.symbol ?? "")
                    menuView.selectedSecu = secuId
                    menuView.setTargetPoint(point, rect: targetRectInWindow ?? .zero)                                           //[menuView
                    menuView.show()
                }
                return cell
            }
            
            let cell = YXOptionalListCell(style: .default, reuseIdentifier: CellIdentifier)
            
            cell.longPressHandler = { [weak self] (ges) in
                guard let strongSelf = self else { return }
                guard let secuGroup = strongSelf.viewModel.secuGroup.value else { return }
                guard let groupId = YXDefaultGroupID(rawValue: secuGroup.id) else { return }
                
                let menuView = YXOptionalMenuView()
                if groupId == .IDHOLD || groupId == .IDLATEST {
                    menuView.itemType = .manage
                } else {
                    menuView.itemType = [.stick, .delete, .manage, .edit]
                }
                
                let contentView = ges.view;
                let point = ges.location(in: contentView)
                let targetRectInWindow = contentView?.convert(contentView?.frame ?? .zero, to: UIApplication.shared.keyWindow)
                menuView.delegate = strongSelf
                let secuId = YXSecuID(market: cell.quote.value?.market ?? "", symbol: cell.quote.value?.symbol ?? "")
                menuView.selectedSecu = secuId
                menuView.setTargetPoint(point, rect: targetRectInWindow ?? .zero)                                           //[menuView
                menuView.show()
            }
            
            cell.quoteAccessView.rx.tapGesture().subscribe(onNext: { (ges) in
                if ges.state == .ended {
                    guard let strongSelf = self else { return }
                    
                    switch strongSelf.viewModel.quoteType.value {
                    case .change:
                        strongSelf.viewModel.quoteType.accept(.roc)
                    case .roc:
                        strongSelf.viewModel.quoteType.accept(.now)
                    case .now:
                        strongSelf.viewModel.quoteType.accept(.change)
                    default:
                        break
                    }
                }
            }).disposed(by: strongSelf.disposeBag)
            
            cell.quote.asDriver().drive(onNext: { [weak self] (item) in
                guard let strongSelf = self else { return }
                
                cell.stockInfoView.name = "--"
                if let name = item?.name, name.count > 0 {
                    cell.stockInfoView.name = name
                }
                
                
                if let level = item?.level?.value, QuoteLevel(rawValue: Int(level)) == .delay {
                    cell.stockInfoView.delayLabel.isHidden = false
                } else {
                    cell.stockInfoView.delayLabel.isHidden = true
                }
                
                if let cmpActiveFlag = item?.cmpActiveFlag?.value, cmpActiveFlag == 1 {
                    cell.stockInfoView.dividensImageView.isHidden = false
                } else {
                    cell.stockInfoView.dividensImageView.isHidden = true
                }
                
                let key = (item?.market ?? "") + (item?.symbol ?? "")
                let timeLineModel = strongSelf.viewModel.timeLineDataSource.value[key]
                cell.simpleLineView.market = item?.market ?? ""
                cell.simpleLineView.symbol = item?.symbol ?? ""
                if let quote = item {
                    cell.simpleLineView.quote = quote
                    if let latestTime = quote.latestTime?.value, let singleTimeModel = timeLineModel?.list.firstObject as? YXTimeLineSingleModel {
                        let fromDay = YXDateToolUtility.dateTime(withTime: String(latestTime))
                        let toDay = YXDateToolUtility.dateTime(withTime: singleTimeModel.time)
                        if fromDay.day != toDay.day {
                            
                            let needReloadLineKey = "reloadLine_" + (quote.market ?? "")
                            let (sameDay,_) = YXUserManager.isTheSameDay(with: needReloadLineKey)
                            if !sameDay {
                                self?.viewModel.pollingTimeLineData()
                            }
                        }
                    }
                }
                cell.simpleLineView.timeModel = timeLineModel ?? YXTimeLineModel()

                cell.stockInfoView.symbol = "--"
                if let symbol = item?.symbol, let market = item?.market {
                    cell.stockInfoView.symbol = symbol
                    cell.stockInfoView.market = market
                }
                
                cell.quoteAccessView.quote = item
                cell.quoteAccessView.quoteType = nil
                cell.quoteAccessView.quoteTypeRelay.accept(strongSelf.viewModel.quoteType.value)
                let qouteIdentifiy = (item?.market ?? "") + "_" + (item?.symbol ?? "")
                if let prePrice = cell.prePrice, let nowPrice = item?.latestPrice?.value, let market = item?.market, let symbol = item?.symbol {
                    if cell.stockInfoView.symbol == symbol, cell.stockInfoView.market == market,cell.quoteIdenitifiy == qouteIdentifiy {
                        if nowPrice > prePrice {
                            cell.animationStockUp()
                        }else if nowPrice < prePrice {
                            cell.animationStockDown()
                        }
                    }
                }
                
                cell.prePrice = item?.latestPrice?.value
                cell.quoteIdenitifiy = qouteIdentifiy
                
                if let tradingStatus = item?.trdStatus?.value {
                    var str: String?
                    if tradingStatus == OBJECT_QUOTETradingStatus.tsSuspended.rawValue {
                        str = YXLanguageUtility.kLang(key: "stock_detail_suspenden")
                    } else if tradingStatus == OBJECT_QUOTETradingStatus.tsDelisting.rawValue  {
                        str = YXLanguageUtility.kLang(key: "stock_detail_delisted")
                    }  else if tradingStatus == OBJECT_QUOTETradingStatus.tsUnlisted.rawValue {
                        str = YXLanguageUtility.kLang(key: "stock_detail_beforList")
                    } else if tradingStatus == OBJECT_QUOTETradingStatus.tsZanting.rawValue {
                        str = YXLanguageUtility.kLang(key: "zanting")
                    } else {
                        
                    }
                    if let text = str {
                        cell.quoteAccessView.infoLabel.text = text
                    }
                }
                                      
                
            }).disposed(by: strongSelf.disposeBag)
            
            cell.quote.accept(item)
            return cell
            }
            .disposed(by: disposeBag)
        
        tableView.delegate = self
    }
    
    override func showErrorEmptyView() {
        
    }
    
    override func showNoDataEmptyView() {
        
    }
    
    override func showEmptyView() {
        
    }
    
    override func hideEmptyView() {
        
    }
    
    override func emptyRefreshButtonAction() {
        if let refreshingBlock = refreshHeader.refreshingBlock{
            refreshingBlock()
        }
    }

    lazy var noticeView: YXQuoteKickNoticeView = {
        let view = YXQuoteKickTool.createNoticeView()

        view.quoteLevelChangeBlock = {
            [weak self] in
            guard let `self` = self else { return }

            self.networkingHUD.showLoading("")
            YXQuoteKickTool.shared.getUserQuoteLevelRequest(activateToken: true, resultBock: {
                [weak self] _ in
                guard let `self` = self else { return }
                self.networkingHUD.hide(animated: true)
                //请求后有通知， 逻辑在YXUserManager.notiQuoteKick通知中处理

            })
        }

        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopPollingTimeLine()
    }
}

extension YXOptionalListViewController {

    func addQuoteKickNotification() {
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                var isFromAlert = false
                var isRefresh = false
                if let object = noti.object as? NSNumber {
                    isFromAlert = object.boolValue
                }

                var market = ""
                if let group = self.viewModel.secuGroup.value {
                    if group.id == YXDefaultGroupID.IDUS.rawValue {
                        market = kYXMarketUS
                    } else if group.id == YXDefaultGroupID.IDHK.rawValue {
                        market = kYXMarketHK
                    }
                }

                if self.showNoticeView {
                    if self.showNoticeView && (YXQuoteKickTool.shared.currentQuoteLevleIsReal(market) || !YXUserManager.isLogin()) {
                        self.showNoticeView = false
                        isRefresh = true
                    }
                } else {
                    if self.showNoticeView == false, YXQuoteKickTool.shared.isQuoteLevelKickToDelay(market) {
                        self.showNoticeView = true
                        isRefresh = true
                    }
                }

                if isRefresh, !isFromAlert, self.qmui_isViewLoadedAndVisible() {
                    self.beginAppearanceTransition(false, animated: false)
                    self.endAppearanceTransition()

                    self.beginAppearanceTransition(true, animated: false)
                    self.endAppearanceTransition()
                }

            }).disposed(by: rx.disposeBag)
    }

}

extension YXOptionalListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let currentItem = self.viewModel.dataSource.value[indexPath.row]
        let canIncludeOption = (YXUserManager.shared().getOptionLevel() == .level1)
        var inputs: [YXStockInputModel] = []
        var index = 0
        var selectIndex = 0
        for item in self.viewModel.dataSource.value {
            let market = item.market ?? ""
            let symbol = item.symbol ?? ""
            let name = item.name
            let type1 = item.type1?.value
            let type2 = item.type2?.value
            let type3 = item.type3?.value

            let input = YXStockInputModel()
            input.market = market
            input.symbol = symbol
            input.name = name ?? ""
            input.type1 = type1
            input.type2 = type2
            input.type3 = type3

            if market == kYXMarketUsOption {
                if canIncludeOption {
                    inputs.append(input)
                } else {
                    index -= 1
                }
            } else {
                inputs.append(input)
            }

            if market == currentItem.market, symbol == currentItem.symbol {
                selectIndex = index
            }

            index += 1
        }

        if selectIndex < 0 {
            selectIndex = 0
        }

        if currentItem.market == kYXMarketUsOption && !canIncludeOption {
            YXToolUtility.handleBusinessWithOptionLevel(excute: {
                self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : selectIndex])
            })
        } else {
            self.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : selectIndex])
        }
        
        let stockCode = (currentItem.market ?? "") + (currentItem.symbol ?? "")
        let stockName = currentItem.name ?? ""
        self.trackViewClickEvent(name: "stocklist_item", other: ["stock_code": stockCode, "stock_name": stockName])

    }
}

extension YXOptionalListViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallback = callback
    }
}

extension YXOptionalListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}

extension YXOptionalListViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard let secuGroup = self.viewModel.secuGroup.value else { return }
        self.viewModel.navigator.present(YXModulePaths.search.url, context: ["secuGroup": secuGroup], animated: false)
    }
}

extension YXOptionalListViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage(named: "empty_noData")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        NSAttributedString(string: YXLanguageUtility.kLang(key: "opt_stock_empty"), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: QMUITheme().textColorLevel3()])
    }
    
//    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
//        let image = addButton.qmui_snapshotLayerImage()//addButtonImage
//        return image
//    }
    
//    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
//        return 20
//    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return customEmptyView
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
       return 40
    }
    
}

extension YXOptionalListViewController: YXOptionalMenuViewDelegate {
    func menuClickEdit(_ secu: YXSecuIDProtocol) {
        guard let secuGroup = viewModel.secuGroup.value  else { return }
        
        let vm = YXStockManageViewModel.init()
        vm.defaultSelectedId = secuGroup.id
        vm.defaultSelectedSecu = secu
        
        let vc = YXStockManageViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services as! YXStockManageViewModel.Services, andNavigator: self.viewModel.navigator)
        
        bottomSheet.rightButton.isHidden = true
        bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "stock_manager")
        bottomSheet.showViewController(vc: vc)
    }
    
    func menuClickStick(_ secu: YXSecuIDProtocol, with name: String) {
        guard let secuGroup = viewModel.secuGroup.value  else { return }
        YXSecuGroupManager.shareInstance().stick(secuGroup, secu: secu)
        YXProgressHUD.showMessage(String(format: YXLanguageUtility.kLang(key: "stock_toTop"), name))
    }
    
    func menuClickDelete(_ secu: YXSecuIDProtocol) {
        guard let secuGroup = viewModel.secuGroup.value  else { return }
                   
        var title = YXLanguageUtility.kLang(key: "tip_for_delete_optional_stock")
        if secuGroup.groupType() != .custom {
            title = YXLanguageUtility.kLang(key: "tips_for_delete_stock_from_all_group")
        }
        let alertView = YXAlertView(message: title)
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
            
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak secuGroup] (action) in
            guard let secuGroup = secuGroup else { return }
            YXSecuGroupManager.shareInstance().remove(secu, secuGroup: secuGroup)
        }))
        
        let alertController = YXAlertController(alert: alertView)
        present(alertController!, animated: true, completion: nil)
        
    }
    
    func menuClickManage(_ secu: YXSecuIDProtocol, with name: String) {
        guard let secuGroup = viewModel.secuGroup.value  else { return }
        
        if YXUserManager.isLogin() {
            
            let groupSettingView = YXGroupSettingView(secus: [secu], secuName:"", currentOperationGroup: secuGroup, settingType: YXGroupSettingTypeModify)

            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "add_to_group")
            self.bottomSheet.rightButton.isHidden = false
            self.bottomSheet.rightButtonAction = { [weak groupSettingView, weak self] in
                groupSettingView?.sureButtonAction()
                self?.bottomSheet.hide()
            }
            self.bottomSheet.showView(view: groupSettingView)

        } else {
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
            viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        }
    }
}


class YXOptionalTipsView: UIView {
    enum YXOptionalTipsViewType {
        case unLoginWhenALL
        case unLoginWhenUS
        case loginedWhenUS
        
        var text: String {
            switch self {
            case .unLoginWhenALL:
                return YXLanguageUtility.kLang(key: "qoutes_no_upagrade_tip")
            case .unLoginWhenUS:
                return YXLanguageUtility.kLang(key: "qoutes_deley_non_log_tip") //"Price quotes are provided with a 15-minute delay for non-logged in users."
            case .loginedWhenUS:
                return YXLanguageUtility.kLang(key: "qoutes_upagrade_real_tip")
            }
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    init(frame: CGRect, type: YXOptionalTipsViewType) {
        super.init(frame: frame)
        
        layer.cornerRadius = 4
        backgroundColor = QMUITheme().blockColor()
        
        addSubview(label)
        addSubview(button)
        
        label.text = type.text
        
        switch type {
        
        case .unLoginWhenALL, .unLoginWhenUS:
            
            button.setTitle(YXLanguageUtility.kLang(key: "login_loginTip"), for: .normal)
            
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(8)
                make.left.equalToSuperview().offset(12)
                make.right.equalTo(button.snp.left).offset(-18)
                make.bottom.equalToSuperview().offset(-8)
            }
            
            button.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-12)
                make.centerY.equalToSuperview()
            }
            
        case .loginedWhenUS:
            
            button.setTitle(YXLanguageUtility.kLang(key: "newStock_see_more"), for: .normal)
            
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(8)
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-12)
                make.bottom.equalToSuperview().offset(-29)
            }
            
            button.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-12)
                make.bottom.equalToSuperview().offset(-8)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
