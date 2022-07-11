//
//  YXPreAfterRankViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/10/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXPreAfterRankViewController: YXHKViewController {
    
    override var pageName: String {
        "Pre/Post Mkt US"
     }
    
    var viewModel = YXViewModel()
    
    var disposeBag = DisposeBag()
    
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
        
        tabView.titles = [YXRankType.pre.title, YXRankType.after.title]
        
        tabView.pageView = self.pageView
        tabView.delegate = self
        
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
        
        pageView.viewControllers = [self.preVC, self.afterVC]
        
        return pageView
    }()
    
    lazy var preVC: YXStockDetailIndustryVC = {
        return creatViewController(withCode: YXRankType.pre.rankCode, rankType: .pre)
    }()
    
    lazy var afterVC: YXStockDetailIndustryVC = {
        return creatViewController(withCode: YXRankType.after.rankCode, rankType: .after)
    }()
    
    func creatViewController(withCode code: String, rankType: YXRankType) -> YXStockDetailIndustryVC {
        let vc = YXStockDetailIndustryVC()
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            vc.viewModel.navigator = root.navigator
        }
        
        vc.viewModel.code = code
        vc.viewModel.market = kYXMarketUS
        vc.viewModel.rankType = rankType
        
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rankTimeNotiAction(noti:)), name: NSNotification.Name.init("MarketRankTimeNoti"), object: nil)
        
        self.title = YXLanguageUtility.kLang(key: "premarket_after_ranking")
        
        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(YXConstant.navBarHeight())
        }
        
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
        }
        
        // 调用一次接口以获得日期
        afterVC.viewModel.dataSourceSingle.subscribe(onSuccess: nil, onError: nil).disposed(by: disposeBag)
        
    }
    
    @objc func rankTimeNotiAction(noti: Notification) {
        if let dic = noti.userInfo as? Dictionary<String, Any>, let time = dic["quoteTime"] as? String, let rankType = dic["rankType"] as? YXRankType {
           
            let dateStr = YXDateHelper.commonDateString(time, format: .DF_MD)
            if rankType == .pre {
                tabView.titles[0] = "\(YXRankType.pre.title)(\(dateStr))"
            }else if rankType == .after {
                tabView.titles[1] = "\(YXRankType.after.title)(\(dateStr))"
            }
            tabView.reloadDataKeepOffset()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension YXPreAfterRankViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {

        if index == 0 {
            
        }else if index == 1 {
            
        }
        
    }
}
