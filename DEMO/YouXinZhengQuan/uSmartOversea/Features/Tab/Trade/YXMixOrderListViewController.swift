//
//  YXMixOrderListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//class YXMixOrderListViewController: YXHKViewController, HUDViewModelBased {
//    var networkingHUD: YXProgressHUD! = YXProgressHUD()
//    
//    var viewModel: YXMixOrderListViewModel!
//    
//    lazy var stockOrderListViewCongtroller: YXOrderListViewController = { () -> YXOrderListViewController in
//        let stockViewModel = YXOrderListViewModel(exchangeType: .us)
//        
//        let stockOrderListViewCongtroller = YXOrderListViewController.instantiate(withViewModel: stockViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
//        return stockOrderListViewCongtroller
//    }()
//    
//    lazy var bondOrderListViewCongtroller: YXOrderBondListViewController = { () -> YXOrderBondListViewController in
//        let bondViewModel = YXOrderBondListViewModel(exchangeType: .us)
//        
//        let bondOrderListViewCongtroller = YXOrderBondListViewController.instantiate(withViewModel: bondViewModel, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
//        return bondOrderListViewCongtroller
//    }()
//    
//    lazy var pageView: YXPageView = {
//        let pageView = YXPageView(frame: view.bounds)
//        pageView.parentViewController = self
//        pageView.viewControllers = [self.stockOrderListViewCongtroller, self.bondOrderListViewCongtroller]
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
//        let tabView = YXTabView.init(frame: CGRect.zero, with: layout)
//        tabView.titles = [YXLanguageUtility.kLang(key: "hold_stock_name"), YXLanguageUtility.kLang(key: "bond")]
//        tabView.pageView = self.pageView
//        tabView.delegate = self
//        
//        return tabView
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = YXLanguageUtility.kLang(key: "hold_orders")
//        initUI()
//        
//        if self.viewModel.securityType == .bond {
//            self.tabView.defaultSelectedIndex = 1
//        }else {
//            self.tabView.defaultSelectedIndex = 0
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
//}
//
//extension YXMixOrderListViewController: YXTabViewDelegate {
//    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
//    }
//        
//}
