//
//  YXNetworkTypeJSActionHandler.swift
//  YXKit
//
//  Created by provswin on 2021/6/2.
//

import UIKit

class YXNetworkTypeJSActionHandler: YXBaseJSActionHandler {
    func onNetworkTypeChange(dictionary: Dictionary<String, Any>) -> Void {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: String.Encoding.utf8),
           let successCallback = self.successCallback {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: self.webview, data: jsonString, callback: successCallback)
        }
    }
}
