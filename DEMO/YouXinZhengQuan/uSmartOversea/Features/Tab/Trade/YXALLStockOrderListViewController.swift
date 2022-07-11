//
//  YXOrderListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

//class YXALLStockOrderListViewController: YXHKViewController, HUDViewModelBased {
//    
//    var networkingHUD: YXProgressHUD! = YXProgressHUD()
//    
//    var viewModel: YXAllStockOrderListViewModel!
//    
//    lazy var hkStockOrderListViewCongtroller: YXOrderListViewController = {
//        viewController(exchangeType: .hk)
//    }()
//    
//    lazy var usStockOrderListViewCongtroller: YXOrderListViewController = {
//        viewController(exchangeType: .us)
//    }()
//    
//    lazy var hsStockOrderListViewCongtroller: YXOrderListViewController = {
//        viewController(exchangeType: .hs)
//    }()
//    
//    lazy var pageView: YXPageView = {
//        let pageView = YXPageView(frame: view.bounds)
//        pageView.parentViewController = self
//        pageView.viewControllers = [self.hkStockOrderListViewCongtroller, self.usStockOrderListViewCongtroller, self.hsStockOrderListViewCongtroller]
//        pageView.contentView.isScrollEnabled = true
//        return pageView
//    }()
//    
//    lazy var tabView: YXTabView = {
//        let layout = YXTabLayout.default()
//        layout.lineHeight = 4;
//        layout.linePadding = 1;
//        layout.lineCornerRadius = 2;
//        layout.lineWidth = 16;
//        layout.titleFont = UIFont.systemFont(ofSize: 16)
//        layout.titleSelectedFont = UIFont.systemFont(ofSize: 16)
//        
//        layout.titleSelectedColor = QMUITheme().mainThemeColor()
//        layout.titleColor = QMUITheme().themeTintColor()
//        layout.lineColor = QMUITheme().mainThemeColor()
//        let tabView = YXTabView.init(frame: CGRect.zero, with: layout)
//        tabView.titles = [YXLanguageUtility.kLang(key: "community_hk_stock"), YXLanguageUtility.kLang(key: "community_us_stock"), YXLanguageUtility.kLang(key: "community_cn_stock")]
//        tabView.pageView = self.pageView
//        tabView.delegate = self
//        
//        return tabView
//    }()
//    
//    func viewController(exchangeType: YXExchangeType) -> YXOrderListViewController {
//        let stockViewModel = YXOrderListViewModel(exchangeType: exchangeType, allOrderType: self.viewModel.allOrderType)
//        stockViewModel.showExpand = false
//        if let type = self.viewModel.externParams["exchangeType"] as? YXExchangeType, type == exchangeType {
//            stockViewModel.setExternParams(self.viewModel.externParams)
//        }
//        let stockOrderListViewCongtroller = YXOrderListViewController.instantiate(withViewModel: stockViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
//        return stockOrderListViewCongtroller
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        initUI()
//        
//        tabView.reloadData()
//        
//        if self.viewModel.exchangeType == .hk {
//            tabView.selectTab(at: 0)
//        }else if self.viewModel.exchangeType == .us {
//            tabView.selectTab(at: 1)
//        }else {
//            tabView.selectTab(at: 2)
//        }
//    }
//    
//    private func initUI() {
//        
//        self.view.addSubview(self.tabView)
//        self.view.addSubview(self.pageView)
//        self.tabView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(self.view)
//            make.top.equalTo(self.strongNoticeView.snp.bottom)
//            make.height.equalTo(50)
//        }
//        self.pageView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(self.view)
//            make.top.equalTo(self.tabView.snp.bottom)
//        }
//        
//        if #available(iOS 11.0, *) {
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
//    }
//
//}
//
//extension YXALLStockOrderListViewController: YXTabViewDelegate {
//    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
//    }
//        
//}
