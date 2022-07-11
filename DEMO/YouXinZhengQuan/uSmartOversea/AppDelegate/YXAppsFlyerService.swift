//
//  YXAppsFlyerService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/11/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import AppsFlyerLib
import PluggableApplicationDelegate

class YXAppsFlyerService: NSObject, ApplicationService, DeepLinkDelegate {
    
    @objc static let shared = YXAppsFlyerService()
    
    let appsFlyerDevKey = "2jiwZWQX6dAYDGZearFnLB"
    let appleAppID = YXConstant.appId
    
    var deeplinkUrl: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
            AppsFlyerLib.shared().appleAppID = appleAppID
            AppsFlyerLib.shared().delegate = self
            AppsFlyerLib.shared().deepLinkDelegate = self
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            #if DEBUG
                AppsFlyerLib.shared().isDebug = true
            #endif
            if YXUserManager.userUUID() != YXUserManager.DEFAULT_GUEST_UUID {
                AppsFlyerLib.shared().customerUserID = String(YXUserManager.userUUID())
            }
            
            _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateUUID))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { _ in
                AppsFlyerLib.shared().customerUserID = String(YXUserManager.userUUID())
            })
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
        YXAppsFlyerTracker.shared.trackAppLaunch()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().handlePushNotification(userInfo)
        }
    }
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().handleOpen(url, options: options)
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().handlePushNotification(userInfo)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if YXToolUtility.appsFlyerEnable() {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        }
        return true
    }
}

extension YXAppsFlyerService: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                    let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
                is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    //Handle Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        if result.status == .found {
            if let value = result.deepLink?.deeplinkValue {
                self.deeplinkUrl = value
                if let delegate = UIApplication.shared.delegate as? YXAppDelegate {
                    if delegate.tab != nil {
                        jumpDeepLink()
                    }
                }
            }
        }
    }
    
    func jumpDeepLink() {
        if let url = self.deeplinkUrl {
            if url.lowercased().starts(with: "https://") || url.lowercased().starts(with: "http://") {
                YXWebViewModel.pushToWebVC(url)
            } else {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: url)
            }
            self.deeplinkUrl = nil
        }
    }
}

