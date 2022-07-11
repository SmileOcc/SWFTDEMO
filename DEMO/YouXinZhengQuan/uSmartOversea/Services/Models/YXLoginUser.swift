//
//  YXLogin.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

//用户信息
import UIKit

/// App语言类型定义
///
/// - CN: 简体
/// - HK: 繁体
/// - EN: 英文
@objc enum YXLanguageType: Int {
    case CN = 0x01
    case HK = 0x02
    case EN = 0x03
    case ML = 0x04
    case TH = 0x05
    case unknown
    
    var identifier: String {
        switch self {
        case .CN:
            return "zh-Hans"
        case .HK:
            return "zh-Hant"
        case .EN, .unknown:
            return "en"
        case .ML:
            return "ms"
        case .TH:
            return "th"
        }
    }
    
}

extension YXLanguageType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXLanguageType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

/// App涨跌颜色定义
///
/// - rRaiseGFall: 红涨绿跌
/// - gRaiseRFall: 绿涨红跌
@objc enum YXLineColorType: Int {
    case rRaiseGFall = 0x01
    case gRaiseRFall = 0x02
    case unknown
}

extension YXLineColorType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXLineColorType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


///港版报价图表 1-简约折线 2-简约K线 3-高级折现 4-高级K线
@objc enum YXQuoteChartHkType: Int {
    case simplifiedLine = 0x01
    case simplifiedK    = 0x02
    case advanced       = 0x03
    case unknown
}

extension YXQuoteChartHkType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXQuoteChartHkType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

///港版智能排序 0-关 1-开
@objc enum YXSortHK: Int {
    case off    = 0x00
    case on     = 0x01
    case unknown
}

extension YXSortHK: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXSortHK(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

/*1, "普通账户"
2, "高级账户-大陆"
3, "高级账户-香港"*/
@objc enum YXUserRoleType: Int {
    case common             = 1
    case seniorMainland     = 2
    case seniorHK           = 3
    case prolevel2          = 4
    case unknown
}

@objc enum YXUserProType: Int {
    case common             = 0
    case level1             = 1
    case level2             = 2
    case unknown
}


extension YXUserRoleType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXUserRoleType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

/// 账户类型
@objc enum YXAccountType: Int {
    case cash               = 1     //现金账户
    case financing          = 2     //保证金账户
    case unknown
}

extension YXAccountType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXAccountType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

@objc
public enum YXExtendStatusBitType: Int {
    case loginPwd           = 0b00000001    //登录密码
    case hqAuthority        = 0b00000010 //1 << 1    //行情权限 是否有绑定美股行情权限，如果为false，一定要弹出h5，强制弹出。
    case derivative         = 0b00000100    //衍生品
    case bondRiskAuth       = 0b00001000    //债券签名
    case fundRiskAuth       = 0b00010000    //基金
    case actQuotRiskAuth    = 0b00100000    //暗盘
    case auth2login    =    0b010000000000    //双重验证
    case unknown
}

@objc
public enum YXOrgStatusBitOtherType: Int {
    case quoteStatement    =  0b0000010000000000    //跳过行情声明
    case unknown
}


extension YXExtendStatusBitType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXExtendStatusBitType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

//用户灰度状态
@objc public enum YXGrayStatusBitType: Int {
    case fund       = 0b00000001    // 1<<0 基金
    case actualQuot = 0b00000010    // 1<<1 暗盘 2^1=2
    case bond       = 0b00000100    // 1<<2 债券 2^2=4
    case pinTuan    = 0b00100000    // 1<<5 拼团灰度  2^5=4*4*2=32
    case margin     = 0b01000000    // 1 << 6,   //保证金账户 2^6=4*4*4=64
    case preAfter      = 0b10000000000 // 1<< 10 盘前盘后
    case hsMargin   = 0b010000000000000000    // 1 << 16 A股融资灰度
    case unknown
}

extension YXGrayStatusBitType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXGrayStatusBitType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

//交易市场(bitmap)
public enum YXMarketBitType: Int {
    case hk = 0b00000001    // 1<<0 港股
    case us = 0b00000010    // 1<<1 美股
    case hs = 0b00000100    // 1<<2 A股通
    case unknown
}

extension YXMarketBitType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXMarketBitType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum YXIdentifyType: Int {
    case mainlandId             = 1 //大陆身份证
    case HKId                   = 2 //香港身份证
    case password               = 3 //护照
    case HKPermanentResident    = 4 //香港永久居民身份证
    case unknown
}

extension YXIdentifyType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXIdentifyType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

/*
 areaCode           //区号
 thirdBindBit       //绑定位 手机1<<0 微信 1<<1 微博1<<2 YXLoginBindType?
 extendStatusBit    //用戶扩展状态  1<<0 登录密码 1<<1 行情权限 1<<2 衍生品
 userQuotationVOList    //用户行情权限信息
 */
struct YXLoginUser: Codable {
    var uuid: Double?
    var uuidStr: String?
    var areaCode, phoneNumber: String?
    var email: String?
    var nickname: String?
    var avatar: String?
    /*YXLoginBindType
     绑定位 手机1<<0 微信 1<<1 微博1<<2  */
    var thirdBindBit: UInt64?
    var userQuotationVOList, highestUserQuotationVOList: UserQuotationVOList?
    var financialProfessional,openUpPurchasePower: Bool?
    /*另外从接口获取*/
//    var openedAccount = false
    var tradePassword = false
    
    var fundAccount, clientID: String?
    var finishedAmount: Bool?
    var languageCN, languageHk: YXLanguageType?
    var lineColorHk: YXLineColorType?
    var accountType: YXAccountType?
    var cnAccountType: YXAccountType?
    var hkAccountType: YXAccountType?
    var usAccountType: YXAccountType?
    var intradayMarket: JSONAny?
    var optionMarket: JSONAny?
    var shortSellingMarket: JSONAny?
    /*YXExtendStatusBitType
     用戶扩展状态  1<<0 登录密码 1<<1 行情权限 1<<2 衍生品 1<<3 债券风险许可 1<<4 基金风险许可 1<<5 暗盘风险许可 */
    var extendStatusBit: Int?
    var invitationCode: String?
    var identifyType, identifyCountryCode: Int?
    var appfirstLogin: Bool?
    var token: String?    
    var expiration: Int64? //时间戳
    var quoteChartHk: YXQuoteChartHkType?
    var sortHk: YXSortHK?
    let phoneSet: Int?
    let smsSet: Int?
    let emailSet: Int?
    let mailSet: Int?
    /*YXGrayStatusBitType
     用户灰度状态 1<<0 基金 1<<1 暗盘 */
    let grayStatusBit: Int?
    let marketBit: Int? //交易市场(bitmap):1<<0 港股 1<<1 美股 1<<2 A股通
    
    //其他
    var thirdPartyID: String?
    var signInSource: Int?
    var accountStatus: Int?   //交易账号状态 0正常1冻结
    var majorStatus: Int?       //pro标签 专业投资者认证状态: 0-未申请 1-待初审 2-待终审 3-审核未通过 4-审核通过
    /*1, "普通账户"
    2, "高级账户-大陆"
    3, "高级账户-香港"*/
    var userRoleType:YXUserRoleType?
    var userAutograph: String?  //用户签名，大陆身份证优先返回中文名，非大陆身份证优先返回英文名
    
    var orgEmailLoginFlag: Bool?
    var openedAccount: Bool? //是否开户，现在仅是机构账号使用
    // 1 的话是master
    var orgUserIsMaster: Int?
    
    //dolphinNo 海外版独有
    var dolphinNo:String?
    //登陆券商
    //    登录券商类型:dolphin-无券商，sg-新加坡券商，nz-新西兰券商
    var securitiesLoginType:String?
    var securitiesOpened:Int?
    var clientId : String = "" //券商登陆后的SG时使用
    var kol: Bool?
    var guideAccountFlag: Bool? //登录注册是否跳转开户界面
    
    enum CodingKeys: String, CodingKey {
        case uuid, uuidStr, areaCode, phoneNumber, email, nickname, avatar, thirdBindBit, userQuotationVOList, fundAccount, openUpPurchasePower, highestUserQuotationVOList,financialProfessional
        case clientID = "clientId"
       // case clientId = "clientId"
        
        case finishedAmount, lineColorHk
        case languageCN = "languageCn"
        case languageHk, accountType,cnAccountType, hkAccountType, usAccountType, extendStatusBit, invitationCode, identifyType, identifyCountryCode, appfirstLogin, token, expiration
        //其他
        case thirdPartyID = "thirdPartyID"
        case signInSource, accountStatus
        case quoteChartHk, sortHk
        case phoneSet = "phoneSet"
        case smsSet = "smsSet"
        case emailSet = "emailSet"
        case mailSet = "mailSet"
        case grayStatusBit = "grayStatusBit"
        case marketBit = "marketBit"
        case majorStatus = "majorStatus"
        case userRoleType = "userRoleType"
        case userAutograph
        case intradayMarket
        case optionMarket
        case shortSellingMarket
        case orgEmailLoginFlag, orgUserIsMaster, openedAccount, guideAccountFlag
        case dolphinNo = "dolphinNo"
        case securitiesLoginType
        case securitiesOpened
    }
    
//    init(from decoder: Decoder) throws {
//        
//    }
}

/*
 areaCode           //区号
 thirdBindBit       //绑定位 手机1<<0 微信 1<<1 微博1<<2 YXLoginBindType?
 extendStatusBit    //用戶扩展状态  1<<0 登录密码 1<<1 行情权限 1<<2 衍生品
 userQuotationVOList    //用户行情权限信息
 */
// 后台改了 uuid 的类型.临时额外增加个model
struct YXLoginUser2: Codable {
    
    var uuid: String?
    var uuidStr: String?
    var areaCode, phoneNumber: String?
    var email: String?
    var nickname: String?
    var avatar: String?
    /*YXLoginBindType
     绑定位 手机1<<0 微信 1<<1 微博1<<2  */
    var thirdBindBit: UInt64?
    var userQuotationVOList, highestUserQuotationVOList: UserQuotationVOList?
    var financialProfessional,openUpPurchasePower: Bool?
    /*另外从接口获取*/
//    var openedAccount = false
    var tradePassword = false
    
    var fundAccount, clientID: String?
    var finishedAmount: Bool?
    var languageCN, languageHk: YXLanguageType?
    var lineColorHk: YXLineColorType?
    var accountType: YXAccountType?
    var cnAccountType: YXAccountType?
    var hkAccountType: YXAccountType?
    var usAccountType: YXAccountType?
    var intradayMarket: JSONAny?
    var optionMarket: JSONAny?
    /*YXExtendStatusBitType
     用戶扩展状态  1<<0 登录密码 1<<1 行情权限 1<<2 衍生品 1<<3 债券风险许可 1<<4 基金风险许可 1<<5 暗盘风险许可 */
    var extendStatusBit: Int?
    var invitationCode: String?
    var identifyType, identifyCountryCode: Int?
    var appfirstLogin: Bool?
    var token: String?
    var expiration: Int64? //时间戳
    var quoteChartHk: YXQuoteChartHkType?
    var sortHk: YXSortHK?
    let phoneSet: Int?
    let smsSet: Int?
    let emailSet: Int?
    let mailSet: Int?
    /*YXGrayStatusBitType
     用户灰度状态 1<<0 基金 1<<1 暗盘 */
    let grayStatusBit: Int?
    let marketBit: Int? //交易市场(bitmap):1<<0 港股 1<<1 美股 1<<2 A股通
    
    //其他
    var thirdPartyID: String?
    var signInSource: Int?
    var accountStatus: Int?   //交易账号状态 0正常1冻结
    var majorStatus: Int?       //pro标签 专业投资者认证状态: 0-未申请 1-待初审 2-待终审 3-审核未通过 4-审核通过
    /*1, "普通账户"
    2, "高级账户-大陆"
    3, "高级账户-香港"*/
    var userRoleType:YXUserRoleType?
    var userAutograph: String?  //用户签名，大陆身份证优先返回中文名，非大陆身份证优先返回英文名
    
    //登陆券商
    //    登录券商类型:dolphin-无券商，sg-新加坡券商，nz-新西兰券商
    var securitiesLoginType:String?
    var securitiesAccountOpened:Int?
    
    enum CodingKeys: String, CodingKey {
        case uuid, uuidStr, areaCode, phoneNumber, email, nickname, avatar, thirdBindBit, userQuotationVOList, fundAccount, openUpPurchasePower, highestUserQuotationVOList,financialProfessional
        case clientID = "clientId"
        
        case finishedAmount, lineColorHk
        case languageCN = "languageCn"
        case languageHk, accountType,cnAccountType, hkAccountType, usAccountType, extendStatusBit, invitationCode, identifyType, identifyCountryCode, appfirstLogin, token, expiration
        //其他
        case thirdPartyID = "thirdPartyID"
        case signInSource, accountStatus
        case quoteChartHk, sortHk
        case phoneSet = "phoneSet"
        case smsSet = "smsSet"
        case emailSet = "emailSet"
        case mailSet = "mailSet"
        case grayStatusBit = "grayStatusBit"
        case marketBit = "marketBit"
        case majorStatus = "majorStatus"
        case userRoleType = "userRoleType"
        case userAutograph
        case intradayMarket
        case optionMarket
        case securitiesLoginType
        case securitiesAccountOpened
    }
}

// MARK: - UserQuotationVOList
struct UserQuotationVOList: Codable {
    let usa: Hk?
    let hk: Hk?
    let zht: Hk?    //中华通
    //用户当前所在IP地区，1：国内，2：境外
    let location: Int?
    // 客户归属，1：大陆，2：香港（不适用，使用realAttribution）
    let attribution: Int?
    // 客户归属， 1：大陆， 2：香港
    let realAttribution: Int?
    let uso: Hk?    //期权
    
    
    let usaArca: Hk? //深度摆盘
    let usaThree: Hk? //三大指数
    let sg : Hk? //新加坡股票
    let usaNation: Hk? //全美行情
    
    enum CodingKeys: String, CodingKey {
        case usa = "usa"
        case hk = "hk"
        case zht = "zht"
        case location = "location"
        case attribution = "attribution"
        case realAttribution = "realAttribution"
        case uso = "uso"
        case usaArca
        case usaThree
        case sg
        case usaNation
    }
}

struct CheckPhoneV1Result: Codable, Equatable {
    let registered: Bool?
    //let activated: Bool?
}

struct Hk: Codable {
    var productID: Int?
    var productName, fullName: String?
    var shorterName: String?
    var productCategory, marketType, productIcon, source, productCode: Int?
    var status: Int?
    var statusTxt: String?
    var productURL: String?
    var effectTime, expireTime: String?
    
    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case productName, fullName, productCategory, marketType, productIcon, source,productCode, status, statusTxt,shorterName
        case productURL = "productUrl"
        case effectTime = "effect_time"
        case expireTime = "expire_time"
    }
}



//开户券商账号(bitmap)
@objc public enum YXBrokersBitType: Int {
    case dolph   = 0b10000000      //  dolph
    case nz      = 0b00000001       //  nz
    case sg      = 0b00000010       //  sg
    func brokerNo() -> String {
        switch self {
        case .nz:
            return "nz"
        case .sg:
            return "sg"
        default:
            return ""
        }
    }
    
    static func brokerValue(_ value:String)->YXBrokersBitType{
        switch value {
        case "nz":
            return .nz
        case "sg":
            return .sg
        case "dolphin":
            return .dolph
        default:
            return .dolph
        }
    }
}


//用户账户等级类型
@objc enum YXAccountLevelType:Int{
    case trade     = 0    //交易账户
    case stantard  = 1    //标准账户
    case intel     = 2    //高级账户
    case unkonw    = -1
}


/// 讨论模块默认选择的tab
@objc enum YXDiscussionSelectedType: Int {
    case globalTab               = 0     //全球
    case singaporeTab         = 1     //新加坡
}
