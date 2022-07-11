//
//  YXAOpenAccountViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/10/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOpenAccountViewController: YXWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func addRealWebView() {
        super.addRealWebView()
        
        progressView?.isHidden = true
        progressView?.removeFromSuperview()
        self.webView?.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YXUserManager.getUserInfo(complete: nil)
    }
}
