//
//  YXA-HKRankTableViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKRankTypeButton: UIButton {
    var type: YXA_HKRankType = .fundDirection
}

class YXA_HKRankPageViewController: YXViewController {
    
    var rankPageViewModel: YXA_HKRankPageViewModel {
        let vm = viewModel as! YXA_HKRankPageViewModel
        return vm
    }
    
    var currentPageViewController: UIViewController?
    
    @objc var tabPageViewScrollCallBack: YXTabPageScrollBlock?
    
    var tabTitles: [String] = []
    
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
        tabView.titles = tabTitles
        
        tabView.delegate = self
        tabView.pageView = self.pageView
        
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
        
        let fundDirectionViewModel = YXA_HKRankListViewModel.init(services: viewModel.services, type: .fundDirection, market: rankPageViewModel.marketType)
        let fundDirectionVC = YXA_HKRankListViewController.init(viewModel: fundDirectionViewModel) ?? YXA_HKRankListViewController()
        
        let rocVC = YXStockDetailIndustryVC()
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            rocVC.viewModel.navigator =  root.navigator
        }
        rocVC.viewModel.code = rankPageViewModel.marketType.code
        rocVC.viewModel.market = rankPageViewModel.marketType.rawValue
        
        let volumeViewModel = YXA_HKRankListViewModel.init(services: viewModel.services, type: .volume, market: rankPageViewModel.marketType)
        let volumeVC = YXA_HKRankListViewController.init(viewModel: volumeViewModel) ?? YXA_HKRankListViewController()
        
        if rankPageViewModel.marketType.direction == .north {
            let limitWarningViewModel = YXA_HKRankListViewModel.init(services: viewModel.services, type: .limitWarning, market: rankPageViewModel.marketType)
            let limitWarningVC = YXA_HKRankListViewController.init(viewModel: limitWarningViewModel) ?? YXA_HKRankListViewController()
            pageView.viewControllers = [fundDirectionVC, rocVC, volumeVC, limitWarningVC]
        }else {
            pageView.viewControllers = [fundDirectionVC, rocVC, volumeVC]
        }
        
        return pageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if rankPageViewModel.marketType.direction == .north {
            tabTitles = [YXA_HKRankType.fundDirection.text, YXA_HKRankType.roc.text, YXA_HKRankType.volume.text, YXA_HKRankType.limitWarning.text]
        }else {
            tabTitles = [YXA_HKRankType.fundDirection.text, YXA_HKRankType.roc.text, YXA_HKRankType.volume.text]
        }
        
        tabView.reloadData()
        currentPageViewController = pageView.viewControllers[0] as? YXA_HKRankListViewController
        
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
        
    }
    
    func refresh() {
        
    }
}

extension YXA_HKRankPageViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        currentPageViewController = pageView.viewControllers[Int(index)]
    }
}

extension YXA_HKRankPageViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        if let vc = currentPageViewController as? YXA_HKRankListViewController {
            return vc.tableView
        }else if let vc = currentPageViewController as? YXStockDetailIndustryVC {
            return vc.tableView
        }else {
            return UIScrollView()
        }
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        tabPageViewScrollCallBack = callback
    }
}

