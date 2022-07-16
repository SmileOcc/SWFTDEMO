//
//  HCNavigatorPaths.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import Foundation

public protocol HCModuleType {
    var scheme: String { get }
    
    var path: String { get }
    
    var url: String { get }
}

@objc protocol HCModulePathServices {
    @objc func pushPath(_ path: HCModulePaths, context: Any?, animated: Bool)
    @objc func presentPath(_ path: HCModulePaths, context: Any?, animated: Bool, completion: (() -> Void)?)
}

@objc enum HCModulePaths: Int {
    
    // 代码搜索
    case search
    
    
    // 用户中心
    case userCenter
 
    // 用户中心-设置
    case userCenterSet
    
    // 用户中心-收藏
    case userCenterCollect
    
    // 用户中心-账户与安全
    case userCenterUserAccount
    
    // 注册Code
    case registerCode
    
    // 普通用户注册Code
    case normalRegisterCode
    
    // 普通用户注册设置密码
    case normalRegisterSetPwd
    
    // 关于
    case userCenterAbout
    
    case market

}

let NavigatiorScheme = "URLDEMO://"

extension HCModulePaths: HCModuleType {
    var scheme: String {
        NavigatiorScheme
    }
    
    var path: String {
        switch self {
        case .search:
            return "search/"
        case .userCenter:
            return "userCenter/"
        case .userCenterSet:
            return "userCenter/set/"
        case .userCenterCollect:
            return "userCenter/Collect/"
        case .registerCode:
            return "registerCode/"
        case .normalRegisterCode:
            return "normalRegisterCode/"
        case .normalRegisterSetPwd:
            return "normalRegisterSetPwd/"
        case .userCenterAbout:
            return "userCenter/about/"
        case .userCenterUserAccount:
            return "userCenter/account/"
        case .market:
            return "market/"
        }
    }
    
    var url: String {
        scheme + path
    }
}
