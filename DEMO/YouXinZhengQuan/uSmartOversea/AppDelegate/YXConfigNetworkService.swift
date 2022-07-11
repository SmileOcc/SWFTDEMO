//
//  YXConfigNetworkService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/10/22.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation
import PluggableApplicationDelegate

class YXConfigNetworkService: NSObject, ApplicationService {
    func configureNetWork() {
//        let ipArr = [
//            "119.29.48.17" /*广州接入点 */,
//            "15.159.18.59" /*上海介入点 */,
//            "119.28.37.77" /*香港 */]
//        let signal: RACSignal? = YXPingUtility.share().ping(withIpArray: ipArr)
//        signal?.subscribeNext({ x in
//            if let aX = x {
//                log(.verbose, tag: kOther, content: "++++++++++++ \(aX)")
//            }
//        })

        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiLogin))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { _ in

                YXGlobalConfigManager.shareInstance.requestGlobalConfig()
            })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureNetWork()
        YXGlobalConfigManager.shareInstance.requestGlobalConfig()
        return true
    }
}
