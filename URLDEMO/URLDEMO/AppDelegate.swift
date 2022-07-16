//
//  AppDelegate.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tab : HCTabBarController?
    public let navigator = HCNavigatorServices.shareInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        
        HCNetworkReachabilityManager.instance.netWorkReachability { (status) in
            print("网络===== status: \(status)")
        }
        HCNavigationMap.initialize(navigator: navigator, services: appServices)

        self.window = UIWindow(frame: UIScreen.main.bounds)

        window?.backgroundColor = UIColor.white
        tab = HCTabBarController(navigator: navigator)
        tab?.configureRootVCS(navigator: navigator, services: appServices)
        window?.rootViewController = tab!
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    lazy var appServices = {
        AppServices(userService: HCUserService(),loginService: HCLoginService())
    }()


}

struct AppServices:HasHCUserService, HasHCLoginService {
    let userService: HCUserService
    let loginService: HCLoginService
    

}

