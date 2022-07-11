//
//  YXAStockMarketViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXA_HKDirection: String {
    case south = "south"
    case north = "north"
}

enum YXA_HKMarket: String {
    case sh = "sh" // 沪股通
    case sz = "sz" // 深股通
    case hs = "hs" // A股通
    case hk = "hk" // 港股通
    case hksh = "hksh" // 港股通沪
    case hksz = "hksz" // 港股通深
    
    var name: String {
        switch self {
        case .sh:
            return YXLanguageUtility.kLang(key: "markets_news_sh_connect")
        case .sz:
            return YXLanguageUtility.kLang(key: "markets_news_sz_connect")
        case .hs:
            return YXLanguageUtility.kLang(key: "bubear_cn_connect")
        case .hk:
            return YXLanguageUtility.kLang(key: "bubear_hk_connect")
        case .hksh:
            return YXLanguageUtility.kLang(key: "bubear_shhk_connect")
        case .hksz:
            return YXLanguageUtility.kLang(key: "bubear_szhk_connect")
        }
    }
    
    var code: String {
        switch self {
        case .sh:
            return "SHHK_ALL"
        case .sz:
            return "SZHK_ALL"
        case .hs:
            return "CONNECT_ALL"
        case .hk:
            return "HKCONNECT_ALL"
        default:
            return ""
        }
    }
    
    var klineCode: String {
        switch self {
        case .sh:
            return "HKSCSH"
        case .sz:
            return "HKSCSZ"
        case .hs:
            return "HKSCHS"
        case .hk:
            return "HSSCHK"
        case .hksh:
            return "SHSCHK"
        case .hksz:
            return "SZSCHK"
        }
    }
    
    var direction: YXA_HKDirection {
        switch self {
        case .sh:
            return .north
        case .sz:
            return .north
        case .hs:
            return .north
        case .hk:
            return .south
        case .hksh:
            return .south
        case .hksz:
            return .south
        }
    }

}

class YXA_HKMarketViewController: YXViewController {
    
    var a_hkViewModel: YXA_HKMarketViewModel {
        let vm = viewModel as! YXA_HKMarketViewModel
        return vm
    }
    
    var disposeBag = DisposeBag()
    
    var tabPageScrollBlock: YXTabPageScrollBlock?
    
    let headerViewHeight: CGFloat = 418.0
    
    var visiblePageVC: YXA_HKRankPageViewController?
    
    var selectedTabButton: UIButton!

    var networkingHUD: YXProgressHUD = YXProgressHUD()
    var showNoticeView = false
    let noticeHeight: CGFloat = 26
    var userLevelChange = false
    
    lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView.init(delegate: self)
        tabPageView.mainTableView.backgroundColor = UIColor.clear
        
        return tabPageView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: headerViewHeight))
        view.backgroundColor = QMUITheme().foregroundColor()
        let greyView = UIView()
        greyView.backgroundColor = QMUITheme().backgroundColor()
        view.addSubview(amountView)
        view.addSubview(chartView)
        view.addSubview(greyView)
        amountView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(13)
            make.height.equalTo(76)
        }
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(amountView.snp.bottom).offset(10)
            make.bottom.equalTo(greyView.snp.top)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        greyView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
        return view
    }()
    
    lazy var amountView: YXA_HKFundAmountView = {
        let view = YXA_HKFundAmountView()
        view.direction = self.a_hkViewModel.direction
        return view
    }()
    
    lazy var chartView: YXA_HKKLineView = {
        var direct: YXA_HKKLineDirection
        if a_hkViewModel.direction == .north {
            direct = YXA_HKKLineDirectionNorth
        }else {
            direct = YXA_HKKLineDirectionSouth
        }
        let view = YXA_HKKLineView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth-30, height: 300), andType: direct)
        view.backgroundColor = QMUITheme().foregroundColor()
        view.loadMoreCallBack = { [weak self] in
            guard let `self` = self else { return }
            if self.a_hkViewModel.hasMoreKlineDatas {
                self.requestKlineData()
            }
        }
        return view
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.linePadding = 1
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.titles = [YXA_HKMarket.sh.name, YXA_HKMarket.hs.name, YXA_HKMarket.sz.name]
        tabView.delegate = self
        
        tabView.addSubview(rankMarketTabView)
        
        rankMarketTabView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        return tabView
    }()
    
    lazy var rankMarketTabView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        let items: [YXA_HKMarket] = [.sh, .hs, .sz]
        let titles = [YXLanguageUtility.kLang(key: "markets_news_sh_connect_wrap"), YXLanguageUtility.kLang(key: "bubear_cn_connect_wrap"), YXLanguageUtility.kLang(key: "markets_news_sz_connect_wrap"),]
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 9
        
        for (index, item) in items.enumerated() {
            let button = UIButton()
            button.tag = index
            button.setTitle(titles[index], for: .normal)
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.layer.cornerRadius = 4
            button.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor
            button.layer.borderWidth = 1
            button.titleLabel?.numberOfLines = 2
            
            // 默认选中第一个
            if index == 0 {
                button.isSelected = true
                button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
                button.layer.borderColor = QMUITheme().themeTextColor().cgColor
                selectedTabButton = button
            }
            button.addTarget(self, action: #selector(setFilterButtonSelected(button:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.width.equalTo(80)
                make.height.equalTo(35)
            }
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(35)
        }
        
        return view
    }()
        
    @objc func setFilterButtonSelected(button: UIButton) {
        if button.isSelected {
            return
        }else {
            selectedTabButton.isSelected = false
            selectedTabButton.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
            selectedTabButton.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1).cgColor

            button.isSelected = true
            button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
            button.layer.borderColor = QMUITheme().themeTextColor().cgColor
            selectedTabButton = button

            tabView.selectTab(at: UInt(button.tag))
        }
    }
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        if a_hkViewModel.direction == YXA_HKDirection.south {
            let rankPageViewModel = YXA_HKRankPageViewModel.init(services:a_hkViewModel.services, market: .hk)
            let rankPageVC = YXA_HKRankPageViewController.init(viewModel: rankPageViewModel) ?? YXA_HKRankPageViewController()
            pageView.viewControllers = [rankPageVC]
        }else {
            let shRankPageViewModel = YXA_HKRankPageViewModel.init(services:a_hkViewModel.services, market: .sh)
            let shRankPageVC = YXA_HKRankPageViewController.init(viewModel: shRankPageViewModel) ?? YXA_HKRankPageViewController()
            
            let hsRankPageViewModel = YXA_HKRankPageViewModel.init(services:a_hkViewModel.services, market: .hs)
            let hsRankPageVC = YXA_HKRankPageViewController.init(viewModel: hsRankPageViewModel) ?? YXA_HKRankPageViewController()
            
            let szRankPageViewModel = YXA_HKRankPageViewModel.init(services:a_hkViewModel.services, market: .sz)
            let szRankPageVC = YXA_HKRankPageViewController.init(viewModel: szRankPageViewModel) ?? YXA_HKRankPageViewController()
            
            pageView.viewControllers = [shRankPageVC, hsRankPageVC, szRankPageVC]
        }

        return pageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visiblePageVC = pageView.viewControllers[0] as? YXA_HKRankPageViewController
        setupUI()
        requestFundAmount()
        requestKlineData()

        if self.a_hkViewModel.direction == .south {

            _ = NotificationCenter.default.rx
                .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
                .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
                .subscribe(onNext: { [weak self] noti in
                    guard let `self` = self else { return }

                    if self.showNoticeView {
                        self.hiddenQuoteNoticeView()
                    } else {
                        self.showQuoteNoticeView()
                    }

                }).disposed(by: rx.disposeBag)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.a_hkViewModel.direction == .south {
            if self.userLevelChange {
                self.tabPageView.mainTableView.mj_header?.refreshingBlock()
            }
        }
    }
    
    func requestFundAmount() {
        a_hkViewModel.getFundAmount().subscribe(onSuccess: { [weak self](model) in
            self?.amountView.model = model
        }).disposed(by: disposeBag)
    }
    
    func requestKlineData() {
        a_hkViewModel.getKlineData().subscribe(onSuccess: { [weak self](model) in
            guard let `self` = self else {return}
            // 每次请求60条，如果小于60，说明是第一次请求，需要reset
            if self.a_hkViewModel.klineDatas.count > 0, self.a_hkViewModel.klineDatas.count <= 60 {
                self.chartView.resetData()
            }
            self.chartView.dataSource = self.a_hkViewModel.klineDatas
        }).disposed(by: disposeBag)
    }

    func setupUI() {

        if self.a_hkViewModel.direction == .south {
            self.showNoticeView = YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketHK)
        }
        view.addSubview(self.noticeView)
        view.addSubview(tabPageView)

        self.noticeView.snp.makeConstraints { (make) in
            make.right.left.top.equalToSuperview()
            make.height.equalTo(self.showNoticeView ? self.noticeHeight : 0)
        }
        self.noticeView.isHidden = !self.showNoticeView
        
        tabPageView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(self.noticeView.snp.bottom)

        }
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            if let vc = self?.visiblePageVC?.currentPageViewController as? YXA_HKRankListViewController {
                vc.refreshData()
            }else if let vc = self?.visiblePageVC?.currentPageViewController as? YXStockDetailIndustryVC {
                if let refreshingBlock = vc.refreshHeader.refreshingBlock {
                    refreshingBlock()
                }
            }
            self?.requestFundAmount()
            self?.a_hkViewModel.offset = 0
            self?.requestKlineData()
            self?.tabPageView.mainTableView.mj_header.endRefreshing()
        }
        
        tabPageView.mainTableView.mj_header = refreshHeader
        
        tabPageView.reloadData()
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

}

extension YXA_HKMarketViewController {

    func showQuoteNoticeView() {
        if self.noticeView.isHidden, YXQuoteKickTool.shared.isQuoteLevelKickToDelay(kYXMarketHK) {
            self.showNoticeView = true

            self.noticeView.isHidden = false
            self.noticeView.snp.updateConstraints { (make) in
                make.height.equalTo(self.noticeHeight)
            }
            self.tabPageView.reloadData()

            if self.qmui_isViewLoadedAndVisible() {
                self.tabPageView.mainTableView.mj_header?.refreshingBlock()
            } else {
                self.userLevelChange = true
            }

        }
    }

    func hiddenQuoteNoticeView() {
        if self.noticeView.isHidden == false && (YXQuoteKickTool.shared.currentQuoteLevleIsReal(kYXMarketHK) || !YXUserManager.isLogin()) {
            self.showNoticeView = false

            self.noticeView.isHidden = true
            self.noticeView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            self.tabPageView.reloadData()

            if self.qmui_isViewLoadedAndVisible() {
                self.tabPageView.mainTableView.mj_header?.refreshingBlock()
            } else {
                self.userLevelChange = true
            }
        }
    }

}


extension YXA_HKMarketViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        
    }
}

extension YXA_HKMarketViewController: YXTabPageViewDelegate {
    func headerViewInTabPage() -> UIView {
        self.headerView
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        headerViewHeight
    }
    
    func tabViewInTabPage() -> YXTabView {
        if a_hkViewModel.direction == YXA_HKDirection.south {
            return YXTabView()
        }else {
            return self.tabView
        }
        
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        if a_hkViewModel.direction == YXA_HKDirection.south {
            return 0.0
        }else {
            return 60
        }
    }
    
    func pageViewInTabPage() -> YXPageView {
        self.pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        if a_hkViewModel.direction == YXA_HKDirection.south {
            return self.view.bounds.size.height
        }else {
            return self.view.bounds.size.height - 40 - (self.showNoticeView ? self.noticeHeight : 0)
        }
    }
}

