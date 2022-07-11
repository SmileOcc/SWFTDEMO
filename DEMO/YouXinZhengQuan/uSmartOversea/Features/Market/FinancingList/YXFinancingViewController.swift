//
//  YXFinancingViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXFinancingUIStyle {
    case normal
    case search
}

class YXFinancingViewController: YXHKViewController {
    
    var viewModel = YXFinancingViewModel()
    
    var selectedTabIndex: UInt = 0
    
    var preSearchText: String?
    var preSearchTypes: [YXSearchType]?

    var didSelectedSearchResultItem: ((_ item: YXSearchItem) -> Void)?
    
    var headerViewHeight: CGFloat = 40.0
    
    let bannerHeight = (YXConstant.screenWidth - 18 * 2)/4.0 // 4:1
    
    lazy var bannerView: YXBannerView = {
        let view = YXBannerView(imageType: .four_one)
        view.requestSuccessBlock = { [weak self] in
            guard let `self` = self else { return }
            self.showBanner()
        }
        view.requestFailedBlock = {[weak self] in
            guard let `self` = self else { return }
            self.hideBanner()
        }
        return view
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage.init(named: "notice")
        
        let noteLabelBgView = UIView()
        noteLabelBgView.backgroundColor = QMUITheme().normalStrongNoticeBackgroundColor()
        
        let noteLabel = QMUILabel()
//        noteLabel.qmui_lineHeight = 15
        noteLabel.text = YXLanguageUtility.kLang(key: "market_dailyFunding_notice")
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textColor = QMUITheme().foregroundColor()
        noteLabel.numberOfLines = 0
        noteLabel.adjustsFontSizeToFitWidth = true
        noteLabel.minimumScaleFactor = 0.3
        
        noteLabelBgView.addSubview(noteLabel)
        noteLabelBgView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(15)
        }
        
        noteLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(6)
            make.top.equalTo(iconImageView).offset(-2)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        view.addSubview(self.bannerView)
        view.addSubview(noteLabelBgView)
        
        self.bannerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(0)
        }
        
        noteLabelBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerViewHeight)
        
        return view
    }()
    
    lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView.init(delegate: self)
        return tabPageView
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.lineColor = QMUITheme().themeTextColor()
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.linePadding = 1
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        
        if (self.viewModel.uiStyle == .search) {
            if YXUserManager.isIntraday(YXMarketType.HK.rawValue), YXUserManager.isIntraday(YXMarketType.US.rawValue) {
                tabView.titles = [YXMarketType.HK.name, YXMarketType.US.name]
            }else if YXUserManager.isIntraday(YXMarketType.HK.rawValue) {
                tabView.titles = [YXMarketType.HK.name]
            }else if YXUserManager.isIntraday(YXMarketType.US.rawValue) {
                tabView.titles = [YXMarketType.US.name]
            }
        }else {
            tabView.titles = [YXMarketType.HK.name, YXMarketType.US.name]
        }
        
        tabView.pageView = self.pageView
        tabView.delegate = self
        
        let line = UIView.line()
        tabView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = true
        
        if (self.viewModel.uiStyle == .search) {
            if YXUserManager.isIntraday(YXMarketType.HK.rawValue), YXUserManager.isIntraday(YXMarketType.US.rawValue) {
                pageView.viewControllers = [self.hkVC, self.usVC]
            }else if YXUserManager.isIntraday(YXMarketType.HK.rawValue) {
                pageView.viewControllers = [self.hkVC]
            }else if YXUserManager.isIntraday(YXMarketType.US.rawValue) {
                pageView.viewControllers = [self.usVC]
            }
        }else {
            pageView.viewControllers = [self.hkVC, self.usVC]
        }
        
        return pageView
    }()
    
    lazy var hkVC: YXStockDetailIndustryVC = {
        return creatViewController(withMarket: YXMarketType.HK.rawValue)
    }()
    
    lazy var usVC: YXStockDetailIndustryVC = {
        return creatViewController(withMarket: YXMarketType.US.rawValue)
    }()
    
    lazy var searchBar: YXNewSearchBar = {
        let searchBar = YXNewSearchBar()

        return searchBar
    }()
    
    lazy var searchBarView: UIView = {
        let view = UIView()
        view.addSubview(self.searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(33)
        }

        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var searchViewModel: YXNewSearchViewModel = {
        let searchViewModel = YXNewSearchViewModel()
        searchViewModel.dailyMargin = 2 // 用来过滤日内融数据，0：全部 1：非日内融 2： 日内融
        searchViewModel.types = [.hk]

        _ = searchViewModel.resultViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
            self?.navigationController?.popViewController(animated: true)
            if let action = self?.didSelectedSearchResultItem {
                action(item)
            }
        })
        
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            searchViewModel.services = appDelegate.appServices
        }
        
        return searchViewModel
    }()
    
    lazy var resultController: YXSearchListController = {
        let viewController = UIStoryboard.init(name: "YXSearchViewController", bundle: nil).instantiateViewController(withIdentifier: "YXSearchListController") as! YXSearchListController
        viewController.newType = true
        viewController.viewModel = self.searchViewModel.resultViewModel
        viewController.viewModel?.types = self.searchViewModel.types
        viewController.ishiddenLikeButton = true
        viewController.view.isHidden = true

        return viewController
    }()
    
    func setupSearchBar() {
        
//        searchBar.cameraBtn.isHidden = true
        searchBar.textField.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(0)
        }
        
        searchBar.textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)
        
        _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self](_) in
            self?.searchBar.textField.text = nil
            self?.searchBar.textField.resignFirstResponder()
            self?.hideResultView()
        })
        
        _ = searchBar.textField.rx.controlEvent(.editingDidEndOnExit).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (e) in
            if let count = self?.searchViewModel.resultViewModel.list.value?.count(), count == 1 {
                self?.searchViewModel.resultViewModel.cellTapAction(at: 0)
            }
        })
        
        _ = searchBar.textField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).filter({ [weak self](text) -> Bool in
            if text?.count ?? 0 > 0 {
                // 这些逻辑是为了解决当从港股tab切刀美股tab时，也会触发搜索动作，但是这时候searchViewModel的type还没更新，导致切到美股时搜索的还是港股的
                // 所以这里加判断，如果是之前搜索过的，就返回fasle不再触发搜索，等type更新后再执行搜索动作
                if let preSearchText = self?.preSearchText, let preSearchTypes = self?.preSearchTypes {
                    if text != preSearchText || self?.searchViewModel.types != preSearchTypes {
                        return true
                    }else {
                        return false
                    }
                }else {
                    return true
                }
            }else {
                return false
            }
            
        }).subscribe(onNext: { [weak self] (text) in
            guard let strongSelf = self else { return }

            if let text = text,text != "" {
                strongSelf.preSearchText = text
                strongSelf.preSearchTypes = strongSelf.searchViewModel.types
                _ = strongSelf.searchViewModel.search(text: text)
            } else {
                self?.hideResultView()
            }
        })
        
        //监听搜索结果
        _ = searchViewModel.resultViewModel.list.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            self?.showResultView()
        })
    }
    
    func showResultView() {
        self.resultController.view.isHidden = false
    }
    
    func hideResultView() {
        self.resultController.view.isHidden = true
    }
    
    func creatViewController(withMarket market: String) -> YXStockDetailIndustryVC {
        let vc = YXStockDetailIndustryVC()
        vc.viewModel.navigator = self.viewModel.navigator
        vc.viewModel.code = self.viewModel.rankType.rankCode
        vc.viewModel.market = market
        vc.viewModel.rankType = self.viewModel.rankType
        if self.viewModel.uiStyle == .search {
            vc.isForDayMarginSearch = true
        }
        if vc.viewModel.rankType == .marginAble {
            vc.viewModel.sorttype = .marginRatio
        }
        return vc
    }
    
    func getBanner() {
        if viewModel.rankType == .dailyFunding, viewModel.uiStyle == .normal {
            bannerView.requestBannerInfo(.dailyFunding)
        }
    }
    
    func showBanner() {
        self.headerViewHeight = 40.0 + self.bannerHeight + 15 * 2
        self.bannerView.snp.updateConstraints { (make) in
            make.height.equalTo(self.bannerHeight)
        }
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerViewHeight)
        self.tabPageView.reloadData()
    }
    
    func hideBanner() {
        self.headerViewHeight = 40.0
        self.bannerView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerViewHeight)
        self.tabPageView.reloadData()
    }
    
    func setUI() {
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }
            self.getBanner()
            if self.tabView.selectedIndex == 0 {
                if let refreshBlock = self.hkVC.refreshHeader.refreshingBlock {
                    refreshBlock()
                }
            }else {
                if let refreshBlock = self.usVC.refreshHeader.refreshingBlock {
                    refreshBlock()
                }
            }
            self.tabPageView.mainTableView.mj_header.endRefreshing()
        }

        tabPageView.mainTableView.mj_header = refreshHeader
        
        view.addSubview(tabPageView)
        
        tabPageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(YXConstant.navBarHeight())
        }
    }
    
    func setSearchUI() {
        view.addSubview(tabView)
        view.addSubview(searchBarView)
        view.addSubview(pageView)
        
        view.addSubview(resultController.view)
        
        self.addChild(resultController)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(YXConstant.navBarHeight())
            make.height.equalTo(40)
        }
        
        searchBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.height.equalTo(60)
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchBarView.snp.bottom)
        }
        
        resultController.view.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.bottom.left.right.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.rankType.title
        
        if viewModel.uiStyle == .search {
            setupSearchBar()
            setSearchUI()
        }else {
            setUI()
        }
        
        if self.viewModel.market == .US {
            if tabView.titles.count > 1 {
                tabView.reloadData()
                tabView.selectTab(at: 1)
            }else {
                self.searchViewModel.types = [.us]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBanner()
    }

}

extension YXFinancingViewController: YXTabPageViewDelegate {
    func headerViewInTabPage() -> UIView {
        if self.viewModel.rankType == .dailyFunding {
            return self.headerView
        }else {
            return UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: 5.0))
        }
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        if self.viewModel.rankType == .dailyFunding {
            return headerViewHeight
        }else {
            return 5
        }
    }
    
    func tabViewInTabPage() -> YXTabView {
        return self.tabView
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        return 40
    }
    
    func pageViewInTabPage() -> YXPageView {
        return self.pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return YXConstant.screenHeight - 40.0 - YXConstant.navBarHeight()
    }
}

extension YXFinancingViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        if index == selectedTabIndex {
            return
        }
        
        if index == 0 {
            self.searchViewModel.types = [.hk]
        }else if index == 1 {
            self.searchViewModel.types = [.us]
        }
        
        if let text = self.searchBar.textField.text, text != "" {
            self.searchViewModel.search(text: text)
        }else {
            self.hideResultView()
        }
        
        selectedTabIndex = index
    }
}
