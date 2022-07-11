//
//  YXSecuGroupService.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import YXKit


class YXSecuItem:NSObject, YXSecuIDProtocol {
    func secuId() -> YXSecuID {
        YXSecuID(market: self.market, symbol: self.symbol)
    }
    var name : String?

    var market: String
    
    var symbol: String
    
    init(name: String?, market: String, symbol: String) {
        self.name = name
        self.market = market
        self.symbol = symbol
    }
    
    static func == (lhs: YXSecuItem, rhs: YXSecuItem) -> Bool {

        lhs.market == rhs.market && lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }
}

class YXSecuGroupService: NSObject, ApplicationService {
    
    var loginObserver: Any?
    var logoutObserver: Any?
    var guestUUIDObserver: Any?
    
    var unLoad: Bool = true
    
    func configureSecuGroupManager() {
        let manager = YXSecuGroupManager.shareInstance()
        
        manager.stockMaxNum = YXGlobalConfigManager.configFrequency(.optStocksMaxNum)
        
        manager.getGroupIfNeed = { (complete) in
            if YXUserManager.userUUID() < 1 {
                return
            }
            if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
                appDelegate.appServices.optionalService.request(.getGroup(manager.version), response: { (response: YXResponseType<YXOptionalGroup>) in
                    switch response {
                    case .success(let result, let code):
                        if code == .success {
                            if let version = result.data?.version {
                                manager.version = Int(version);
                            }
                            
                            if let sortflag = result.data?.sortflag {
                                manager.sortflag = Int(sortflag);
                            }
                            
                            if let array = result.data?.group {
                                let groupList = array.map({ (group) -> YXSecuGroup in
                                    let item = YXSecuGroup()
                                    if let gid = group.gid, let gname = group.gname, let list = group.list {
                                        item.id = gid
                                        item.name = gname
                                        item.list = list.map({ (secuId) -> YXSecuID in
                                            YXSecuID(market: secuId.market ?? "", symbol: secuId.symbol ?? "")
                                        })
                                    }
                                    return item
                                })
                                //                            manager.allGroupList = groupList
                                manager.updateAllGroupList(withList: groupList)
                            }
                            //manager._update()
                            if let block = complete {
                                block()
                            }
                        } else if code == .optionalNone {
                            manager.postGroup()
                        }
                    case .failed(let error):
                        print(error)
                    }
                }).disposed(by: appDelegate.disposeBag)
            }
        }
        
        manager.postGroupIfNeed = { (complete) in
            if YXUserManager.userUUID() < 1 {
                return
            }
            
            let secuGroupList = manager.allGroupsForPostToServer.map({ (group: YXSecuGroup) -> SecuGroup in
                SecuGroup(gid: group.id, gname: group.name, list: group.list.map({ (secuId: YXSecuID) -> SecuId in
                    SecuId(market: secuId.market, symbol: secuId.symbol, sort: secuId.sort)
                }))
            })
            if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
                appDelegate.appServices.optionalService.request(.setGroup(manager.version, manager.sortflag, secuGroupList), response: { (response: YXResponseType<YXOptionalGroup>) in
                    switch response {
                    case .success(let result, let code):
                        if code == .success {
                            if let version = result.data?.version {
                                manager.version = Int(version);
                            }
                        } else if code == .versionDifferent {
                            manager.getGroupIfNeed(complete)
                        }
                    case .failed(let error):
                        print(error)
                    }
                }).disposed(by: appDelegate.disposeBag)
            }
        }
        
        manager.synchroHoldGroup = { (complete) in
            if YXUserManager.userUUID() < 1 ||  YXUserManager.canTrade() == false {
                return
            }
            //为解决 ： 已退出状态，token失效，但是还返回了用户信息，就会出现 已经退出，但是还是登录状态
            if YXUserManager.isLogin() {
                if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
                    appDelegate.appServices.stockOrderService.request(.hold(nil), response: { (response: YXResponseType<[YXHoldStock]>) in
                        switch response {
                        case .success(let result, let code):
                            if code == .success {
                                if let data = result.data {
                                    let array = data.map({ (holdStock) -> YXSecuID in
                                        YXSecuID(market:  holdStock.exchangeType?.market ?? "", symbol: holdStock.stockCode ?? "")
                                    })
                                    let secuGroup = YXSecuGroup()
                                    secuGroup.setDefaultGroupID(.IDHOLD)
                                    secuGroup.list = array;
                                    manager.holdSecuGroup = secuGroup;
                                    manager._update()
                                }
                                if let block = complete {
                                    block()
                                }
                            }
                        case .failed(let error):
                            print(error)
                        }
                    }).disposed(by: appDelegate.disposeBag)
                }
            }
        }
        
        if YXUserManager.isLogin() {
            manager.version = manager.loginedSecuGroupVersion
            manager.sortflag = manager.loginedSecuGroupSortflag
            manager.state = .logined
        } else {
            manager.version = manager.unloginSecuGroupVersion
            manager.sortflag = manager.unloginSecuGroupSortflag
            manager.state = .unLogin
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        loginObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiLogin), object: nil, queue: OperationQueue.main) { (ntf) in
            let firstLogin = ntf.userInfo?[YXUserManager.notiFirstLogin] as? Bool
            manager.login(firstLogin ?? false)
        }
        
        if let observer = logoutObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        logoutObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiLoginOut), object: nil, queue: OperationQueue.main) { (ntf) in
            manager.logout()
        }
        
        if let observer = guestUUIDObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        guestUUIDObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(YXUserManager.notiGuestsUUID), object: nil, queue: OperationQueue.main) { (ntf) in
            manager.guessLogin()
        }
        
        manager.getGroup()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureSecuGroupManager()
        return true
    }
}
