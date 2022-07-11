//
//  YXConstant+Common.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

public enum DevicePlatformType {
    case none
    
    case iPhone_4
    case iPhone_4S
    case iPhone_5
    case iPhone_5c
    case iPhone_5s
    case iPhone_6
    case iPhone_6_Plus
    case iPhone_6s
    case iPhone_6s_Plus
    case iPhone_SE
    case iPhone_7
    case iPhone_7_Plus
    case iPhone_8
    case iPhone_8_Plus
    case iPhone_X
    case iPhone_XS
    case iPhone_XS_MAX
    case iPhone_XR
    
    case iPod_Touch_1G
    case iPod_Touch_2G
    case iPod_Touch_3G
    case iPod_Touch_4G
    case iPod_Touch_5Gen
    case iPod_Touch_6
    
    case iPad
    case iPad_3G
    case iPad_2_WiFi
    case iPad_2
    case iPad_2_CDMA
    case iPad_Mini_WiFi
    case iPad_Mini
    case iPad_Mini_GSM_CDMA
    case iPad_3_WiFi
    case iPad_3_GSM_CDMA
    case iPad_3
    case iPad_4_WiFi
    case iPad_4_GSM_CDMA
    case iPad_4
    case iPad_Air_WiFi
    case iPad_Air_Cellular
    case iPad_Mini_2_WiFi
    case iPad_Mini_2_Cellular
    case iPad_Mini_2
    case iPad_Mini_3
    case iPad_Mini_4_WiFi
    case iPad_Mini_4_LTE
    case iPad_Air_2
    case iPad_Pro_9_7
    case iPad_Pro_12_9
    case iPad_5_WiFi
    case iPad_5_Cellular
    case iPad_Pro_12_9_WiFi
    case iPad_Pro_12_9_Cellular
    case iPad_Pro_10_5_WiFi
    case iPad_Pro_10_5_Cellular
    
    case Apple_TV_2
    case Apple_TV_3
    case Apple_TV_4
    case Simulator
    
}

public enum DeviceScreenSize: NSInteger {
    case none
    case size3_5    //3.5英寸640_960   @2x 320x480   //iPhone 2G/3G/3GS/4/4s
    case size4      //4英寸640_1136    @2x 320x568   //iPhone 5/5s/5c/SE
    case size4_7    //4.7英寸750_1334  @2x 375x667   //iPhone 6/6s/7/8
    case size5_5    //5.5英寸1242_2208 @3x 414x736   //iPhone 6 Plus/6s Plus/7
    case size5_8    //5.8英寸1125_2436 @3x 375x812   //iPhone X/XS/11 Pro
    case size6_1    //6.1英寸828_1792  @2x 414x896   //iPhone XR/11
    case size6_5    //6.5英寸1242_2688 @3x 414x896   //iPhone XS Max/11 Pro Max
}

public enum ScreenPiexlScale: NSInteger {
    case scale1X
    case scale2X
    case scale3X
}

//获取 图片
public func getImage(name:String) -> UIImage? {
    if name.count == 0 { return nil}
    var tempName: String = name
    if !(name.hasSuffix("@2x") || name.hasSuffix("@3x")) {
        tempName = name + "@2x"
        if YXConstant.screenPiexlScale == .scale3X {
            tempName = name + "@3x"
        }
    }
    if let path = Bundle.main.path(forResource: tempName, ofType: "png") {
        return UIImage.init(contentsOfFile: path)
    }
    return UIImage.init(named: name)
}
/**
 适配的宽度比
 */
private let unifomHeight = UIScreen.main.bounds.size.height / 812.0
/**
 适配的高度比
 */
private let unifomWidth = UIScreen.main.bounds.size.width / 375.0
/// 等比例高度
///
/// - Parameter height: 原来的高度
/// - Returns: 统一后的高度
public func uniVerLength(_ height:CGFloat) -> CGFloat {
    unifomHeight * height
}
public func uniVerLength(_ height:CGFloat,uniHeight:CGFloat) -> CGFloat {
    UIScreen.main.bounds.size.height / uniHeight * height
}
/// 等比例宽度
///
/// - Parameter height: 原来的宽度
/// - Returns: 统一后的宽度
public func uniHorLength(_ width:CGFloat) -> CGFloat {
    unifomWidth * width
}
public func uniHorLength(_ width:CGFloat,uniWidth:CGFloat) -> CGFloat {
    UIScreen.main.bounds.size.width / uniWidth * width
}
/// 等比例文字大小
///
/// - Parameter height: 原来的文字大小
/// - Returns: 统一后的文字大小
public func uniSize(_ size:CGFloat) -> CGFloat {
    unifomWidth * size
}

/// 强制设置某种语言
///
/// - Parameter key: 某个文字的key
/// - Returns: 统一后的文字大小
public func forceLocalized(withKey key:String) {
    var language = ""
    switch YXUserManager.curLanguage() {
    case .CN:
        // 简体中文
        language = "zh-Hans"
    case .EN:
        // 英文
        language = "en"
    case .HK:
        language = "zh-Hant"//"zh-HK"
    default:
        language = "en"
    }
    if let path = Bundle.main.path(forResource: language, ofType: "lproj"),path.count > 0 {
        Bundle(path: path)?.localizedString(forKey: key, value: nil, table: "Localizable")
    }
}


extension YXConstant {
    //获取像素类型
    public static var screenPiexlScale: ScreenPiexlScale {
        switch YXConstant.screenSize {
        case .size3_5,.size4,.size4_7,.size6_1:
            return .scale2X
        case .size5_5,.size5_8,.size6_5:
            return .scale3X
        default:
            return .scale2X
        }
    }
    
    /// 获取屏幕尺寸类型
    public static var screenSize : DeviceScreenSize {
        let width = YXConstant.screenWidth
        let height = YXConstant.screenHeight
        if width == 320 && height == 480 {
            return .size3_5
        }
        else if width == 320 && height == 568 {
            return .size4
        }
        else if width == 375 && height == 667 {
            return .size4_7
        }
        else if width == 414 && height == 736 {
            return .size5_5
        }
        else if width == 375 && height == 812 {
            return .size5_8
        }
        else if width == 414 && height == 896 {
            if YXConstant.platform == .iPhone_XR {
                return .size6_1
            } else {
                return .size6_5
            }
        }
        else {
            return .none
        }
    }
    
    /*  设备型号 */
    public static var platform : DevicePlatformType {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { (identifier, elementin) -> String in
            guard let value = elementin.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case"iPhone3,1","iPhone3,2","iPhone3,3":     return .iPhone_4
        case"iPhone4,1":                             return .iPhone_4S
        case"iPhone5,1","iPhone5,2":                 return .iPhone_5
        case"iPhone5,3","iPhone5,4":                 return .iPhone_5c
        case"iPhone6,1","iPhone6,2":                 return .iPhone_5s
        case"iPhone7,2":                             return .iPhone_6
        case"iPhone7,1":                             return .iPhone_6_Plus
        case"iPhone8,1":                             return .iPhone_6s
        case"iPhone8,2":                             return .iPhone_6s_Plus
        case"iPhone8,3","iPhone8,4":                 return .iPhone_SE
        case"iPhone9,1","iPhone9,3":                 return .iPhone_7
        case"iPhone9,2","iPhone9,4":                 return .iPhone_7_Plus
        case"iPhone10,1","iPhone10,4":               return .iPhone_8
        case"iPhone10,2","iPhone10,5":               return .iPhone_8_Plus
        case"iPhone10,3","iPhone10,6":               return .iPhone_X
        case"iPhone11,2":                            return .iPhone_XS
        case"iPhone11,4","iPhone11,6":               return .iPhone_XS_MAX
        case"iPhone11,8":                            return .iPhone_XR
            
        case"iPod1,1":                               return .iPod_Touch_1G
        case"iPod2,1":                               return .iPod_Touch_2G
        case"iPod3,1":                               return .iPod_Touch_3G
        case"iPod4,1":                               return .iPod_Touch_4G
        case"iPod5,1":                               return .iPod_Touch_5Gen
        case"iPod7,1":                               return .iPod_Touch_6
            
        case"iPad1,1":                               return .iPad
        case"iPad1,2":                               return .iPad_3G
        case"iPad2,1":                               return .iPad_2_WiFi
        case"iPad2,2","iPad2,4":                     return .iPad_2
        case"iPad2,3":                               return .iPad_2_CDMA
        case"iPad2,5":                               return .iPad_Mini_WiFi
        case"iPad2,6":                               return .iPad_Mini
        case"iPad2,7":                               return .iPad_Mini_GSM_CDMA
        case"iPad3,1":                               return .iPad_3_WiFi
        case"iPad3,2":                               return .iPad_3_GSM_CDMA
        case"iPad3,3":                               return .iPad_3
        case"iPad3,4":                               return .iPad_4_WiFi
        case"iPad3,5":                               return .iPad_4
        case"iPad3,6":                               return .iPad_4_GSM_CDMA
        case"iPad4,1":                               return .iPad_Air_WiFi
        case"iPad4,2":                               return .iPad_Air_Cellular
        case"iPad4,4":                               return .iPad_Mini_2_WiFi
        case"iPad4,5":                               return .iPad_Mini_2_Cellular
        case"iPad4,6":                               return .iPad_Mini_2
        case"iPad4,7","iPad4,8","iPad4,9":           return .iPad_Mini_3
        case"iPad5,1":                               return .iPad_Mini_4_WiFi
        case"iPad5,2":                               return .iPad_Mini_4_LTE
        case"iPad5,3","iPad5,4":                     return .iPad_Air_2
        case"iPad6,3","iPad6,4":                     return .iPad_Pro_9_7
        case"iPad6,7","iPad6,8":                     return .iPad_Pro_12_9
        case"iPad6,11":                              return .iPad_5_WiFi
        case"iPad6,12":                              return .iPad_5_Cellular
        case"iPad7,1":                               return .iPad_Pro_12_9_WiFi
        case"iPad7,2":                               return .iPad_Pro_12_9_Cellular
        case"iPad7,3":                               return .iPad_Pro_10_5_WiFi
        case"iPad7,4":                               return .iPad_Pro_10_5_Cellular
            
        case"AppleTV2,1":                            return .Apple_TV_2
        case"AppleTV3,1":                            return .Apple_TV_3
        case"AppleTV3,2":                            return .Apple_TV_3
        case"AppleTV5,3":                            return .Apple_TV_4
            
        case"i386","x86_64":                         return .Simulator
        default:                                     return .none//identifier
        }
    }
}
