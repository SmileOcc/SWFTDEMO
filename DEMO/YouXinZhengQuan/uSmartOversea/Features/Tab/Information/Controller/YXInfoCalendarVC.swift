//
//  YXInfoCalendarVC.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXInfoCalendarVC: YXWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func webViewFrame() -> CGRect {
        let webViewHeight = YXConstant.screenHeight - YXConstant.tabBarHeight() - YXConstant.navBarHeight() - 60
        return CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: webViewHeight)
    }
    
    override func progressViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.progressViewHeight)
    }
    
    override func addRealWebView() {
        super.addRealWebView()
        
        webView?.frame = self.webViewFrame() //重新指定webView?.frame
        self.progressView?.frame = self.progressViewFrame()
    }
    
    func onPageStatusChange() {
        if let webV = self.webView {
            YXJSActionUtil.invokeJSFunc(withWebview: webV, paramsJsonData: [:], callback: "window.onPageStatusChange", completionCallback: nil)
        }
    }
}
