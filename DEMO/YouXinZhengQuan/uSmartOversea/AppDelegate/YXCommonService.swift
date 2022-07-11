//
//  YXCommonService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import PluggableApplicationDelegate

class YXCommonService: NSObject, ApplicationService {
    
    @objc static let shared = YXCommonService()
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    
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
    
    let disposeBag = DisposeBag()
    
    var checkMsgStausTimerBag: DisposeBag?
    
    let messageCenterService = YXMessageCenterService.shared
    
    @objc public func checkMsgStatus() {
        self.messageCenterService.request(.getMsg, response: { (response) in
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    if YXUserManager.isLogin() {
                        if result.data?.system?.newFlag == 1 || result.data?.business?.newFlag == 1 /*|| result.data?.stockNotify?.newFlag == 1 || result.data?.news?.newFlag == 1 || result.data?.activity?.newFlag == 1*/ {
                            YXMessageButton.pointIsHidden = false
                        } else {
                            YXMessageButton.pointIsHidden = true
                        }
                    } else {
                        YXMessageButton.pointIsHidden = true
                    }
                default:
                    YXMessageButton.pointIsHidden = true
                }
            case .failed(_):
                YXMessageButton.pointIsHidden = true
            }
            } as YXResultResponse<YXHKMsgHomeResponseModel>).disposed(by: self.disposeBag)
    }
    
    func getUnReadNum() {
        //获取券商消息 1：系统公告 2：业务提醒
        self.messageCenterService.request(.unreadNum("1,2"), response: { (response) in
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    var hasUnread = false
                    
                    if let unreadNums = result.data?.unreadNum {
                        for (_,count) in unreadNums {
                            if count > 0 {
                                hasUnread = true
                                break
                            }
                        }
                    }
                    YXMessageButton.brokerRedIsHidden = !hasUnread
                default:
                    YXMessageButton.brokerRedIsHidden = true
                }
            case .failed(_):
               break
            }
            } as YXResultResponse<YXMsgUnreadNumResponseModel>).disposed(by: self.disposeBag)
    }
    
    private func registerNotifications() {
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLogin))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }
                
                self.stopCheckMsgStatus()
//                self.checkMsgStatus()
                self.startCheckMsgStatus()
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiLoginOut))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }
                
                YXMessageButton.pointIsHidden = true
                YXMessageButton.brokerRedIsHidden = true
                self.stopCheckMsgStatus()
            })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.launchOptions = launchOptions

        self.registerNotifications()
        
        if YXUserManager.isLogin() {
            self.startCheckMsgStatus()
            self.getUnReadNum()
         //   self.checkMsgStatus()
        }
        
        return true
    }
    
    private func startCheckMsgStatus() {
        self.stopCheckMsgStatus()

        self.checkMsgStausTimerBag = DisposeBag()

        if let checkMsgStausTimerBag = self.checkMsgStausTimerBag {
            let interval = RxTimeInterval.seconds(60)
            Observable<Int>.timer(RxTimeInterval.seconds(0), period: interval, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.getUnReadNum()
                //self.checkMsgStatus()
            }).disposed(by: checkMsgStausTimerBag)
        }
    }

    private func stopCheckMsgStatus() {
        self.checkMsgStausTimerBag = nil
    }
}
