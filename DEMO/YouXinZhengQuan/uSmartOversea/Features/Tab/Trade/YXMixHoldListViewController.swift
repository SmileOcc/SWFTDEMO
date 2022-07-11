//
//  YXMixHoldListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMixHoldListViewController: YXHKViewController, HUDViewModelBased {
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXMixHoldListViewModel!
    //股票
    lazy var stockHoldListViewCongtroller: YXHoldListViewController = { () -> YXHoldListViewController in
        let vm = YXHoldListViewModel(exchangeType: self.viewModel.exchangeType)
        vm.securityType = .stock
        
        let stockHoldListViewCongtroller = YXHoldListViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        return stockHoldListViewCongtroller
    }()
    //基金
    lazy var fundHoldListViewCongtroller: YXHoldFundListViewController = { () -> YXHoldFundListViewController in
        let viewM = YXHoldFundListViewModel(exchangeType: self.viewModel.exchangeType)
        viewM.securityType = .fund
        
        let vc = YXHoldFundListViewController.instantiate(withViewModel: viewM, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        return vc
    }()
    
    //债券
    lazy var bondHoldListViewCongtroller: YXHoldBondListViewController = { () -> YXHoldBondListViewController in
        let vm = YXHoldBondListViewModel(exchangeType: self.viewModel.exchangeType)
        vm.securityType = .bond
        
        let bondHoldListViewCongtroller = YXHoldBondListViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services, andNavigator: self.viewModel.navigator)
        return bondHoldListViewCongtroller
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        
        pageView.contentView.isScrollEnabled = true
        return pageView
    }()
    
    lazy var tabView: YXTabView = {
        let layout = YXTabLayout.default()
        layout.lineHeight = 4;
        layout.linePadding = 1;
        layout.lineCornerRadius = 2;
        layout.lineWidth = 16;
        layout.titleFont = UIFont.systemFont(ofSize: 16)
        layout.titleSelectedFont = UIFont.systemFont(ofSize: 16)
        layout.titleSelectedColor = QMUITheme().mainThemeColor()
        layout.titleColor = QMUITheme().themeTintColor()
        let tabView = YXTabView.init(frame: CGRect.zero, with: layout)
        tabView.pageView = self.pageView
        tabView.delegate = self
        return tabView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "hold_holds")
        initUI()
    }
    
    private func initUI() {
        
        if YXUserManager.isGray(with: .bond), self.viewModel.exchangeType == .us {
            pageView.viewControllers = [self.stockHoldListViewCongtroller, self.bondHoldListViewCongtroller]
            tabView.titles = [YXLanguageUtility.kLang(key: "hold_stock_name"), YXLanguageUtility.kLang(key: "bond")]
        }else {
            pageView.viewControllers = [self.stockHoldListViewCongtroller]
            tabView.titles = [YXLanguageUtility.kLang(key: "hold_stock_name")]
        }
        
        self.view.addSubview(self.tabView)
        self.view.addSubview(self.pageView)
        self.tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.height.equalTo(50)
        }
        self.pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.tabView.snp.bottom)
        }
        
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    
}

extension YXMixHoldListViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        
    }
}
