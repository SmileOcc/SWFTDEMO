//
//  YXLoginViewController+Extension.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/6/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

extension UIViewController {
    
    // 注册登录成功返回处理
    func loginSuccessBack(_ soureVc: UIViewController?, loginCallBack: (([String: Any])->Void)?) {
        
        if YXLaunchGuideManager.isGuideToLogin() == false {//不是引导页进来
            if YXUserManager.isShowLoginRegister() {//灰度登录注册
                YXUserManager.registerLoginInitRootViewControler()
                return
            }
            
            if let vc = soureVc {//有来源，返回来源
                if self.navigationController?.viewControllers.contains(vc) ?? false {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }

            // 异常返回处理
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                if root.window?.rootViewController is UITabBarController {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
            }
            // 不是tab,重置tab
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
            

        } else { // 引导页进来
            YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
            if YXUserManager.isShowLoginRegister() {//灰度登录注册
                YXUserManager.registerLoginInitRootViewControler()
                return
            }

            if loginCallBack == nil { //防止异常处理，没有传入回调 （引导页没给回调的话）
                
                // 异常返回处理
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    if root.window?.rootViewController is UITabBarController {
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                }
                
                // 不是tab,重置tab
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: ["index" : YXTabIndex.market])
            }
        }
    }
}
