//
//  YXQuoteTipHelper.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/8/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXQuoteTipHelper: NSObject {
    
    @objc static let shared = YXQuoteTipHelper()
    
    @objc static let kOpenAccount: String = "OpenAccount"
    @objc static let kLogin: String = "Login"
    
    @objc static let kNotificationName = "YXQuoteTipNotification"
    
    var hasUSCoupon = false
    var hasHKCoupon = false
    var hasUSOptionCoupon = false
    
    private func cancelCoupon(_ exchangeType: YXExchangeType) {
        if exchangeType == .hk {
            hasHKCoupon = false
        } else if exchangeType == .us {
            hasUSCoupon = false
        } else if exchangeType == .usop {
            hasUSOptionCoupon = false
        }
    }
    
    private func addCoupon(_ exchangeType: YXExchangeType) {
        var postNoti = false
        if exchangeType == .hk, hasHKCoupon == false  {
            hasHKCoupon = true
            postNoti = true
        } else if exchangeType == .us, hasUSCoupon == false {
            hasUSCoupon = true
            postNoti = true
        } else if exchangeType == .usop, hasUSOptionCoupon == false {
            hasUSOptionCoupon = true
            postNoti = true
        }
        
        if postNoti {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXQuoteTipHelper.kNotificationName), object: exchangeType.market)
        }
    }
    
    @objc func requestUnusedCoupon(_ markets: [String]) {
        guard YXUserManager.isLogin() else {
            return
        }
        for market in markets {
            self.requestSingleUnusedCoupon(market)
        }
    }
    
    fileprivate func requestSingleUnusedCoupon(_ market: String) {
        
        guard market == kYXMarketHK || market == kYXMarketUS || market == kYXMarketUsOption else {
            return
        }
        
        let level = YXUserManager.shared().getLevel(with: market)
        let finishedAmount = YXUserManager.shared().curLoginUser?.finishedAmount ?? false
        let exchangeType: YXExchangeType = market.exchangeType
        if finishedAmount, level.rawValue > YXUserLevel.hkBMP.rawValue {
            
            cancelCoupon(exchangeType)
            return
        }
        
        
        let requestModel = YXQuoteTipRequestModel()
        requestModel.marketType = exchangeType.rawValue
        
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock { responseModel in
            if responseModel.code == .success, let data = responseModel.data, let model = YXQuoteTipModel.yy_model(with: data), let list = model.list, list.count > 0 {
            
                for info in list {
                    if info.status == 1, info.activated == 2 {
                        self.addCoupon(exchangeType)
                        break
                    }
                }
            }
        } failure: { _ in
             
        }
    }
    
    
    @objc class func isShowTip(_ market: String) -> Bool {
        
        guard market == kYXMarketHK || market == kYXMarketUS || market == kYXMarketUsOption || market == kYXMarketSG else {
            return false
        }
        
        if !YXUserManager.isLogin() {
            return true
        }

        if market == kYXMarketHK {
            let level = YXUserManager.shared().getLevel(with: market)
            if level.rawValue < QuoteLevel.level1.rawValue {
                return true
            }
        } else if market == kYXMarketUS {
            let userLevle = YXUserManager.shared().getLevel(with: kYXMarketUS)
            if userLevle == .delay {
                return true
            }
        } else if (market == kYXMarketUsOption) {
            if YXUserManager.shared().getOptionQuoteAuthority() == .delay {
                return true
            }
        } else if market == kYXMarketSG {
            let level = YXUserManager.shared().getLevel(with: market)
            if level == .delay {
                return true
            }
        }
        
        return false
    }
    

    @objc class func tipMessage(_ market: String) -> YXQuoteTipMessageInfo {
        
        let info = YXQuoteTipMessageInfo()
        
        if !YXUserManager.isLogin() {
            if market == kYXMarketHK {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_hk_advance")
            } else if market == kYXMarketUS {
                info.message = YXLanguageUtility.kLang(key: "depth_register_tip")
            } else if market == kYXMarketSG {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_sg_advance")
            }
            info.buttonTitle = YXLanguageUtility.kLang(key: "default_loginTip")
            info.jumpUrl = YXQuoteTipHelper.kLogin
            
            return info
        }
        
        let openAccount = YXUserManager.canTrade()

        
        if market == kYXMarketHK {
            let level = YXUserManager.shared().getLevel(with: market)
            if !openAccount {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_hk_advance")
                info.buttonTitle = YXLanguageUtility.kLang(key: "account_open")
                info.jumpUrl = YXQuoteTipHelper.kOpenAccount
            } else if level.rawValue < YXQuoteAuthority.level1.rawValue {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_hk_advance")
                info.jumpUrl = YXH5Urls.YX_MY_QUOTES_URL(tab: 2)
                info.buttonTitle = YXLanguageUtility.kLang(key: "depth_order_get")
            }
            
        } else if market == kYXMarketUS {
                        
            let userLevle = YXUserManager.shared().getLevel(with: kYXMarketUS)
            if !openAccount {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_hk_advance")
                info.buttonTitle = YXLanguageUtility.kLang(key: "account_open")
                info.jumpUrl = YXQuoteTipHelper.kOpenAccount
            } else if userLevle == .delay {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_us_advance")
                info.jumpUrl = YXH5Urls.YX_MY_QUOTES_URL(tab: 1)
                info.buttonTitle = YXLanguageUtility.kLang(key: "depth_order_get")
            }
        } else if (market == kYXMarketSG) {
            let level = YXUserManager.shared().getLevel(with: market)
            if !openAccount {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_sg_advance")
                info.buttonTitle = YXLanguageUtility.kLang(key: "account_open")
                info.jumpUrl = YXQuoteTipHelper.kOpenAccount
            } else if level == .delay {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_sg_advance")
                info.buttonTitle = YXLanguageUtility.kLang(key: "tip_quote_get_sg_now")
                info.jumpUrl = YXH5Urls.YX_MY_QUOTES_URL(tab: 0)
            }
        } else if (market == kYXMarketUsOption) {
            if !YXUserManager.isOption(kYXMarketUS) {
                info.message = YXLanguageUtility.kLang(key: "tip_quote_usOption_advance")
                info.buttonTitle = YXLanguageUtility.kLang(key: "depth_order_get")
                info.jumpUrl = YXH5Urls.YX_MY_QUOTES_URL(tab: 1)
            }
        }
        
        return info
    }
}


class YXQuoteTipMessageInfo: NSObject {
    
    @objc var message: String = ""
    @objc var buttonTitle: String = ""
    @objc var jumpUrl: String = ""

}
