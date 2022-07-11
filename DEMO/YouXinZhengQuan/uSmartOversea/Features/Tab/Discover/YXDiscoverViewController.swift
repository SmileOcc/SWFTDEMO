//
//  YXDiscoverViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

enum YXDiscoverTabType {
    case community
    case opportunity
    case news

    
    var title: String {
        
        switch self {
        case .community:
            return YXLanguageUtility.kLang(key: "discover_community")
        case .opportunity:
            return YXLanguageUtility.kLang(key: "discover_opportunity")
        case .news:
            return YXLanguageUtility.kLang(key: "common_news")
        }
    }
    
    var tabIndex: UInt {
        switch self {
        case .community:
            return 0
        case .opportunity:
            return 1
        case .news:
            return 2
        }
    }
}

class YXDiscoverViewController: YXHKViewController, ViewModelBased {
    
    var viewModel: YXDiscoverViewModel!
    
    let marketCurrentTabIndexKey = "YXMarketCurrentTabIndexKey"
    
    var showCryptos = true
    
    
    override var pageName: String {
          return "Discover"
    }
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 0
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 4
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 22, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.delegate = self
        tabView.pageView = pageView;
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.useCache = true
        pageView.parentViewController = self
        return pageView
    }()
    
//    lazy var communityViewController: YXCommunityViewController = {
//        let communityViewModel = YXCommunityViewModel.init()
//        let communitVC = YXCommunityViewController.instantiate(withViewModel: communityViewModel, andServices: viewModel.services, andNavigator: self.viewModel.navigator)
//        return communitVC
//    }()
    
    lazy var newCommunityViewController: YXCommunityContainViewController = {
        let communityViewModel = YXCommunityContainViewModel.init()
        let communitVC = YXCommunityContainViewController.instantiate(withViewModel: communityViewModel, andServices: viewModel.services, andNavigator: self.viewModel.navigator)
        return communitVC
    }()
    
    lazy var stockSTViewController: YXStockSTWebviewController = {
        let stockSTViewModel = YXStockSTWebViewModel(dictionary: [YXStockSTWebViewModel.kWebViewModelUrl: YXH5Urls.YX_STOCK_KING_URL()])
        let stockST = YXStockSTWebviewController.instantiate(withViewModel: stockSTViewModel, andServices: viewModel.services, andNavigator: self.viewModel.navigator)
        return stockST
    }()
    
    lazy var newsViewController: YXInformationHomeViewController = {
        let newsVM = YXInformationHomeViewModel.init()
        let newsVC = YXInformationHomeViewController.instantiate(withViewModel: newsVM, andServices: viewModel.services, andNavigator: self.viewModel.navigator)
        return newsVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        selectedTabWithTime()
        //封装YXPopManager弹窗管理类，在需要展示弹窗的模块的viewDidLoad中checkPop，内部实现是调用中台弹窗数据接口
        YXPopManager.shared.checkPop(with: YXPopManager.showPageStategy, vc: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabbarVisibleIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //检查弹框
        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageStategy, vc: self)
        
        self.requestNoticeData(urlStr: YXNativeRouterConstant.GOTO_DISCOVER) {[weak self] datas in
            guard let `self` = self else { return }
            if datas.count > 0 {
                self.strongNoticeView.dataSource = datas
            }
        } failed: { errorMsg in

        }
        
    }
    
    func selectedTabWithTime() {
        tabView.reloadData()
        tabView.selectTab(at: YXDiscoverTabType.community.tabIndex)
    }

    func setupUI() {
        
        fetchViewControllers()

        let messageBtn = QMUIButton()
        messageBtn.setImage(UIImage(named: "message"), for: .normal)
        messageBtn.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        messageBtn.qmui_tapBlock = { [weak self] _ in
            self?.trackViewClickEvent(name: "Message_Tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_BROKERS_MSG_CENTER_URL())
        }
        messageBtn.rx.observeWeakly(YXMessageButton.self, "brokerRedIsHidden").subscribe {[weak messageBtn] _ in
            messageBtn?.qmui_shouldShowUpdatesIndicator = !YXMessageButton.brokerRedIsHidden
        }.disposed(by: disposeBag)
        messageBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true

        let spaceItem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceItem.width = 16

        let searchBtn = QMUIButton()
        searchBtn.setImage(UIImage(named: "market_search"), for: .normal)
        searchBtn.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModel.navigator.present(YXModulePaths.aggregatedSearch.url, animated: false)
            self.trackViewClickEvent(name: "Search_Tab")
        }
        searchBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let searchBarButtonItem = UIBarButtonItem(customView: searchBtn)

        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: messageBtn), spaceItem, searchBarButtonItem]

        navigationItem.titleView = tabView

        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.bottom.equalTo(view).offset(-YXConstant.tabBarHeight())
        }
    }
    
    
    func fetchViewControllers(_ needReload: Bool = false) {
        
        var titles = [YXDiscoverTabType.opportunity.title,
                      YXDiscoverTabType.community.title,
                      YXDiscoverTabType.news.title]
        
        var controllers = [stockSTViewController,
                           newCommunityViewController,
                           newsViewController]
        
        tabView.titles = titles
        pageView.viewControllers = controllers
        
        if needReload {
            tabView.reloadData()
            pageView.reloadData()
        }
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
    

}



extension YXDiscoverViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        MMKV.default().set(UInt32(index), forKey: marketCurrentTabIndexKey)
        
        
        if pageView.viewControllers.count >= 2 {
            if index == 0{
                self.trackViewClickEvent(name: "Opportunity_Tab")
            }else if index == 1{
                self.trackViewClickEvent(name: "Community_Tab")
            }
        }
    }
    
}
