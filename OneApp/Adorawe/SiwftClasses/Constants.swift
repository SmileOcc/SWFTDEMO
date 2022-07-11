//
//  Constants.swift
// XStarlinkProject
//
//  宏定义转换
//  Created by fan wang on 2021/7/4.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

///函数常量
let STLLocalizedString_ = STLLocalizationString.shareLocalizable().stlLocalizedString

///字符串常量
extension String{
    static let kResult = "result"
    static let kStatusCode = "statusCode"
    static let kAddressCountrySelctCellId = "kAddressCountrySelctCellId"
    
    static var selectCountryTips:String {
        get{
            STLLocalizedString_("text_select_country_title")!
        }
    }
    static var selectProvinceTips:String{
        get{
            STLLocalizedString_("text_select_state_title")!
        }
    }
    static var selectCityTips:String{
        get {
            STLLocalizedString_("text_select_city_title")!
        }
    }
    static var selectAreaTips:String{
        get {
            STLLocalizedString_("text_select_district_title")!
        }
    }
    
    static var selecCountryBreds:String{
        get {
            STLLocalizedString_("country_region")!
        }
    }
    static var selecStateBreds:String{
        get {
            STLLocalizedString_("select_default_state")!
        }
    }
    static var selecCityBreds:String{
        get {
            STLLocalizedString_("select_default_city")!
        }
    }
    static var selecAreaBreds:String{
        get {
            STLLocalizedString_("address_select_default_town")!
        }
    }
    
    static var errorMsg:String{
        get {
            STLLocalizedString_("EmptyCustomViewManager_titleLabel")!
        }
    }
    
    
    static var FirstnameEmpytMsg:String{
        get {
            STLLocalizedString_("FirstnameEmpytMsg")!
        }
    }
    static var FirstnameMinLengthMsg:String{
        get {
            STLLocalizedString_("FirstnameMinLengthMsg")!
        }
    }
    static var LastnameEmptyMsg:String{
        get {
            STLLocalizedString_("LastnameEmptyMsg")!
        }
    }
    static var LastnameMinLengthMsg:String{
        get {
            STLLocalizedString_("LastnameMinLengthMsg")!
        }
    }
    static var StreetEmptyMsg:String{
        get {
            STLLocalizedString_("StreetEmptyMsg")!
        }
    }
    static var StreetValidMsg:String{
        get {
            STLLocalizedString_("StreetValidMsg")!
        }
    }
    static var CountryEmptyMsg:String{
        get {
            STLLocalizedString_("CountryEmptyMsg")!
        }
    }
    static var StateEmptyMsg:String{
        get {
            STLLocalizedString_("StateEmptyMsg")!
        }
    }
    static var CityEmptyMsg:String{
        get {
            STLLocalizedString_("CityEmptyMsg")!
        }
    }
    static var VillageEmptyMsg:String{
        get {
            STLLocalizedString_("VillageEmptyMsg")!
        }
    }
    static var PhoneEmptyMsg:String{
        get {
            STLLocalizedString_("PhoneEmptyMsg")!
        }
    }
    static var warningStringFor10:String{
        get {
            STLLocalizedString_("warningStringFor10")!
        }
    }
    static var warningStringFor11:String{
        get {
            STLLocalizedString_("warningStringFor11")!
        }
    }
    static var ZipMaxLengthMsg:String{
        get {
            STLLocalizedString_("ZipMaxLengthMsg")!
        }
    }
    static var ZipMinLengthMsg:String{
        get {
            STLLocalizedString_("ZipMinLengthMsg")!
        }
    }
    static var ZipValidMsg:String{
        get {
            STLLocalizedString_("ZipValidMsg")!
        }
    }
    
    static var addressAddAdress:String{
        get {
            STLLocalizedString_("addressAddAdress")!
        }
    }
    static var modifyAddress:String{
        get {
            STLLocalizedString_("modifyAddress")!
        }
    }
    
    static var viewMoreText:String{
        get {
            STLLocalizedString_("messageViewMore")!.uppercased()
        }
    }
}

///APIs
extension String{
    ///坑位配置
    static let InitIconApiPath = "system/init-icon"
    ///新品频道
    static let newInPath = "special/newin"
    ///新品加载更多
    static let newInMore = "special/get-channel-goods"
    ///四级联动
    static let cascadeAddress = "country/address-list"
    ///branch事件记录
    static let branchLogPath = "default/branch-log"
    ///社媒列表接口
    static let socialList = "social/list"
    
    ///发送验证码短信
    static let codSMSSend = "order/cod-confirm-code"
    ///验证
    static let codConfirm = "order/cod-confirm"
    ///断码订阅
    static let arrivalSubscribpath = "item/arrival-notice"
}

///便捷方法
extension String{
//    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
    static let kAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    // 沙盒路径
    static let kDocument_Path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    
    static let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
}

extension CGFloat {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let topSafeHeight:CGFloat = Bool.kIS_IPHONEX ? 24.0 : 0.0
    static let bottomSafeHeight:CGFloat = Bool.kIS_IPHONEX ? 34.0 : 0.0
    static let topNavHeight:CGFloat = (64 + topSafeHeight)

}

extension Bool{
    static let kIS_IPHONEX = (CGFloat.screenHeight >= 812.0)

}
