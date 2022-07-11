//
//  YXPushService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import PluggableApplicationDelegate

class YXPushService: NSObject, ApplicationService, UNUserNotificationCenterDelegate {
    #if PRD || PRD_HK
    static let appId = "8b54767706c72"
    static let appSecret = "7320a622087a67c7781f01eff9147f6d"
    #else
    static let appId = "259f008bd9218"
    static let appSecret = "2d7f9b2ca25a20481383df1a2264c6ed"
    #endif
    
    static var pushToken: String?
    
    var tokenRegisted: Bool = false
    
    var tokenTimerFlag: YXTimerFlag = 0
    
    var tagRegisted: Bool = false
    
    var tagTimerFlag: YXTimerFlag = 0
    
    // 默认的超时重试时间
    let timeout: TimeInterval = 10
    
    private func registerNotifications() {
        // 网络监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleNetWorkChangeNotification), name: Notification.Name.init(rawValue: kNetWorkReachabilityChangedNotification), object: nil)

        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateLanguage))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
                self.tagRegisted = false
            
                self.regisgerTag()
            })
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateUUID))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                
                // 1. 启动自建
                self.tokenRegisted = false
                self.tagRegisted = false
                
                self.registerToken()
                self.regisgerTag()
            })
    }
    
    /// 网络状态变化回调处理
    ///
    /// - Parameter ntf: 通知信息
    @objc func handleNetWorkChangeNotification(ntf: Notification) {
        if let reachability = ntf.object as? HLNetWorkReachability {
            let netWorkStatus = reachability.currentReachabilityStatus()
            
            // 如果网络可用了，并且之前没有注册过
            if netWorkStatus != .notReachable, !tokenRegisted {
                self.registerToken()
            }
            
            if netWorkStatus != .notReachable, !tagRegisted {
                self.regisgerTag()
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        self.registerNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        YXPushService.pushToken = deviceToken.map { String(format: "%02x", $0) }.joined()
        if !(YXPushService.pushToken?.isEmpty ?? true) {
            self.tokenRegisted = false
            self.registerToken()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if
            let custom = userInfo["custom"] as? [String: String],
            let taskId = custom["taskId"] {
            reportTaskId(taskId: taskId)
        }
        
        completionHandler(.newData)
        
        // 前台显示信鸽推送消息
        if application.applicationState == .active {
            let ntf = UILocalNotification()
            ntf.fireDate = Date(timeIntervalSinceNow: 0.1)
            ntf.repeatInterval = .day
            if let dataDic = userInfo["data"] as? Dictionary<AnyHashable, Any>,
                let content = dataDic["content"] as? String {
                ntf.alertBody = content
            }
            ntf.timeZone = NSTimeZone.default
            ntf.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(ntf)
        }
        
        if
            let custom = userInfo["custom"] as? [String: String],
            let param = custom["param"],
            let json = ((try? JSONSerialization.jsonObject(with: param.data(using: .utf8) ?? Data() , options: .mutableContainers) as? [String: Any]) as [String : Any]??)
        {
            if
                json?["isJumpPage"] as? Int == 1
            {
                // jumpPageType    跳转页面类型 1-指定app页面 2-跳转活动页面（手动录入URL）
                if json?["jumpPageType"] as? Int == 1 {
                    if let showPageUrl = json?["showPageUrl"] as? String,
                        showPageUrl.count > 0 {
                        YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: showPageUrl)
                    }
                } else if json?["jumpPageType"] as? Int == 2 {
                    if let jumpPageUrl = json?["jumpPageUrl"] as? String,
                        jumpPageUrl.count > 0 {
                        YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: jumpPageUrl)
                    }
                }
            }
        }
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if
            let custom = userInfo["custom"] as? [String: String],
            let taskId = custom["taskId"] {
            reportTaskId(taskId: taskId)
        }
        
        completionHandler()
        
        if
            let custom = userInfo["custom"] as? [String: String],
            let param = custom["param"],
            let json = ((try? JSONSerialization.jsonObject(with: param.data(using: .utf8) ?? Data() , options: .mutableContainers) as? [String: Any]) as [String : Any]??)
        {
            if
                json?["isJumpPage"] as? Int == 1
            {
                // jumpPageType    跳转页面类型 1-指定app页面 2-跳转活动页面（手动录入URL）
                if json?["jumpPageType"] as? Int == 1 {
                    if let showPageUrl = json?["showPageUrl"] as? String,
                        showPageUrl.count > 0 {
                        YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: showPageUrl)
                    }
                } else if json?["jumpPageType"] as? Int == 2 {
                    if let jumpPageUrl = json?["jumpPageUrl"] as? String,
                        jumpPageUrl.count > 0 {
                        YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: jumpPageUrl)
                    }
                }
                
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if
            let custom = userInfo["custom"] as? [String: String],
            let taskId = custom["taskId"] {
            reportTaskId(taskId: taskId)
        }
        completionHandler([.badge, .sound, .alert])
    }
    
    func reportTaskId(taskId: String) {
        let requestModel = YXPushReportRequestModel()
        requestModel.taskId = taskId
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (model) in
            log(.debug, tag: kXGPush, content: "report result code = \(String(describing: model.code)), msg = \(String(describing: model.msg))")
        }, failure: { (request) in
            log(.debug, tag: kXGPush, content: "report failed")
        })
    }

    func regisgerTag() {
        DispatchQueue.main.async {
            if self.tagTimerFlag > 0 {
                YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.tagTimerFlag)
                self.tagTimerFlag = 0
            }
            
            self.tagTimerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                guard let `self` = self else { return }
                
                if let pushToken = YXPushService.pushToken {
                    let requestModel = YXRegisterTagRequestModel()
                    switch YXUserManager.curLanguage() {
                    case .CN:
                        // 记录当前正在进行绑定的Identifier
                        requestModel.tagList = ["simple"]
                    case .HK,
                         .unknown:
                        // 记录当前正在进行绑定的Identifier
                        requestModel.tagList = ["traditional"]
                    case .EN, .ML, .TH:
                        // 记录当前正在进行绑定的Identifier
                        requestModel.tagList = ["eng"]
                    }
                    requestModel.operatorType = 6
                    requestModel.deviceList = [pushToken]
                    requestModel.platform = "ios"
                    
                    let request = YXRequest(request: requestModel)
                    request.startWithBlock(success: { [weak self] (model) in
                        guard let `self` = self else { return }
                        
                        if model.code == .success {
                            self.tagRegisted = true
                            
                            self.invalidTagTimerOperationIfNeed()
                        }
                    }, failure: { (request) in
                        print("\(request)")
                    })
                }
                
            }, timeInterval: self.timeout, repeatTimes: Int.max, atOnce: true)
        }
    }
    
    func registerToken() {
        DispatchQueue.main.async {
            if self.tokenTimerFlag > 0 {
                YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.tokenTimerFlag)
                self.tokenTimerFlag = 0
            }
            
            self.tokenTimerFlag = YXTimerSingleton.shareInstance().transactOperation({ [weak self] (flag) in
                guard let `self` = self else { return }
                
                if YXUserManager.userUUID() != 0, let pushToken = YXPushService.pushToken {
                    let deviceUserList = YXDeviceUserList()
                    deviceUserList.device = pushToken
                    deviceUserList.userList = ["\(YXUserManager.userUUID())"]

                    let requestModel = YXRegisterTokenRequestModel()
                    requestModel.operatorType = 3
                    requestModel.platform = "ios"
                    requestModel.deviceUserList = [deviceUserList]
                    
                    let request = YXRequest(request: requestModel)
                    request.startWithBlock(success: { [weak self] (model) in
                        guard let `self` = self else { return }
                        
                        if model.code == .success {
                            self.tokenRegisted = true
                            
                            self.invalidTokenTimerOperationIfNeed()
                        }
                    }, failure: { (request) in
                        print("\(request)")
                    })
                }
            }, timeInterval: self.timeout, repeatTimes: Int.max, atOnce: true)
        }
    }
    
    func invalidTokenTimerOperationIfNeed() -> Void {
        DispatchQueue.main.async {
            if self.tokenTimerFlag > 0 {
                YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.tokenTimerFlag)
                self.tokenTimerFlag = 0
            }
        }
    }
    
    func invalidTagTimerOperationIfNeed() -> Void {
        DispatchQueue.main.async {
            if self.tagTimerFlag > 0 {
                YXTimerSingleton.shareInstance().invalidOperation(withFlag: self.tagTimerFlag)
                self.tagTimerFlag = 0
            }
        }
    }
}
