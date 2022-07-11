//
//  YXAppsFlyerTracker.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import AppsFlyerLib
import FirebaseAnalytics

class YXAppsFlyerTracker: NSObject {
    @objc static let shared = YXAppsFlyerTracker()
    
    private override init() {
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
    
    /// Use this method to track an events with mulitple values. See AppsFlyer's documentation for details.
    /// Swift:
    ///
    /// <pre>
    /// AppsFlyerTracker.shared().trackEvent(AFEventPurchase,
    ///  withValues: [AFEventParamRevenue  : "1200",
    ///  AFEventParamContent  : "shoes",
    ///  AFEventParamContentId: "123"])
    /// </pre>
    /// - Parameters:
    ///   - name: Contains name of event that could be provided from predefined constants in `AppsFlyerTracker.h`
    ///   - values: Contains dictionary of values for handling by backend
    func trackEvent(name: String, withValues values: Dictionary<String, Any>? = nil) {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().logEvent(name, withValues: values)
        }
        // 同时埋点到firebase
        Analytics.logEvent(name, parameters: values)
    }
    
    /// Use this method to track an events with mulitple values. See AppsFlyer's documentation for details.
    /// - Parameters:
    ///   - name: Contains name of event that could be provided from predefined constants in `AppsFlyerTracker.h`
    ///   - values: Contains dictionary of values for handling by backend
    ///   - completionHandler: 追踪完成后的回调事件
    func trackEvent(name: String, values: [String : Any]? = nil, completionHandler: @escaping (_ dictionary: [String : Any?]?, _ error: Error?) -> Void) {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().logEvent(name: name, values: values, completionHandler: completionHandler)
        }
        Analytics.logEvent(name, parameters: values)
    }
    
    /// 追踪App启动事件
    func trackAppLaunch() {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().start()
        }
    }
}
