//
//  YXSocketSingletonDeleage.swift
//  uSmartOversea
//
//  Created by ellison on 2018/12/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import YXKit
import RxSwift

class YXSocketSingletonService: NSObject, ApplicationService  {
    let disposeBag = DisposeBag()
    
    var uuidObserver: Any?
    var tokenObserver: Any?
    var languageObserver: Any?
    
    let messageCenterService = YXMessageCenterService.shared
    
    var didActive: Bool = false
    
    private func checkMsgStatus() {
        self.messageCenterService.request(.getMsg, response: { (response) in
            switch response {
            case .success(let result, let code):
                switch code {
                case .success?:
                    if YXUserManager.isLogin() {
                        if result.data?.system?.newFlag == 1 || result.data?.business?.newFlag == 1 || result.data?.stockNotify?.newFlag == 1 || result.data?.news?.newFlag == 1 || result.data?.activity?.newFlag == 1{
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
    
   private func getUnReadNum() {
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
    
    func configureSocket() {
        YXSocketSingleton.shareInstance().uuid = YXUserManager.userUUID()
        YXSocketSingleton.shareInstance().accessToken = YXUserManager.shared().curLoginUser?.token;
        YXSocketSingleton.shareInstance().deviceId = YXConstant.deviceUUID
        // 港版App的AppType默认为.HK
        YXSocketSingleton.shareInstance().appType = .OVERSEA_SG
        
        let currentLanguage: YXLanguageType = YXUserManager.curLanguage()
        switch currentLanguage {
        case .CN:
            // 简体中文
            YXSocketSingleton.shareInstance().langType = .ZHSIMPLE
        case .HK,
             .unknown:
            // 繁体中文
            YXSocketSingleton.shareInstance().langType = .ZH
        case .EN:
            // 英文
            YXSocketSingleton.shareInstance().langType = .EN
        case .ML:
            // 马来语
            YXSocketSingleton.shareInstance().langType = .ML
        case .TH:
            // 泰语
            YXSocketSingleton.shareInstance().langType = .TH
        }
        
        
        YXSocketSingleton.shareInstance().urls = YXUrlRouterConstant.socketBaseUrl()

        if let observer = uuidObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        uuidObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiUpdateUUID), object: nil, queue: OperationQueue.main) { (ntf) in
            if self.didActive == true {
                YXQuoteManager.sharedInstance.removeAllRequest()
                YXSocketSingleton.shareInstance().needReconnect = true
                YXSocketSingleton.shareInstance().cutOffSocket()
                
                YXSocketSingleton.shareInstance().uuid = YXUserManager.userUUID()
                YXSocketSingleton.shareInstance().accessToken = YXUserManager.shared().curLoginUser?.token;
                YXSocketSingleton.shareInstance().socketConnectHost()
            }
        }

        if let observer = tokenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        tokenObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiUpdateToken), object: nil, queue: OperationQueue.main) { (ntf) in
            YXSocketSingleton.shareInstance().accessToken = YXUserManager.shared().curLoginUser?.token;
            if (YXSocketSingleton.shareInstance().connecting == false) {
                YXSocketSingleton.shareInstance().needReconnect = true
                YXSocketSingleton.shareInstance().authWithServer()
            }
        }
        
        if let observer = languageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        languageObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiUpdateLanguage), object: nil, queue: OperationQueue.main, using: { (ntf) in
            YXSocketSingleton.shareInstance().needReconnect = true
            YXSocketSingleton.shareInstance().cutOffSocket()
            
            let currentLanguage: YXLanguageType = YXUserManager.curLanguage()
            switch currentLanguage {
            case .CN:
                // 简体中文
                YXSocketSingleton.shareInstance().langType = .ZHSIMPLE
            case .HK,
                 .unknown:
                // 繁体中文
                YXSocketSingleton.shareInstance().langType = .ZH
            case .EN:
                // 英文
                YXSocketSingleton.shareInstance().langType = .EN
            case .ML:
                // 马来语
                YXSocketSingleton.shareInstance().langType = .ML
            case .TH:
                // 马来语
                YXSocketSingleton.shareInstance().langType = .TH
                
            }
            YXSocketSingleton.shareInstance().socketConnectHost()
        })
        
        YXSocketSingleton.shareInstance().messageBlock = { (dict) in
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                if let model = try? JSONDecoder().decode(YXNoticeStruct.self, from: data) {
                    if model.pushType == YXPushType.fringe {
                        if model.msgType == YXMessageType.smartNoti.rawValue {
                            YXMessage.handleMessage(model)
                        }
                    } else if model.pushType == YXPushType.pop {
                        let noticeModel = YXNoticeModel(msgId: model.msgId ?? 0, title: model.title ?? "", content: model.content ?? "", pushType: model.pushType ?? .none, pushPloy: model.pushPloy ?? "", msgType: model.msgType ?? 0, contentType: model.contentType ?? 0, startTime: model.startTime ?? 0.0, endTime: model.endTime ?? 0.0, createTime: model.createTime ?? 0.0, newFlag: model.newFlag ?? 0)
                        let current = UIViewController.current()
                     //   YXPopManager.shared.showPop(noticeModel: noticeModel,vc:current, showPage: 0)
                    } else if model.pushType == YXPushType.message {
                        self.getUnReadNum()
                    }
                }
            }
        } 
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureSocket()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        YXSocketSingleton.shareInstance().cutOffSocket()
        ServerNode.cancelRemoteRequest()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if YXSocketSingleton.shareInstance().connecting == false {
            didActive = true
            ServerNode.requestServerNode()
        }
    }
}
 
