//
//  YXSensorsAnalyticsService.swift
//  uSmartEducation
//
//  Created by 胡华翔 on 2018/11/30.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import SensorsAnalyticsSDK
import RxSwift

class YXSensorsAnalyticsService: NSObject, ApplicationService {
    
    open var SA_SERVER_URL: String {
        get {
            YXConstant.targetMode() != YXTargetMode.prd && YXConstant.targetMode() != .prd_hk
                ? "https://sc.usmartsg.com/sa?project=default"
                : "https://sc.usmartsg.com/sa?project=production"
        }
    }

    open var SA_DEBUG_MODE: SensorsAnalyticsDebugMode {
        get {
            #if PRD || PRD_HK
            return .off
            #else
            return .andTrack
            #endif
        }
    }

    var superProps: Dictionary<String, Any> = [:]
    
    // 曝光的推荐资讯列表文章id
    static var exposeInfoRecommendListIds = Set<String>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initSensorsAnalytics(withLaunchOptions: launchOptions)
//        SensorsAnalyticsSDK.sharedInstance()?.addWebViewUserAgentSensorsDataFlag();
        
        // 神策用户关联，需要后台同步使用trackSignup进行关联
        SensorsAnalyticsSDK.sharedInstance()?.login(String(YXUserManager.userUUID()))
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateUUID))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
                
                self.registerUserSuperProps()
                SensorsAnalyticsSDK.sharedInstance()?.registerSuperProperties(self.superProps)
                
                SensorsAnalyticsSDK.sharedInstance()?.login(String(YXUserManager.userUUID()))
            })
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if SensorsAnalyticsSDK.sharedInstance()?.handleSchemeUrl(url) ?? false {
               return true
       }
       return true
    }
    
    func initSensorsAnalytics(withLaunchOptions launchOptions: [AnyHashable : Any]?) {
        // 初始化 SDK
        let options = SAConfigOptions.init(serverURL: SA_SERVER_URL, launchOptions: launchOptions)
        options.flushInterval = 60 * 1000
        //options.enableTrackPageLeave = true
        options.enableAutoTrackChildViewScreen = true
        options.autoTrackEventType = [.eventTypeAppStart, .eventTypeAppEnd, .eventTypeAppViewScreen]
        #if DEBUG
        options.enableLog = true
        #endif
        SensorsAnalyticsSDK.start(configOptions: options)
        
        registerSuperProps()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 如果应用退出到后台时，发现还有未上传的资讯，则也上传
        guard YXSensorsAnalyticsService.exposeInfoRecommendListIds.count > 0  else {
            return
        }
        
        var infoIds: String = String()
        for (index, value) in YXSensorsAnalyticsService.exposeInfoRecommendListIds.enumerated() {
            infoIds.append(value)
            if index != YXSensorsAnalyticsService.exposeInfoRecommendListIds.count - 1 {
                infoIds.append(",")
            }
        }
        
    }
    
    @objc class func addExposeInfoId(_ newsId: String, algorithm: String) -> Void {
        let exposeInfoIds = NSMutableSet.init(set: YXSensorsAnalyticsService.exposeInfoRecommendListIds)
        exposeInfoIds.add(newsId + ":\(algorithm)")
        
        if let exposeInfoIds = exposeInfoIds as? Set<String> {
            YXSensorsAnalyticsService.exposeInfoRecommendListIds = exposeInfoIds
        }
        
        // 如果大于30个，则进行曝光列表上报
        guard YXSensorsAnalyticsService.exposeInfoRecommendListIds.count >= 30  else {
            return
        }
        
        var infoIds: String = String()
        for (index, value) in YXSensorsAnalyticsService.exposeInfoRecommendListIds.enumerated() {
            infoIds.append(value)
            if index != YXSensorsAnalyticsService.exposeInfoRecommendListIds.count - 1 {
                infoIds.append(",")
            }
        }
        
    }
    
    
    fileprivate func registerUserSuperProps() {
        self.superProps.removeValue(forKey: "yx_guest_id")
        self.superProps.removeValue(forKey: "user_uuid")
        if YXUserManager.isLogin() {
            self.superProps["user_uuid"] = String(YXUserManager.userUUID())
        } else {
            self.superProps["user_uuid"] = String(YXUserManager.userUUID())
        }
    }
    
    func registerSuperProps() -> Void {
        self.superProps["app_id"] = "yxstock_app"
        
        switch YXConstant.targetMode() {
        case .sit:
            self.superProps["channel_id"] = "pgyer"
        case .uat:
            self.superProps["channel_id"] = "pgyer"
        case .dev:
            self.superProps["channel_id"] = "pgyer"
        case .mock:
            self.superProps["channel_id"] = "pgyer"
        case .prd,
             .prd_hk:
            self.superProps["channel_id"] = "App Store"
        }
        self.superProps["app_type"] = YXConstant.appTypeValue.rawValue
        self.superProps["app_env"] = YXConstant.targetModeName()
        self.superProps["app_device_id"] = YXConstant.deviceUUID
        
        registerUserSuperProps()
        SensorsAnalyticsSDK.sharedInstance()?.registerSuperProperties(self.superProps)
    }
}

