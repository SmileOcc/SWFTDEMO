//
//  YXStockFilterTabViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class YXStockFilterTabViewController: YXViewController {
    
    var tabViewModel: YXStockFilterTabViewModel {
        return self.viewModel as! YXStockFilterTabViewModel
    }
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.lineWidth = 16
        tabLayout.linePadding = 1
        tabLayout.lineColor = QMUITheme().themeTextColor()
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        
//        tabView.titles = ["港股", "美股", "沪深"]
        
        let line = UIView.line()
        tabView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        
        tabView.pageView = self.pageView
        tabView.delegate = self
        
        return tabView
    }()
    
    lazy var hkVC: YXStockFilterViewController = {
        return creatStockFilterVC(market: kYXMarketHK)
    }()
    
    lazy var usVC: YXStockFilterViewController = {
        return creatStockFilterVC(market: kYXMarketUS)
    }()
    
    lazy var hsVC: YXStockFilterViewController = {
        return creatStockFilterVC(market: kYXMarketHS)
    }()
    
    func creatStockFilterVC(market: String) -> YXStockFilterViewController {
        let vm = YXStockFilterViewModel.init(services: self.tabViewModel.services, params: ["market": market])
        vm.editModel = tabViewModel.editModel
        vm.operationType = tabViewModel.operateType
        return YXStockFilterViewController.init(viewModel: vm)
    }
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        
        return pageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabViewModel.operateType == .edit {
            if tabViewModel.market == kYXMarketHK {
                pageView.viewControllers = [hkVC]
                tabView.titles = [YXLanguageUtility.kLang(key: "community_hk_stock")]
            }else if tabViewModel.market == kYXMarketUS {
                pageView.viewControllers = [usVC]
                tabView.titles = [YXLanguageUtility.kLang(key: "community_us_stock")]
            }else if tabViewModel.market == kYXMarketHS {
                pageView.viewControllers = [hsVC]
                tabView.titles = [YXLanguageUtility.kLang(key: "sh_sz")]
            }
            self.title = tabViewModel.editModel?.name ?? YXLanguageUtility.kLang(key: "stock_scanner")
        }else {
            pageView.viewControllers = [hkVC, usVC, hsVC]
            tabView.titles = [YXLanguageUtility.kLang(key: "community_hk_stock"), YXLanguageUtility.kLang(key: "community_us_stock"), YXLanguageUtility.kLang(key: "sh_sz")]
            self.title = YXLanguageUtility.kLang(key: "stock_scanner")
        }
        
        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            }
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.tabView.snp.bottom)
        }

        if self.tabViewModel.operateType != .edit {

            let rightBarItem = UIBarButtonItem.init(title: YXLanguageUtility.kLang(key: "my_stock_scanner"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightBarItemAction))

            self.navigationItem.rightBarButtonItems = [rightBarItem]
        }


        if self.tabViewModel.market == kYXMarketHK {
            self.tabView.defaultSelectedIndex = 0
        } else if self.tabViewModel.market == kYXMarketUS {
            self.tabView.defaultSelectedIndex = 1
        } else {
            self.tabView.defaultSelectedIndex = 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

    @objc func rightBarItemAction() {
        if YXUserManager.isLogin() {
            let vm = YXStockFilterGroupViewModel.init(services: self.tabViewModel.services, params: ["market": self.tabViewModel.market])
            self.tabViewModel.services.push(vm, animated: true)


        } else {
            (self.viewModel.services as? NavigatorServices)?.pushToLoginVC(callBack: nil)
        }
    }
}

extension YXStockFilterTabViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {

        let arr = [kYXMarketHK, kYXMarketUS, kYXMarketHS]
        if index < arr.count {
            self.tabViewModel.market = arr[Int(index)]
        }
        
    }
}
