//
//  YXAggregatedOrderListViewController.swift
//  uSmartOversea
//
//  Created by Evan on 2021/12/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

enum YXOrderListTabType: Int {
    case normal
    case smart

    var title: String {

        switch self {
        case .normal:
            return YXLanguageUtility.kLang(key: "orders_title")
        case .smart:
            return YXLanguageUtility.kLang(key: "smart_orders_title")
        }
    }
}

/// 订单聚合页
class YXAggregatedOrderListViewController: YXHKViewController, ViewModelBased {

    var viewModel: YXAggregatedOrderListViewModel!
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = true
        tabLayout.lrMargin = 0
        tabLayout.tabMargin = 30
        tabLayout.titleFont = .systemFont(ofSize: 18)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 18, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: 232, height: 44), with: tabLayout)
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

    private lazy var orderListViewController: YXOrderListViewController = {
        let orderListViewModel = YXOrderListViewModel.init(exchangeType: viewModel.exchangeType)
        orderListViewModel.showExpand = false
        let vc = YXOrderListViewController.instantiate(withViewModel: orderListViewModel,
                                                       andServices: viewModel.services,
                                                       andNavigator: viewModel.navigator)
        return vc
    }()

    private lazy var smartOrderListViewController: YXSmartOrderListViewController = {
        var params: [String: Any] = [:]
        if viewModel.exchangeType != nil {
            params["exchangeType"] = viewModel.exchangeType
        }
        let viewModel = YXSmartOrderListViewModel(services: viewModel.navigator, params: params)
        viewModel.isAll = true
        viewModel.shouldInfiniteScrolling = true
        viewModel.shouldPullToRefresh = true
        return YXSmartOrderListViewController(viewModel: viewModel)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = QMUITheme().backgroundColor()
        setupUI()
    }

    func setupUI() {
        fetchViewControllers()

        tabView.defaultSelectedIndex = viewModel.defaultTab.rawValue

        navigationItem.titleView = tabView

        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    func fetchViewControllers() {
        let titles = [YXOrderListTabType.normal.title, YXOrderListTabType.smart.title]
        let controllers = [orderListViewController, smartOrderListViewController]
        tabView.titles = titles
        pageView.viewControllers = controllers
    }
    
    override var pageName: String {
        "All Orders-Orders"
    }
}

extension YXAggregatedOrderListViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        var event = "Orders_tab"
        if index == 1 {
            event = "Smart Order_tab"
        }
        self.trackViewClickEvent(name: event)
    }
}
