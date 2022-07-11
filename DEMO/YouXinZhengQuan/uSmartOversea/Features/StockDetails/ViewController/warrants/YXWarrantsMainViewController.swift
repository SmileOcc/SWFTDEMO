//
//  YXWarrantsMainViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/1/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsMainViewController: YXHKViewController, ViewModelBased {
    
    var viewModel: YXWarrantsMainViewModel! = YXWarrantsMainViewModel()
    
    var selectedTab = 0

    @objc lazy var tabView: YXTabView = {
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
        tabLayout.titleSelectedFont = .systemFont(ofSize: 16, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        
        let tabView = YXTabView(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.pageView = pageView;
        tabView.delegate = self
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        return pageView
    }()
    
    lazy var barTitleView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44)
        view.addSubview(self.tabView)
//        self.tabView.snp.makeConstraints { make in
//            make.left.right.top.bottom.equalToSuperview()
//        }
//        view.addSubview(tapButtonView)
//        tapButtonView.snp.makeConstraints { make in
//            make.left.right.top.bottom.equalToSuperview()
//        }
        return view
    }()
    
    @objc lazy var warrantsViewController: YXStockWarrantsViewController = {
        let vc = YXStockWarrantsViewController()
        vc.isHideLZBButton = true
        vc.viewModel.navigator = self.viewModel.navigator
        vc.viewModel.warrantType = YXStockWarrantsType.bullBear
        vc.mainViewController = self
        vc.clearAll()
        return vc
    }()
    
    lazy var warrantsStreetViewModel: YXWarrantsStreetViewModel = {
        YXWarrantsStreetViewModel.init(services: viewModel.navigator, params: nil)
    }()
    
    lazy var warrantStreetViewController: YXWarrantsStreetViewController = {
        let vc = YXWarrantsStreetViewController.init(viewModel: warrantsStreetViewModel)
        vc.mainViewController = self
        return vc
    }()
    
    lazy var inlineWarrantViewController: YXStockWarrantsViewController = {
        let vc = YXStockWarrantsViewController()
        vc.viewModel.warrantType = .inlineWarrants
        vc.viewModel.navigator = self.viewModel.navigator
        vc.mainViewController = self
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = QMUITheme().backgroundColor()
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupUI()
        
        if selectedTab != 0 {
            tabView.reloadData()
            tabView.selectTab(at: UInt(selectedTab))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    lazy var tapButtonView: UIStackView = {
        let stack = UIStackView()
        stack.isUserInteractionEnabled = true
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.axis = .horizontal
        stack.alignment = .fill
        let titles = [YXLanguageUtility.kLang(key: "warrants_bull_bear1"), YXLanguageUtility.kLang(key: "warrants_cbbc"), YXLanguageUtility.kLang(key: "warrants_inline_warrants1")]
        for (index, title) in titles.enumerated() {
            let button = QMUIButton()
            button.tag = index
            button.titleLabel?.numberOfLines = 2
            button.setTitle(title, for: .normal)
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
            button.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.4), for: .normal)
            if index == 0 {
                button.isSelected = true
                button.titleLabel?.font = .systemFont(ofSize: 16)
            }else {
                button.isSelected = false
                button.titleLabel?.font = .systemFont(ofSize: 14)
            }
            
            _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self]_ in
                for view in stack.arrangedSubviews {
                    if let btn = view as? UIButton {
                        btn.isSelected = false
                        btn.titleLabel?.font = .systemFont(ofSize: 14)
                    }
                }
                button.isSelected = true
                button.titleLabel?.font = .systemFont(ofSize: 16)
                self?.tabView.reloadData()
                self?.tabView.selectTab(at: UInt(button.tag))
            })
            button.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            
            button.size = CGSize(width: 44, height: 44)
            
            stack.addArrangedSubview(button)
        }
        return stack
    }()
    
    func setupUI() {
        
        //搜索
        tabView.titles = [YXLanguageUtility.kLang(key: "warrants_bull_bear"), YXLanguageUtility.kLang(key: "warrants_cbbc_distribtion"), YXLanguageUtility.kLang(key: "warrants_inline_warrants")]
        pageView.viewControllers = [warrantsViewController, warrantStreetViewController, inlineWarrantViewController]
        
        self.navigationItem.titleView = self.tabView//self.barTitleView
        
        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }
    
    @objc func searchAction(type: YXStockWarrantsType) {
        let didSelectedItem: (YXSearchItem)->() = { [weak self] (item) in
            guard let `self` = self else { return }
            self.warrantsViewController.didSearchItem(item)
            self.warrantsStreetViewModel.market = item.market
            self.warrantsStreetViewModel.code = item.symbol
            self.warrantsStreetViewModel.name = item.name ?? ""
        }
        let didSearchAll: (Bool)->() = { [weak self] (bool) in
            guard let `self` = self else { return }
            self.warrantsViewController.didSearchAll(bool)
            self.warrantsStreetViewModel.market = ""
            self.warrantsStreetViewModel.code = ""
            self.warrantsStreetViewModel.name = ""
        }
        let dic = ["didSelectedItem": didSelectedItem, "didSearchAll": didSearchAll, "warrantType": type] as [String : Any]
        self.viewModel.navigator.present(YXModulePaths.stockWarrantsSearch.url, context: dic)
    }
    
}

extension YXWarrantsMainViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
    }
}
