//
//  YXJSActionUtil.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

public class YXJSActionUtil: NSObject {
    
    /**
     * 调用成功
     */
    static let JS_ACTION_INVOKE_SUCCESS = 0;
    
    /**
     * 调用失败
     */
    static let JS_ACTION_INVOKE_FAIL = -1;
    
    /// 将JSON字符串尝试转换为Dictionary
    ///
    /// - Parameter text: 需要转换的字符串
    /// - Returns: 转换后的字典或nil
    @objc public static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                log(.error, tag: kOther, content: "\(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /// 将字典尝试转换为JSON字符串
    ///
    /// - Parameter dict: 需要转换的字典
    /// - Returns: 转换后的JSON字符串
    @objc public static func convertToJsonString(dict: [String:Any]) -> String? {
        var result:String?
        do {
            //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
            
        } catch {
            result = nil
        }
        return result
    }

    /// 针对执行成功的情况，对JS进行回调
    ///
    /// - Parameters:
    ///   - webview: 需要执行回调的Webview
    ///   - data: 需要携带的数据
    ///   - callback: 回调函数名称
    @objc public static func invokeJSCallbackForSuccess(withWebview webview: WKWebView, data: String, callback: String) -> Void {
        var paramsJsonData = ["code" : JS_ACTION_INVOKE_SUCCESS, "desc" : "success"] as [String : Any]
        
        if let jsonData = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            
            if json != nil {
                paramsJsonData["data"] = json
            } else {
                paramsJsonData["data"] = data
            }
            
            DispatchQueue.main.async {
                if let dictionaryData = try? JSONSerialization.data(withJSONObject: paramsJsonData, options: []), let jsonStr = String(data: dictionaryData, encoding: String.Encoding.utf8) {
                    webview.evaluateJavaScript("\(callback)(\(jsonStr))", completionHandler: { jsData, error in
                        log(.info, tag: kOther, content: "\(jsData as Optional)")
                    })
                }
            }
        }
    }
    
    
    /// 针对执行失败的情况，对JS进行回调
    ///
    /// - Parameters:
    ///   - webview: 需要执行回调的Webview
    ///   - errorDesc: 需要携带的数据
    ///   - callback: 回调函数名称
    @objc public static func invokeJSCallbackForError(withWebview webview: WKWebView, errorDesc: Any, callback: String) -> Void {
        let paramsJsonData = ["code" : JS_ACTION_INVOKE_FAIL, "desc" : errorDesc] as [String : Any]
        
        DispatchQueue.main.async {
            if let dictionaryData = try? JSONSerialization.data(withJSONObject: paramsJsonData, options: []), let jsonStr = String(data: dictionaryData, encoding: String.Encoding.utf8) {
                webview.evaluateJavaScript("\(callback)(\(jsonStr))", completionHandler: { jsData, error in
                    log(.info, tag: kOther, content: "\(jsData as Optional)")
                })
            }
        }
    }
    
    /// 针对执行失败的情况，对JS进行回调
    ///
    /// - Parameters:
    ///   - webview: 需要执行回调的Webview
    ///   - errorCode: 错误码
    ///   - errorMessage: 错误描述
    ///   - callback: 回调函数名称
    @objc public static func invokeJSCallbackForError(withWebview webview: WKWebView, errorCode: Int, errorMessage: String, callback: String) -> Void {
        let errorInfo = ["errorCode": NSNumber(value: errorCode), "errorMessage": errorMessage] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: errorInfo, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
            
            if let data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                if json != nil {
                    invokeJSCallbackForError(withWebview: webview, errorDesc: json!, callback: callback)
                }
            }
        }
    }
    
    /// 执行JS方法
    ///
    /// - Parameters:
    ///   - webview: 需要执行方法的Webview
    ///   - paramsJsonData: 携带的参数
    ///   - callback: JS函数名
    ///   - completionCallback: 执行完毕后的回调函数
    @objc public static func invokeJSFunc(withWebview webview: WKWebView, paramsJsonData: [String : Any], callback: String, completionCallback: ((Any?, Error?) -> Void)?) {
        DispatchQueue.main.async {
            if let dictionaryData = try? JSONSerialization.data(withJSONObject: paramsJsonData, options: []), let jsonStr = String(data: dictionaryData, encoding: String.Encoding.utf8) {
                webview.evaluateJavaScript("\(callback)(\(jsonStr))", completionHandler: { jsData, error in
                    if let completionCallback = completionCallback {
                        completionCallback(jsData, error)
                    }
                })
            }
        }
    }
}
