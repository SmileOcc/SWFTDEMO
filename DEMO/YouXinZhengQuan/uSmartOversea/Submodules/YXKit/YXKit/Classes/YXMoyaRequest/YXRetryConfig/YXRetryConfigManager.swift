//
//  YXRetryConfigManager.swift
//  Alamofire
//
//  Created by 井超 on 2019/11/7.
//

import UIKit
import MMKV
import NSObject_Rx
import SAMKeychain



@objc public class YXRetryConfigManager: NSObject {

    @objc public static let shareInstance = YXRetryConfigManager()
    
    @objc public static let guestsUUIDSuccess   = "noti_guestsUUIDSuccess"
    
    @objc public func requestGuestsUUID() {
        
        YXRetryConfigProvider.rx.request(.guests)
            .map(YXResult<YXGuestsLoginModel>.self)
            .subscribe(onSuccess: { (response) in
                         
                if response.code == YXResponseCode.success.rawValue, let model = response.data {
                    let service = YXKeyChainUtil.serviceName(serviceType: .Guest, bizType: .GuestUUID)
                    let account = YXKeyChainUtil.accountName(serviceType: .Guest)
                    let guestsUUID = SAMKeychain.password(forService: service, account: account)
                    if let guestsUUID = guestsUUID {
                        
                    } else {
                        NotificationCenter.default.post(name:  NSNotification.Name(YXRetryConfigManager.guestsUUIDSuccess), object: UInt64(model.uuid?.value ?? 0))
                        SAMKeychain.setPassword("\(UInt64(model.uuid?.value ?? 0))", forService: service, account: account)
                    }
                }
                
            }, onError: { (error) in
                log(.error, tag: kNetwork, content: "\(error)")
            }).disposed(by: rx.disposeBag)
    }
}
