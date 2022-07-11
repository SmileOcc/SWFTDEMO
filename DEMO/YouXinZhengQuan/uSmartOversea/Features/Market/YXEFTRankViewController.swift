//
//  YXEFTRankViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXEFTRankViewController: YXHKViewController, ViewModelBased {
    
    override var pageName: String {
           "HK ETFs"
       }
    
    var viewModel: YXETFRankViewModel! = YXETFRankViewModel()
    
    lazy var allRankVC: YXStockDetailIndustryVC = {
        return creatViewController(withCode: "MKTETF_ALL")
    }()
    
    lazy var posRankVC: YXStockDetailIndustryVC = {
        return creatViewController(withCode: "MKTETF_POS")
    }()
    
    lazy var negRankVC: YXStockDetailIndustryVC = {
        return creatViewController(withCode: "MKTETF_NEG")
    }()
        
    func creatViewController(withCode code: String) -> YXStockDetailIndustryVC {
        let vc = YXStockDetailIndustryVC()
        vc.viewModel.navigator = self.viewModel.navigator
        vc.viewModel.code = code
        vc.viewModel.market = kYXMarketHK
        vc.viewModel.rankType = .normal
        return vc
    }
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView.init(frame: CGRect.zero)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = true
        
        pageView.viewControllers = [allRankVC, posRankVC, negRankVC]
        
        return pageView
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHeight = 4
        tabLayout.lineWidth = 16
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.linePadding = 1
        tabLayout.lineCornerRadius = 2
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().mainThemeColor()
        tabLayout.titleFont = .systemFont(ofSize: 14)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 14, weight: .medium)
        
        let tabView = YXTabView.init(frame: CGRect.zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        
        tabView.titles = [YXLanguageUtility.kLang(key: "common_all"), YXLanguageUtility.kLang(key: "pos_leverage"), YXLanguageUtility.kLang(key: "inves_leverage")]
        
        tabView.pageView = self.pageView
        
        let line = UIView.line()
        tabView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.left.right.equalToSuperview()
        }
        
        return tabView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXLanguageUtility.kLang(key: "market_hk_etf")
        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(YXConstant.navBarHeight())
            make.height.equalTo(40)
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
        }
    }
    

    

}
