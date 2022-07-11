//
//  YXFundWebViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXFundWebViewController: YXWebViewController {
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleView?.title = YXLanguageUtility.kLang(key: "hold_fund_name")
        
        // 因为基金页面是H5页面，为了考虑用户体验特意将弹窗的时间延后2秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            YXPopManager.shared.checkPop(with: YXPopManager.showPageFund, vc:self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 因为基金页面是H5页面，为了考虑用户体验特意将弹窗的时间延后2秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //检查Pop的弹窗状态
            YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageFund, vc: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.addNavUserBtn()
        self.setTabbarVisibleIfNeed()
        // 神策事件：开始记录
        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
    }
    
//    override func navigationBarBackgroundImage() -> UIImage? {
//        UIImage(named: "home_navbar_bg")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
//    }
//    
//    override func navigationBarTintColor() -> UIColor? {
//        return UIColor.white
//    }
//    
//    override func titleViewTintColor() -> UIColor? {
//        return UIColor.white
//    }
    
    override func bottomGap() -> CGFloat {
        YXConstant.tabBarHeight()
    }
    
    override func setupWebView() {
        super.setupWebView()
        
        self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight() - self.bottomGap())
    }
    
    override func setupNavigationBar() {
        // FIXME: 此处发现在iOS11以下如果设置过leftBarButtonItems之后，再对leftBarButtonItems设置nil就不会生效;因此在iOS11以下不调用super去设置leftBarButtonItems
        if #available(iOS 11.0, *) {
            super.setupNavigationBar()
        }
        
        self.navigationItem.leftBarButtonItems = nil
    }

}
