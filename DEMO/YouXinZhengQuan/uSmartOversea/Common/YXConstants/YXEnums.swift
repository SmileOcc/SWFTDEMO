//
//  YXEnums.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// 交易所類型（0：港股，5：美股）
@objc enum YXExchangeType: Int {
    case hk     = 0
    case us     = 5
    case sh     = 6
    case sz     = 7
    case usop   = 51
    case hs     = 67
    case sg     = 100
    case unknown
    
    var market: String {
        switch self {
        case .hk:
            return kYXMarketHK          //"hk"
        case .us:
            return kYXMarketUS          //"us"
        case .sh:
            return kYXMarketChinaSH     //"sh"
        case .sz:
            return kYXMarketChinaSZ     //"sz"
        case .hs:
            return kYXMarketChinaHS     //"hs"
        case .usop:
            return kYXMarketUsOption
        case .sg:
            return kYXMarketSG
        case .unknown:
            return kYXMarketHK
        }
    }
    
    static func market(_ exchangeType: Int?) -> String {
        if exchangeType == YXExchangeType.hk.rawValue {
            return kYXMarketHK
        } else if exchangeType == YXExchangeType.us.rawValue {
            return kYXMarketUS
        } else if exchangeType == YXExchangeType.sh.rawValue {
            return kYXMarketChinaSH
        } else if exchangeType == YXExchangeType.sz.rawValue {
            return kYXMarketChinaSZ
        } else if exchangeType == YXExchangeType.hs.rawValue {
            return kYXMarketChinaHS
        } else if exchangeType == YXExchangeType.usop.rawValue {
            return kYXMarketUsOption
        } else if exchangeType == YXExchangeType.sg.rawValue {
            return kYXMarketSG
        }  else {
            return ""
        }
    }
    
    static func exchangeType(_ market: String?) -> YXExchangeType {
        if market == YXMarketType.HK.rawValue {
            return .hk
        } else if market == YXMarketType.US.rawValue {
            return .us
        } else if market == YXMarketType.USOption.rawValue {
            return .usop
        } else if market == YXMarketType.SG.rawValue {
            return .sg
        } else {
            return .hs
        }
    }
    
    static func exchangeType1(_ market: String?) -> YXExchangeType? {
        if market == YXMarketType.HK.rawValue {
            return .hk
        } else if market == YXMarketType.US.rawValue {
            return .us
        } else if market == YXMarketType.USOption.rawValue {
            return .usop
        } else if market == YXMarketType.SG.rawValue {
            return .sg
        }  else {
            return nil
        }
    }
    
    static func currentType(_ exchangeType: Int?) -> YXExchangeType {
        var type: YXExchangeType = YXExchangeType.hk
        if let exchange = exchangeType,
            let tempExchange = YXExchangeType(rawValue: exchange) {
            type = tempExchange
        }
        return type
    }
    
    var moneyType: Int {
        switch self {
        case .hk:
            return 2
        case .us,
             .usop:
            return 1
        case .sh,
             .sz,
             .hs:
            return 0
        case .sg:
            return 3
        case .unknown:
            return 2
        }
    }
    
    var coinName: String {
        switch self {
        case .hk:
            return YXLanguageUtility.kLang(key: "common_hk_dollar")
        case .us,
             .usop:
            return YXLanguageUtility.kLang(key: "common_us_dollar")
        case .sh,
             .sz,
             .hs:
            return YXLanguageUtility.kLang(key: "common_rmb")
        case .sg:
            return YXLanguageUtility.kLang(key: "common_sg_dollar")
        case .unknown:
            return YXLanguageUtility.kLang(key: "common_hk_dollar")
        }
    }
    
    var text: String {
        switch self {
        case .us:
            return "USD"
        case .hk:
            return "HKD"
        case .sg:
            return "SGD"
        default:
            return "USD"
        }
    }
    
    var textForLable: String {
        switch self {
        case .us:
            return "(USD)"
        case .hk:
            return "(HKD)"
        case .sg:
            return "(SGD)"
        default:
            return "US"
        }
    }
    
    var displayText : String{
        switch self {
        case .us:
            return YXLanguageUtility.kLang(key: "account_market_us")
        case .hk:
            return YXLanguageUtility.kLang(key: "account_market_hk")
        case .sg:
            return YXLanguageUtility.kLang(key: "account_market_sg")
        default:
            return ""
        }
    }
    
}

enum YXMarketType: String {
    case HK = "hk"
    case US = "us"
    case ChinaSH = "sh"
    case ChinaSZ = "sz"
    case ChinaHS = "hs" //A股沪深
    case USOption = "usoption" //美股期权
    case Cryptos = "cryptos" //数字货币
    case SG = "sg"       //新加坡股票
    case none = "none"

    
    var name: String {
        switch self {
        case .HK:
            return YXLanguageUtility.kLang(key: "community_hk_stock")
        case .US:
            return YXLanguageUtility.kLang(key: "community_us_stock")
        case .ChinaHS:
            return YXLanguageUtility.kLang(key: "community_cn_stock")
        case .USOption:
            return YXLanguageUtility.kLang(key: "options")
        case .SG:
            return YXLanguageUtility.kLang(key: "community_sg_stock")
        default:
            return ""
        }
    }
    
    var iconBackgroundColor: UIColor? {
        switch self {
        case .HK:
            return UIColor.themeColor(withNormalHex: "#944EFF", andDarkColor: "#763ECC")
        case .US, .USOption:
            return UIColor.themeColor(withNormalHex: "#3489FF", andDarkColor: "2A6ECC")
        case .ChinaHS, .ChinaSZ, .ChinaSH:
            return UIColor(hexString: "#FF415D")
        case .Cryptos:
            return UIColor(hexString: "#F8C900")
        case .SG:
            return UIColor.themeColor(withNormalHex: "#F2397B", andDarkColor: "#BF2D61")
        default:
            return .clear
        }
    }
}

extension YXExchangeType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXExchangeType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum YXSecurityType {
    case stock
    case bond
    case fund
}
