//
//  YXJSActionBridge.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

public class YXJSActionBridge: NSObject, WKScriptMessageHandler {
    @objc var watchActivityJSActionHandler:YXWatchActivityJSActionHandler
    @objc var networkTypeJSActionHandler:YXNetworkTypeJSActionHandler
    @objc var gotoNativeManager: YXGotoNativeProtocol?
    
    @objc public init(webView: WKWebView, gotoNativeManager: YXGotoNativeProtocol?) {
        self.watchActivityJSActionHandler = YXWatchActivityJSActionHandler(webView: webView)
        self.networkTypeJSActionHandler = YXNetworkTypeJSActionHandler(webView: webView)
        self.gotoNativeManager = gotoNativeManager
        super.init()
    }
    
    /// 接受Webview中JavaScript的消息代理方法
    ///
    /// - Parameters:
    ///   - userContentController: userContentController description
    ///   - message: message description
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JSActionBridge" {
            var dic : Dictionary<String, Any>?
            if let string = message.body as? String {
                dic = YXJSActionUtil.convertToDictionary(text: string)
            } else if let dictionary = message.body as? Dictionary<String, Any> {
                dic = dictionary
            }
            
            if dic != nil {
                if let method = dic?["method"] as? String, method == "handlerAction" {
                    let data = dic?["data"] as? Dictionary<String, Any>
                    if let actionEvent = data?["actionEvent"] as? String,
                        let webView = message.webView {
                        let jsActionHandler = getJSActionHandler(withActionEvent: actionEvent, webView: webView)
                        let paramsJsonValue = data?["paramsJsonValue"] as? Dictionary<String, Any>
                        let successCallback = data?["successCallback"] as? String
                        let errorCallback = data?["errorCallback"] as? String
                        jsActionHandler?.handlerAction(withWebview: webView, actionEvent: actionEvent, paramsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
                    }
                }
            }
        }
    }
    
    
    /// 获取对应actionEvent的Handler
    ///
    /// - Parameter actionEvent: actionEvent字符串
    /// - Returns: 对应的JSActionHandler，目前支持YXGotoNativeJSActionHandler、YXGetJSActionHandler和YXCommandJSActionHandler三种
    func getJSActionHandler(withActionEvent actionEvent: String, webView: WKWebView) -> YXBaseJSActionHandler? {
        var jsActionHandler : YXBaseJSActionHandler?
        
        if actionEvent.hasPrefix(GOTO_NATIVE_MOUDLE) {
            jsActionHandler = YXGotoNativeJSActionHandler(webView: webView, gotoNativeManager: self.gotoNativeManager)
            
        } else if actionEvent.hasPrefix(JS_ACTION_GET_PREFIX) {
            jsActionHandler = YXGetJSActionHandler(webView: webView)
            
        } else if actionEvent.hasPrefix(JS_ACTION_COMMAND_PREFIX) {
            
            if actionEvent == COMMAND_WATCH_ACTVITY_STATUS {
                jsActionHandler = self.watchActivityJSActionHandler
            } else if actionEvent == COMMAND_WATCH_NETWORK {
                jsActionHandler = self.networkTypeJSActionHandler
            } else {
                jsActionHandler = YXCommandJSActionHandler(webView: webView)
            }
        }
        
        return jsActionHandler
    }
    
    @objc public func onActivityStatusChange(isVisible: Bool) {
        self.watchActivityJSActionHandler.onActivityStatusChange(isVisible: isVisible)
    }
    
    @objc public func onNetworkTypeChange(dictionary: Dictionary<String, Any>) {
        self.networkTypeJSActionHandler.onNetworkTypeChange(dictionary: dictionary)
    }
    
    @objc public func onAppDidBecomeActive() {
        self.watchActivityJSActionHandler.onAppDidBecomeActive()
    }
}
