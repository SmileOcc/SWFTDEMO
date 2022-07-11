//
//  YXNewStockECMWebVC.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXNewStockECMWebVC: YXWebViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func addRealWebView() {
        super.addRealWebView()
   
        progressView?.isHidden = true
        self.webView?.scrollView.mj_header = nil
        self.webView?.scrollView.bounces = false
        self.webView?.scrollView.layoutIfNeeded()
        progressView?.removeFromSuperview()
        self.webView?.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    
}

class YXNewStockHKRecordWebVC: YXWebViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func addRealWebView() {
        super.addRealWebView()

        self.webView?.scrollView.layoutIfNeeded()
        progressView?.mj_y = 0
        self.webView?.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }


}
