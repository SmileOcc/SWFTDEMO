//
//  YXFirebaseAnalyticsTracker.swift
//  uSmartOversea
//
//  Created by youxin on 2020/2/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class YXFirebaseAnalyticsTracker: NSObject {

    @objc static let shared = YXFirebaseAnalyticsTracker()

    private override init() {
        //Analytics.setUserProperty("", forName: "")
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
    //自动收集事件详细描述 https://support.google.com/firebase/answer/6317485
    /// Logs an app event. The event can have up to 25 parameters. Events with the same name must have
    /// the same parameters. Up to 500 event names are supported. Using predefined events and/or
    /// parameters is recommended for optimal reporting.
    ///
    /// The following event names are reserved and cannot be used:
    /// <ul>
    ///     <li>ad_activeview</li>
    ///     <li>ad_click</li>
    ///     <li>ad_exposure</li>
    ///     <li>ad_impression</li>
    ///     <li>ad_query</li>
    ///     <li>adunit_exposure</li>
    ///     <li>app_clear_data</li>
    ///     <li>app_remove</li>
    ///     <li>app_update</li>
    ///     <li>error</li>
    ///     <li>first_open</li>
    ///     <li>in_app_purchase</li>
    ///     <li>notification_dismiss</li>
    ///     <li>notification_foreground</li>
    ///     <li>notification_open</li>
    ///     <li>notification_receive</li>
    ///     <li>os_update</li>
    ///     <li>screen_view</li>
    ///     <li>session_start</li>
    ///     <li>user_engagement</li>
    /// </ul>
    ///
    /// @param name The name of the event. Should contain 1 to 40 alphanumeric characters or
    ///     underscores. The name must start with an alphabetic character. Some event names are
    ///     reserved. See FIREventNames.h for the list of reserved event names. The "firebase_",
    ///     "google_", and "ga_" prefixes are reserved and should not be used. Note that event names are
    ///     case-sensitive and that logging two events whose names differ only in case will result in
    ///     two distinct events.
    /// @param parameters The dictionary of event parameters. Passing nil indicates that the event has
    ///     no parameters. Parameter names can be up to 40 characters long and must start with an
    ///     alphabetic character and contain only alphanumeric characters and underscores. Only NSString
    ///     and NSNumber (signed 64-bit integer and 64-bit floating-point number) parameter types are
    ///     supported. NSString parameter values can be up to 100 characters long. The "firebase_",
    ///     "google_", and "ga_" prefixes are reserved and should not be used for parameter names.
    func trackEvent(name: String, withValues values: Dictionary<String, Any>? = nil) {
        Analytics.logEvent(name, parameters: values)
    }


    /* 替换类名的方法
    func recordScreenView() {
        // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
        guard let screenName = title else {
            return
        }
        let screenClass = classForCoder.description()

        // [START set_current_screen]
        Analytics.setScreenName(screenName, screenClass: screenClass)
        // [END set_current_screen]
    }
     */



}
