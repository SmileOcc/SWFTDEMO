//
//  YXHotETFListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXHotETFListViewController: YXViewController {
    
    var etfListViewModel: YXHotETFListViewModel {
        let vm = viewModel as! YXHotETFListViewModel
        return vm
    }
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 16
        tabLayout.tabMargin = 8
        tabLayout.tabPadding = 12
        tabLayout.lineHeight = 28
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 4
        tabLayout.lineColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        tabLayout.linePadding = 6
        tabLayout.lineWidth = 0
        tabLayout.titleFont = .systemFont(ofSize: 14)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 14)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        
        let tabView = YXTabView(frame: .zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.delegate = self
        tabView.pageView = pageView;
        tabView.titles = self.etfListViewModel.titles
        
        tabView.clipsToBounds = true
        
//        let gradientView = YXGradientLayerView()
//        gradientView.direction = .horizontal
//        gradientView.colors = [UIColor(hexString: "#FFFFFF")!.withAlphaComponent(0), UIColor(hexString: "#FFFFFF")!]
//        
//        tabView.addSubview(gradientView)
//        gradientView.snp.makeConstraints { (make) in
//            make.top.bottom.right.equalToSuperview()
//            make.width.equalTo(30)
//        }
        
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        pageView.viewControllers = self.etfListViewModel.viewControllers
        return pageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.viewModel.title

        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tabView.selectTab(at: UInt(self.etfListViewModel.selectedIndex))
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabView.reloadData()
    }
}

extension YXHotETFListViewController: YXTabViewDelegate {
    
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        
    }
}
