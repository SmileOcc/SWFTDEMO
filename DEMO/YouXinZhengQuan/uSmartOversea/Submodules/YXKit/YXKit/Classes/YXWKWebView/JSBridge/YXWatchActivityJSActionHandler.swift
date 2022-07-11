//
//  YXWatchActivityJSActionHandler.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/1/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXWatchActivityJSActionHandler: YXBaseJSActionHandler {
    func onActivityStatusChange(isVisible: Bool) -> Void {
        if isVisible {
            let data = ["status" : "visible"]
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                let successCallback = self.successCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: self.webview, data: jsonString, callback: successCallback)
            }
        } else {
            let data = ["status" : "invisible"]
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
                let successCallback = self.successCallback {
                YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: self.webview, data: jsonString, callback: successCallback)
            }
        }
    }
    
    func onAppDidBecomeActive() -> Void {
        let data = ["status" : "appDidBecomActive"]
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
            let successCallback = self.successCallback {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: self.webview, data: jsonString, callback: successCallback)
        }
    }
}
