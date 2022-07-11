//
//  YXGotoNativeJSActionHandler.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXGotoNativeJSActionHandler: YXBaseJSActionHandler {
    let gotoNativeManager: YXGotoNativeProtocol?
    
    public required init(webView: WKWebView, gotoNativeManager: YXGotoNativeProtocol?) {
        self.gotoNativeManager = gotoNativeManager
        super.init(webView: webView)
    }
    
    override func handlerAction(withWebview webview:WKWebView, actionEvent: String, paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        super.handlerAction(withWebview: webview, actionEvent: actionEvent, paramsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
        switch actionEvent {
        case GOTO_NATIVE_MOUDLE:
            if let url = paramsJsonValue?["url"] as? String {
                // TODO: 待实现isWaitingResult逻辑
                let isWaitingResult = paramsJsonValue?["isWaitingResult"] as? Bool
                
                let success = self.gotoNativeManager?.gotoNativeViewController(withUrlString: url) ?? false
                
                if success {
                    if let successCallback = self.successCallback {
                        YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webview, data: "success", callback: successCallback)
                    }
                } else {
                    if let errorCallback = self.errorCallback {
                        YXJSActionUtil.invokeJSCallbackForError(withWebview: webview, errorDesc: "invoke goto native failed!", callback: errorCallback)
                    }
                }
            } else {
                log(.info, tag: kOther, content: "no native url error")
            }
        default:
            log(.error, tag: kOther, content: "no matched goto native action")
        }
    }
}
