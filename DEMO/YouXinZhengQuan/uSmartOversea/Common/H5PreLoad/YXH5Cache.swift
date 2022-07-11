//
//  YXH5Cache.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/12/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import YXKit
import WebKit

class YXH5Cache: NSObject {
    @objc static let shareInstance = YXH5Cache()
    let url = YXUrlRouterConstant.staticResourceBaseUrl() + "/common/prefetch/sg.html"
    lazy var webView: YXWKWebView = {
        let v = YXWKWebView()
//        v.navigationDelegate = self
        return v
    }()
    
    @objc func startPreload() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let `self` = self else {return}
            if YXGlobalConfigManager.isH5PreLoadOn() {
                if let URL = URL.init(string: self.url) {
                    let request = URLRequest.init(url: URL)
                    self.webView.load(request)
                }
            }
        }
    }
}
