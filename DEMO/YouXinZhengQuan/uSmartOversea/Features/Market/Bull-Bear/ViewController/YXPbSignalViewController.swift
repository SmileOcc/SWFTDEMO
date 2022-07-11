//
//  YXPbSignalViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPbSignalViewController: YXViewController {
    
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
        tabView.titles = [YXLanguageUtility.kLang(key: "market_warrants_warrants"), YXLanguageUtility.kLang(key: "market_warrants_cbbc")]
        
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
        
        let rocVC = YXStockDetailIndustryVC()
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            rocVC.viewModel.navigator =  root.navigator
        }
       
        pageView.viewControllers = [warrantVC, bullBearVC]
        
        return pageView
    }()
    
    lazy var warrantVC: YXBullBearMoreViewController = {
        let warrantVM = YXBullBearMoreViewModel.init(services: viewModel.services, type: .warrant, sectionType: .longShortSignal)
        let warrantVC = YXBullBearMoreViewController.init(viewModel: warrantVM)
        return warrantVC
    }()
    
    lazy var bullBearVC: YXBullBearMoreViewController = {
        let bullBearVM = YXBullBearMoreViewModel.init(services: viewModel.services, type: .bullBear, sectionType: .longShortSignal)
        let bullBearVC = YXBullBearMoreViewController.init(viewModel: bullBearVM)
        return bullBearVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXBullBearContractSectionType.longShortSignal.sectionTitle
        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.height.equalTo(40)
        }
        pageView.snp.makeConstraints { (make) in
            make.top.equalTo(tabView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

}
