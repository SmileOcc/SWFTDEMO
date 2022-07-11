//
//  YXSpecialViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSpecialViewController: YXHKViewController {
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.tabMargin = 20
        tabLayout.lineHeight = 4
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 18, weight: .semibold)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.pageView = pageView
        
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var subscribeVC: YXSubscribeViewController = {
        return YXSubscribeViewController()
    }()
    
    lazy var recommendVC: YXRecommendViewController = {
        return YXRecommendViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name("FirstInNoScribe")).subscribe { [weak self]noti in
            self?.tabView.selectTab(at: 1)
        }.disposed(by: disposeBag)

        
        view.backgroundColor = UIColor(hexString: "F9F9F9")
        
        tabView.titles = [YXLanguageUtility.kLang(key: "nbb_tab_follow"), YXLanguageUtility.kLang(key: "nbb_recommend")]
        pageView.viewControllers = [subscribeVC, recommendVC]
        
        view.addSubview(tabView)
        view.addSubview(pageView)
        
        tabView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                // Fallback on earlier versions
                make.top.equalToSuperview()
            }
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            if YXUserManager.isENMode() {
                make.width.equalTo(240)
            }else {
                make.width.equalTo(140)
            }
        }
        
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }

}
