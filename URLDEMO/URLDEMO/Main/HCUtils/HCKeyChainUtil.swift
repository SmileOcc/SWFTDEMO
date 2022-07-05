//
//  HCKeyChainUtil.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit


@objcMembers public class HCKeyChainUtil: NSObject {

    ///--------
    /// KEYCHAIN服务前缀
    /// 服务前缀分为三类：设备级别、游客级别、用户级别；每个级别的服务通过这些宏进行业务隔离，每个级别服务应根据自身的业务，在这些Prefix后再加上唯一的业务代号
    ///--------
    private static let SAM_KEYCHAIN_SERVICE_PREFIX = "yx_keychain_service_"
    private static let SAM_KEYCHAIN_DEVICE_SERVICE_PREFIX = SAM_KEYCHAIN_SERVICE_PREFIX + "device_"
    private static let SAM_KEYCHAIN_GUEST_SERVICE_PREFIX = SAM_KEYCHAIN_SERVICE_PREFIX + "guest_"
    private static let SAM_KEYCHAIN_USER_SERVICE_PREFIX = SAM_KEYCHAIN_SERVICE_PREFIX + "user_"
    
    ///--------
    /// KEYCHAIN账号
    /// 服务前缀分为三类：设备级别、游客级别、用户级别；
    /// 其中设备级别和游客级别的Account采用固定的模式，用户级别的应当使用YXUserManager中的userUUID作为Keychain的Account
    ///--------
    private static let SAM_KEYCHAIN_ACCOUNT_PREFIX = "yx_keychain_account_"
    private static let SAM_KEYCHAIN_DEVICE_ACCOUNT = SAM_KEYCHAIN_ACCOUNT_PREFIX + "device"
    private static let SAM_KEYCHAIN_GUEST_ACCOUNT = SAM_KEYCHAIN_ACCOUNT_PREFIX + "guest"
    
    @objc public enum YXKeyChainServiceType: Int {
        case Device, Guest, Account
    }
    
    @objc public enum YXKeyChainBizType: Int {
        case DeviceUUID
        case GuestUUID
    }
    
    private class func bizTypeDescription(bizType: YXKeyChainBizType) -> String {
        switch bizType {
        case .DeviceUUID:
            return "uuid"
        case .GuestUUID:
            return "uuid";
        default:
            assertionFailure("未知业务类型,请在YXKeyChainBizType中完善业务")
        }
        return ""
    }
    
    @objc public class func serviceName(serviceType: YXKeyChainServiceType, bizType: YXKeyChainBizType) -> String {
        switch serviceType {
        case .Device:
            return HCKeyChainUtil.SAM_KEYCHAIN_DEVICE_SERVICE_PREFIX + bizTypeDescription(bizType: bizType)
        case .Guest:
            return HCKeyChainUtil.SAM_KEYCHAIN_GUEST_SERVICE_PREFIX + bizTypeDescription(bizType: bizType)
        case .Account:
            return HCKeyChainUtil.SAM_KEYCHAIN_ACCOUNT_PREFIX + bizTypeDescription(bizType: bizType)
        }
    }
    
    @objc public class func accountName(serviceType: YXKeyChainServiceType) -> String {
        switch serviceType {
        case .Device:
            return HCKeyChainUtil.SAM_KEYCHAIN_DEVICE_ACCOUNT
        case .Guest:
            return HCKeyChainUtil.SAM_KEYCHAIN_GUEST_ACCOUNT
        case .Account:
            assertionFailure("未登录时，请使用YXKeyChainServiceTypeGuest作为serviceType")
            return ""
        }
    }
}
