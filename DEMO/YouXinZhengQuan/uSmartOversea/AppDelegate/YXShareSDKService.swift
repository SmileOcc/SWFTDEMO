//
//  YXShareSDKService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/10/24.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import Firebase
import GoogleSignIn
import YXKit

class YXShareSDKService: NSObject, ApplicationService, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            let err = error as NSError
            if err.code == GIDSignInErrorCode.canceled.rawValue {
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiGoogleLogin), object: self, userInfo: ["code": "", "success": NSNumber(booleanLiteral: false), "msg": YXLanguageUtility.kLang(key: "login_auth_cancel")])
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiGoogleLogin), object: self, userInfo: ["code": "", "success": NSNumber(booleanLiteral: false), "msg": YXLanguageUtility.kLang(key: "login_auth_failure")])
            }
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let code = authentication.accessToken
        if !(code?.isEmpty ?? true) {//code?.count ?? 0 > 0
            NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiGoogleLogin), object: self, userInfo: ["code": code ?? "", "success": NSNumber(booleanLiteral: true)])
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "Please use application:openURL:options:")
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        YXShareSDKHelper.shareInstance().handleOpen(url)
        return true
    }

    @available(iOS, introduced: 4.2, deprecated: 9.0, message: "Please use application:openURL:options:")
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        YXShareSDKHelper.shareInstance().handleOpen(url)
        
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        YXShareSDKHelper.shareInstance().handleOpen(url)
        
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return YXShareSDKHelper.shareInstance()?.handleOpenUniversalLink(userActivity) ?? false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WXApi.registerApp(MOBSSDKWeChatAppID, universalLink: YX_WECHAT_UNIVERSAL_LINKS)
        #if PRD || PRD_HK || AD_HOC_SIT
        let filePath = Bundle.main.path(forResource: "GoogleService-Info-PRD", ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else { assert(false, "Couldn't load config file"); return false }
        FirebaseApp.configure(options: fileopts)
        #else
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!) else { assert(false, "Couldn't load config file"); return false }
        FirebaseApp.configure(options: fileopts)
        #endif
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.serverClientID = "244872476513-q8p0m7mhhn11aq5c4fgo2d8a8ut7aucl.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
}
