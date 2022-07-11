//
//  YXShareOptionsViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit
import JXPagingView

class YXShareOptionsViewController: YXViewController {
    
    var disposeBag = DisposeBag()
    
    var currentDate: String = ""
    var currentVC: UIViewController?
        
    var isLandscape = false
        
    var shouldGetData = true
    var date: Date?
    
    var selectedTabViewIndex: Int = 0

    var emptyScrollView: UIScrollView?
    var quote: YXV2Quote?
    
    var vm: YXShareOptionsViewModel {
        return self.viewModel as! YXShareOptionsViewModel
    }
    
    var quoteRequest: YXQuoteRequest?
    
    lazy var emptybutton:YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.layer.cornerRadius = 4
        button.backgroundColor = QMUITheme().themeTextColor()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        if !YXUserManager.isLogin() {
            button.setTitle(YXLanguageUtility.kLang(key: "nbb_loginandregister"), for: .normal)
        } else {
            button.setTitle(YXLanguageUtility.kLang(key: "go_to_get"), for: .normal)
        }
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        button.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            YXToolUtility.handleBusinessWithOptionLevel(callBack: {
                [weak self] in
                guard let `self` = self else { return }
                if !YXUserManager.isLogin() {
                    self.emptybutton.setTitle(YXLanguageUtility.kLang(key: "nbb_loginandregister"), for: .normal)
                } else {
                    self.emptybutton.setTitle(YXLanguageUtility.kLang(key: "go_to_get"), for: .normal)
                }
                YXWebViewModel.pushToWebVC(YXH5Urls.myQuotesUrl(tab: 1, levelType: 3))
            },excute: {
                [weak self] in
                guard let `self` = self else { return }
                self.createNewUI()
            })

        }).disposed(by: rx.disposeBag)
        return button
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "warrant_search"), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let didSelectedItem: (YXSearchItem)->() = { [weak self] (item) in
                guard let `self` = self else { return }
                self.refreshData(market: item.market, symbol: item.symbol)
            }
            let dic = ["didSelectedItem": didSelectedItem, "warrantType": YXStockWarrantsType.optionChain, "needPushOptionChain" : true] as [String : Any]
            
            self.vm.services.pushPath(.stockWarrantsSearch, context: dic, animated: true)
            
        }).disposed(by: disposeBag)
        
        return button
    }()
    
    lazy var stockView: YXStockTopView = {
        let view = YXStockTopView()
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self]tap in
            if let market = self?.vm.market, let symbol = self?.vm.symbol {
                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = ""

                self?.vm.services.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex":  0], animated: true)
            }
            
        })
        return view
    }()
    
    lazy var dateTabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = true
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()//QMUITheme().themeTextColor()
        tabLayout.titleFont = .systemFont(ofSize: 14)
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
                
        if self.vm.style != .inStockDetail {
            let topLine = UIView.line()
            tabView.addSubview(topLine)
            topLine.snp.makeConstraints { (make) in
                make.height.equalTo(0.5)
                make.top.left.right.equalToSuperview()
            }
        }
        
        tabView.delegate = self
        
        return tabView
    }()
    
    lazy var filterView:ShareOptionFilterView = {
        let view = ShareOptionFilterView.init(frame: .zero, defaultSelectIndex: YXShareOptionsType.all.rawValue)
        view.selectCallBack = { [weak self] type in
            guard let `self` = self else { return }
            self.selectedTabViewIndex = type.rawValue
           
            if self.vm.listStyle == .straddleStyle {
                if let vc = self.pageView.viewControllers[self.selectedTabViewIndex] as? YXShareOptionsListViewController {
                    self.currentVC = vc
                    vc.listViewModel.currentOptinosCount = self.vm.currentOptinosCount
                    self.pageView.contentView.setContentOffset(CGPoint(x: self.selectedTabViewIndex * Int(YXConstant.screenWidth), y: 0), animated: false)
                }
            } else {
                if let vc = self.pageView.viewControllers[self.selectedTabViewIndex + 3] as? ShareOptionNewListViewController {
                    self.currentVC = vc
                    vc.listViewModel.currentOptinosCount = self.vm.currentOptinosCount
                    self.pageView.contentView.setContentOffset(CGPoint(x: (self.selectedTabViewIndex + 3) * Int(YXConstant.screenWidth), y: 0), animated: false)
                }
            }
        }
        
        view.changeStyleCallBack = { [weak self] in
            guard let `self` = self else { return }
            
            let showView = self.createShowView()
            
            self.bottomSheet.leftButtonAction = { [weak self] in
                guard let `self` = self else { return }
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true)
                }
            }
            
            self.bottomSheet.rightButtonAction = { [weak self] in
                guard let `self` = self else { return }
                guard let strike = showView.getSelectStrike(),let style = showView.getSelectStyle() else {
                    if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                        vc.hideWith(animated: true)
                    }
                    return
                }
                
                if self.vm.listStyle.rawValue != style.rawValue {
                    self.vm.listStyle = style
                    MMKV.default().set(Int32(self.vm.listStyle.rawValue), forKey: YXShareOptionsViewModel.ListStyleKey)
                }
                
                if self.vm.currentOptinosCount.rawValue != strike.rawValue {
                    self.vm.currentOptinosCount = strike
                    MMKV.default().set(Int32(self.vm.currentOptinosCount.rawValue), forKey: YXShareOptionsViewModel.StrikeKey)
                    //切换数量列表滚动到现价
                    self.vm.allVC.shouldScrollToMiddle = true
                    self.vm.callVC.shouldScrollToMiddle = true
                    self.vm.putVC.shouldScrollToMiddle = true
                    self.vm.allNewListVC.shouldScrollToMiddle = true
                    self.vm.callNewListVC.shouldScrollToMiddle = true
                    self.vm.putNewListVC.shouldScrollToMiddle = true
                }
                
                
                if self.vm.listStyle == .straddleStyle {
                    if let vc = self.pageView.viewControllers[self.selectedTabViewIndex] as? YXShareOptionsListViewController {
                        self.currentVC = vc
                        self.pageView.contentView.setContentOffset(CGPoint(x: self.selectedTabViewIndex * Int(YXConstant.screenWidth), y: 0), animated: false)
                        vc.listViewModel.currentOptinosCount = self.vm.currentOptinosCount
                        vc.getData(showLoading: true)
                    }
                } else {
                    if let vc = self.pageView.viewControllers[self.selectedTabViewIndex + 3] as? ShareOptionNewListViewController {
                        self.currentVC = vc
                        self.pageView.contentView.setContentOffset(CGPoint(x: (self.selectedTabViewIndex + 3) * Int(YXConstant.screenWidth), y: 0), animated: false)
                        vc.listViewModel.currentOptinosCount = self.vm.currentOptinosCount
                        vc.getData(showLoading: true)
                    }
                }
            
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true)
                }
            }
            self.bottomSheet.showView(view: showView, contentHeight: 268)
        }
        return view
    }()
    
    func createShowView() ->ShareOptionSettingView {
        
        var styleIndex = 0
        if vm.listStyle == .straddleStyle {
            styleIndex = 0
        } else {
            styleIndex = 1
        }
        
        var strikeIndex = 0
        if vm.currentOptinosCount == .all {
            strikeIndex = 0
        } else if vm.currentOptinosCount == .ten {
            strikeIndex = 1
        } else if vm.currentOptinosCount == .twenty {
            strikeIndex = 2
        } else if vm.currentOptinosCount == .forty {
            strikeIndex = 3
        }
        
        let oneSectionDatas = [
            OptionSectionDataModel.init(title: YXShareOptionsListStyle.straddleStyle.title, rawValue: YXShareOptionsListStyle.straddleStyle),
            OptionSectionDataModel.init(title: YXShareOptionsListStyle.listStyle.title, rawValue: YXShareOptionsListStyle.listStyle)]
        
        let oneSection =  OptionSectionModel.init(sectionTitle: YXLanguageUtility.kLang(key: "option_list_style"), datas: oneSectionDatas, index: styleIndex)
        
        let twoSectionDatas = [
            OptionSectionDataModel.init(title: YXShareOptinosCount.all.title, rawValue: YXShareOptinosCount.all),
            OptionSectionDataModel.init(title: YXShareOptinosCount.ten.title, rawValue: YXShareOptinosCount.ten),
            OptionSectionDataModel.init(title: YXShareOptinosCount.twenty.title, rawValue: YXShareOptinosCount.twenty),
            OptionSectionDataModel.init(title: YXShareOptinosCount.forty.title, rawValue: YXShareOptinosCount.forty)]
        
        let twoSection =  OptionSectionModel.init(sectionTitle: YXLanguageUtility.kLang(key: "option_strikes"), datas:twoSectionDatas, index: strikeIndex)
        let view = ShareOptionSettingView.init(frame: .zero, sections: [oneSection,twoSection])
        return view
    }
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.header.backgroundColor = QMUITheme().popupLayerColor()
        sheet.titleLabel.text = YXLanguageUtility.kLang(key: YXLanguageUtility.kLang(key: "option_list_setting"))
        sheet.titleLabel.textColor = QMUITheme().textColorLevel1()
        sheet.leftButton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        sheet.leftButton.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        sheet.leftButton.titleLabel?.font = .systemFont(ofSize: 16)
        sheet.rightButton.setTitle(YXLanguageUtility.kLang(key: "user_save"), for: .normal)
        sheet.rightButton.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        sheet.rightButton.titleLabel?.font = .systemFont(ofSize: 16)


        return sheet
    }()
    
    //不需要显示tabview
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.titles = [YXShareOptionsType.all.title, YXShareOptionsType.call.title, YXShareOptionsType.put.title,YXShareOptionsType.all.title, YXShareOptionsType.call.title, YXShareOptionsType.put.title]
        tabView.pageView = self.pageView
        tabView.delegate = self
        if self.vm.listStyle == .straddleStyle {
            tabView.defaultSelectedIndex = 0
            currentVC = self.vm.allVC
        } else {
            tabView.defaultSelectedIndex = UInt(3)
            currentVC = self.vm.allNewListVC
        }
        tabView.isHidden = true
        return tabView
    }()
    
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        pageView.viewControllers = [vm.allVC, vm.callVC, vm.putVC,vm.allNewListVC,vm.callNewListVC,vm.putNewListVC]
        
        return pageView
    }()
    
    lazy var collegeNavItem: UIBarButtonItem = {
        
        let searchItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "options_101"), target: nil, action: nil)
        searchItem.rx.tap.bind {
            YXWebViewModel.pushToWebVC(YXH5Urls.OPTION_COLLEGE_URL())
        }.disposed(by: disposeBag)
        
        return searchItem
    }()
    
    lazy var noOptionsView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        let imageV = UIImageView.init(image: UIImage(named: "empty_noData"))
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key:"common_string_of_emptyPicture")
        view.addSubview(imageV)
        view.addSubview(label)
        imageV.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageV.snp.bottom).offset(10)
        }
        view.isHidden = true
        return view
    }()
    
    func refreshData(market: String, symbol: String) {
        vm.market = market
        vm.symbol = symbol
        self.vm.allVM.quote = nil
        self.vm.callVM.quote = nil
        self.vm.putVM.quote = nil

        shouldGetData = true
        
        getDate()
        if dateTabView.titles.count > 0 {
            dateTabView.selectTab(at: 0)
        }
    }
    
    override var pageName: String {
        return "us option chain"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = YXLanguageUtility.kLang(key: "options_options")
        if YXUserManager.shared().getOptionLevel() == .level1 {
            setUI()
            getDate()
            
        } else {
            addEmptyView()
        }
    }
    
    func getDate() {
        vm.getDate().subscribe(onSuccess: { [weak self](e) in
            if let list = self?.vm.dateModel?.list {
                var dateArr = [String]()
                for index in 0..<list.count {
                    let item = list[index]
                    if index == 0, let date = item.maturityDate {
                        self?.currentDate = date
                        self?.vm.allVM.maturityDate = date
                        self?.vm.callVM.maturityDate = date
                        self?.vm.putVM.maturityDate = date
                        
                        if let style  = self?.vm.listStyle {
                            switch style {
                            case .straddleStyle:
                                if let vc = self?.currentVC as? YXShareOptionsListViewController {
                                    if vc.listViewModel.stockPrice > 0{
                                        vc.loadFirstPage()
                                    }
                                }
                            case .listStyle:
                                if let vc = self?.currentVC as? ShareOptionNewListViewController {
                                    if vc.listViewModel.stockPrice > 0{
                                        vc.loadFirstPage()
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    if let timeStr = item.maturityDate {
                        var dateStr = ""
                        if YXUserManager.isENMode() {
                            dateStr = YXDateHelper.commonDateString(timeStr) + String(format: "(%d)", item.remainingTime)
                        } else {
                            let dateModel = YXDateToolUtility.dateTime(withTime: timeStr)
                            dateStr = "\(dateModel.year)-\(dateModel.month)-\(dateModel.day)(\(item.remainingTime))"
                        }
                        
                        dateArr.append(dateStr)
                    }
                }
                self?.dateTabView.titles = dateArr
                self?.dateTabView.reloadData()
                self?.noOptionsView.isHidden = dateArr.count != 0
            }
        }).disposed(by: disposeBag)
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if vm.market.count > 0, vm.symbol.count > 0 {
            let secu = Secu.init(market: vm.market, symbol: vm.symbol)
            let level = YXUserManager.shared().getLevel(with: vm.market)//YXUserManager.shareInstance().getCurLevel(withMarket: vm.market)
            self.quoteRequest?.cancel()
            self.quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [secu], level: level, handler: { [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                let quote = quotes.first
                self.updateStockInfo(quote: quote)
            })
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.quoteRequest?.cancel()
    }
    
    func updateStockInfo(quote: YXV2Quote?) {
        
        self.stockView.model = quote
        self.vm.allVM.quote = quote
        self.vm.callVM.quote = quote
        self.vm.putVM.quote = quote
        
        if !shouldGetData {
            // 限制不能太频繁的刷新使页面卡顿
            if self.date == nil || Date().timeIntervalSince(self.date!) > 1 {
                
                switch self.vm.listStyle {
                case .straddleStyle:
                    if let vc = self.currentVC as? YXShareOptionsListViewController {
                        vc.tableView?.reloadData()
                    }
                case .listStyle:
                    if let vc = self.currentVC as? ShareOptionNewListViewController {
                        vc.tableView?.reloadData()
                    }
                }
                self.date = Date()
            }
            
        }
        
        if let price = quote?.latestPrice?.value, price > 0, shouldGetData {
            switch self.vm.listStyle {
            case .straddleStyle:
                if let currentVC = self.currentVC, let vc = currentVC as? YXShareOptionsListViewController {
                    
                    if vc.listViewModel.stockPrice > 0{
                        vc.loadFirstPage()
                    }
                }
            case .listStyle:
                if let currentVC = self.currentVC, let vc = currentVC as? ShareOptionNewListViewController {
                    if vc.listViewModel.stockPrice > 0{
                        vc.loadFirstPage()
                    }
                }
            }
            shouldGetData = false
        }
    }
    
    func setUI() {
        
        view.backgroundColor = QMUITheme().foregroundColor()
        
        view.addSubview(tabView)
        view.addSubview(dateTabView)
        view.addSubview(pageView)
        view.addSubview(noOptionsView)

        
        if vm.style == .inMarket {
//            navigationItem.rightBarButtonItems = [collegeNavItem]
            view.addSubview(stockView)
            
            view.addSubview(filterView)
            
            filterView.snp.makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
                make.right.equalToSuperview()
             
                make.height.equalTo(54)
            }
            
            stockView.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                }
                make.right.equalToSuperview()
                make.top.equalTo(self.strongNoticeView.snp.bottom)
                make.height.equalTo(68)
            }
            
            dateTabView.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                }
                make.top.equalTo(stockView.snp.bottom)
                make.right.equalToSuperview()
                make.height.equalTo(48)
            }
            
            pageView.snp.makeConstraints { (make) in
                make.bottom.equalTo(filterView.snp.top)
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                }
                make.right.equalToSuperview()
                make.top.equalTo(dateTabView.snp.bottom)
            }
            
        }else {
            dateTabView.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                }
                make.top.equalTo(self.strongNoticeView.snp.bottom)
                make.right.equalToSuperview()
                make.height.equalTo(48)
            }
            
            pageView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.left.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.equalToSuperview()
                }
                make.right.equalToSuperview()
                make.top.equalTo(dateTabView.snp.bottom)
            }
        }
        
        noOptionsView.snp.makeConstraints { (make) in
            make.top.equalTo(dateTabView).offset(6)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    override init(viewModel: YXViewModel) {
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        self.quoteRequest?.cancel()
    }
}

extension YXShareOptionsViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        if let list = self.vm.dateModel?.list {
            if let date = list[Int(index)].maturityDate {
                if date == self.currentDate {
                    return
                }else {
                    self.currentDate = date
                    self.vm.allVM.maturityDate = date
                    self.vm.callVM.maturityDate = date
                    self.vm.putVM.maturityDate = date
                    
                    //切换时间 控制器需要滚到中间
                    switch self.vm.listStyle {
                    case .straddleStyle:
                        if let vc = self.currentVC as? YXShareOptionsListViewController {
                            if vc.listViewModel.stockPrice > 0{
                                vc.loadFirstPage()
                                self.vm.allVC.shouldScrollToMiddle = true
                                self.vm.callVC.shouldScrollToMiddle = true
                                self.vm.putVC.shouldScrollToMiddle = true
                            }
                        }
                    case .listStyle:
                        if let vc = self.currentVC as? ShareOptionNewListViewController {
                            if vc.listViewModel.stockPrice > 0{
                                vc.loadFirstPage()
                                self.vm.allNewListVC.shouldScrollToMiddle = true
                                self.vm.callNewListVC.shouldScrollToMiddle = true
                                self.vm.putNewListVC.shouldScrollToMiddle = true
                            }
                        }
                    }
                    
                    
                }
            }
        }
        
    }
}

//无期权权限展示
extension YXShareOptionsViewController {

    func createNewUI() {

        if self.isViewLoaded, self.emptyScrollView != nil {

            self.emptyScrollView?.isHidden = true
            self.emptyScrollView?.removeFromSuperview()
            self.emptyScrollView = nil

            setUI()
            if let quote = self.quote,let price = quote.latestPrice?.value, price > 0 {
                self.updateStockInfo(quote: self.quote)
            } else {
                if vm.market.count > 0, vm.symbol.count > 0 {
                    let secu = Secu.init(market: vm.market, symbol: vm.symbol)
                    let level = YXUserManager.shared().getLevel(with: vm.market)//YXUserManager.shareInstance().getCurLevel(withMarket: vm.market)
                    self.quoteRequest?.cancel()
                    self.quoteRequest = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: [secu], level: level, handler: { [weak self] (quotes, scheme) in
                        guard let `self` = self else { return }
                        let quote = quotes.first
                        self.updateStockInfo(quote: quote)
                    })
                }
            }
            getDate()
        }
    }

    
    func addEmptyView() {

        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        self.emptyScrollView = scrollView
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let emptyView = YXStockEmptyDataView()
        
        if YXUserManager.shared().getOptionLevel() != .delay {
            emptyView.imageView.image = UIImage(named: "network_nodata")
        } else {
            emptyView.imageView.image = YXDefaultEmptyEnums.noPermission.image()
        }
        
        emptyView.textLabel.text = YXLanguageUtility.kLang(key: "option_no_permission")
        emptyView.textLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        emptyView.setCenterYOffset(-100)
        scrollView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        emptyView.addSubview(emptybutton)

        emptybutton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyView.textLabel.snp.bottom).offset(15)
            make.height.equalTo(30)
        }

        self.view.addSubview(emptyView)
    }
}

extension YXShareOptionsViewController: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView {
        if let scrollView = self.emptyScrollView {
            return scrollView
        }
        if let vc = self.currentVC as? YXShareOptionsListViewController {
            return vc.tableView
        }
        
        if let vc = self.currentVC as? ShareOptionNewListViewController {
            return vc.tableView
        }
        return  UIScrollView()
    }
    
}
