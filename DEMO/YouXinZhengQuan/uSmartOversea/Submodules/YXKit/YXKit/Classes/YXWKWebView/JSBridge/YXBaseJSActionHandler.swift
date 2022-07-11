//
//  YXBaseJSActionHandler.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXBaseJSActionHandler: NSObject {
    var webview: WKWebView
    var successCallback : String?
    var errorCallback : String?
    
    init(webView: WKWebView) {
        self.webview = webView
        super.init()
    }
    
    func handlerAction(withWebview webview:WKWebView, actionEvent : String, paramsJsonValue : Dictionary<String, Any>?, successCallback : String?, errorCallback : String?) -> Void {
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
}
