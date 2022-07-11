//
//  AppDelegate.swift
//  YXKit
//
//  Created by ellison on 03/27/2019.
//  Copyright (c) 2019 ellison. All rights reserved.
//

import UIKit
import YXKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var loginObserver: Any?
    var logoutObserver: Any?
    var guestUUIDObserver: Any?
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let manager = YXSecuGroupManager.shareInstance()
        
        if true {
            manager.state = .logined
            manager.version = manager.loginedSecuGroupVersion
        } else {
            manager.state = .unLogin
            manager.version = manager.unloginSecuGroupVersion
        }
        
//        jmb.log(<#T##level: XloggerType##XloggerType#>, tag: <#T##UnsafePointer<Int8>!#>, content: <#T##String!#>, fileName: <#T##String!#>, function: <#T##String!#>, line: <#T##Int#>)
        manager.getGroupIfNeed = { (complete) in
            if let block = complete {
                block()
            }
        }
        
        manager.postGroupIfNeed = { (complete) in
            if let block = complete {
                block()
            }
        }
        
        manager.synchroHoldGroup = { (complete) in
            if let block = complete {
                block()
            }
        }
        
        loginObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("login"), object: nil, queue: OperationQueue.main) { (ntf) in
            
            if let isFirst = ntf.userInfo?["firstLogin"] as? Bool {
                manager.login(isFirst)
            } else {
                manager.login(false)
            }
        }
        
        logoutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("logout"), object: nil, queue: OperationQueue.main) { (ntf) in
            manager.logout()
        }
        
        guestUUIDObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("guest"), object: nil, queue: OperationQueue.main) { (ntf) in
            manager.logout()
        }
        
        manager.getGroup()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

