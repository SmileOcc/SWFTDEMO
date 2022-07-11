//
//  YXCourseListTabViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXCourseListTabViewController: YXHKViewController {
    
    let viewModel = YXCourseListTabViewModel()
    
    var currentPageViewController: YXCourseListViewController?
    
    var scrollCallBack: YXTabPageScrollBlock?

    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = true
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 16
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 24
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 12.5
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 0
        tabLayout.titleFont = .systemFont(ofSize: 14)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 14)
        tabLayout.tabCornerRadius = 4
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.tabColor = QMUITheme().foregroundColor()
        tabLayout.tabSelectedColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        tabLayout.titleSelectedColor = QMUITheme().mainThemeColor()
        
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 24), with: tabLayout)
        tabView.delegate = self
        tabView.pageView = pageView
        tabView.backgroundColor = QMUITheme().foregroundColor()

        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.contentView.isScrollEnabled = false
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var tabContainerView: UIView = {
        let tabContainerView = UIView()
        tabContainerView.backgroundColor = QMUITheme().foregroundColor()
        return tabContainerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QMUITheme().backgroundColor()

        tabContainerView.addSubview(tabView)
        view.addSubview(tabContainerView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        tabContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(40)
        }
        
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabContainerView.snp.bottom)
        }
        
        if let list = viewModel.tabList, list.count > 0 {
            var titles: [String] = []
            var viewControllers: [YXCourseListViewController] = []
            
            for item in list {
                titles.append(item.categoryName ?? "--")
                
                let vc = YXCourseListViewController()
                vc.viewModel.primaryCategory = viewModel.primaryCategory ?? ""
                vc.viewModel.secondaryCategory = item.categoryId ?? "0"
                
                viewControllers.append(vc)
            }
            
            if titles.count < 2 {
                tabView.isHidden = true
                tabContainerView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }else {
                // 插入“全部”
                titles.insert(YXLanguageUtility.kLang(key: "common_all"), at: 0)
                let vc = YXCourseListViewController()
                vc.viewModel.primaryCategory = viewModel.primaryCategory ?? ""
                vc.viewModel.secondaryCategory = "0"
                viewControllers.insert(vc, at: 0)
                
            }
            
            tabView.titles = titles
            tabView.reloadData()
            
            pageView.viewControllers = viewControllers
            pageView.reloadData()
            currentPageViewController = pageView.viewControllers.first as? YXCourseListViewController
        }
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return false
    }
}

extension YXCourseListTabViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        currentPageViewController = pageView.viewControllers[Int(index)] as? YXCourseListViewController
    }
}

extension YXCourseListTabViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        if let vc = currentPageViewController {
            return vc.tableView
        }else {
            return UIScrollView()
        }
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }
}
