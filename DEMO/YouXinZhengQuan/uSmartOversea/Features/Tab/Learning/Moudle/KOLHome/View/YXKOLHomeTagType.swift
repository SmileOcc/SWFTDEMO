//
//  YXKOLHomeTagEum.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit

// beerich的标签逻辑
//enum YXKOLHomeTagType: String {
//
//    case licensed = "1"
//    case certified = "2"
//    case invest = "6"
//    case analyst = "3"
//    case master = "4"
//    case kol = "5"
//
//    private func colors() -> [UIColor] {
//        switch self {
//        case .licensed:
//            return [UIColor(hexString: "1493FF")!,UIColor(hexString: "3C71FF")!]
//        case .invest:
//            return [UIColor(hexString: "B548FF")!,UIColor(hexString: "9013FE")!]
//        case .analyst:
//            return [UIColor(hexString: "1493FF")!,UIColor(hexString: "30CBC1")!]
//        case .master:
//            return [UIColor(hexString: "6B5DFE")!,UIColor(hexString: "0050FF")!]
//        case .kol:
//            return [UIColor(hexString: "FE984F")!,UIColor(hexString: "FE7835")!]
//        case .certified:
//            return [UIColor(hexString: "FAAF2D")!,UIColor(hexString: "F8782E")!]
//        }
//    }
//
//    private func icon() -> UIImage? {
//        switch self {
//        case .licensed:
//            return UIImage(named: "kol_tag_licensed_icon")
//        case .invest:
//            return UIImage(named: "kol_tag_invest_icon")
//        case .analyst:
//            return UIImage(named: "kol_tag_analyst_icon")
//        case .master:
//            return UIImage(named: "kol_tag_master_icon")
//        case .kol:
//            return UIImage(named: "kol_tag_kol_icon")
//        case .certified:
//            return UIImage(named: "kol_tag_certified_icon")
//        }
//    }
//
//    private func title() -> String {
//        switch self {
//        case .licensed:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_licensed")
//        case .invest:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_invest")
//        case .analyst:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_analyst")
//        case .master:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_master")
//        case .kol:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_kol")
//        case .certified:
//            return YXLanguageUtility.kLang(key: "nbb_kol_tag_certified")
//        }
//    }
//
//    func tagImage() -> QMUIButton {
//        let btn = QMUIFillButton()
//        btn.backgroundColor = .clear
//        btn.setBackgroundImage(UIImage(gradientColors: self.colors()), for: .normal)
//        btn.setImage(self.icon(), for: .normal)
//        btn.isUserInteractionEnabled = false
//        btn.backgroundColor = .clear
//        btn.setTitle(title(), for: .normal)
//        btn.layer.cornerRadius = 8
//        btn.layer.masksToBounds = true
//        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
//        btn.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
//        btn.titleLabel?.font = .systemFont(ofSize: 10, weight: .semibold)
//        return btn
//    }
//
//}


//sg的标签逻辑
enum YXKOLHomeTagType: String {
    
    case licensed = "1"
    case certified = "2"
    case invest = "6"
    case analyst = "3"
    case master = "4"
    case kol = "5"
    
    private func colors() -> [UIColor] {
        switch self {
        case .licensed:
            return [UIColor(hexString: "F9A800")!,UIColor(hexString: "F9A800")!]
        case .invest:
            return [UIColor(hexString: "9013FE")!,UIColor(hexString: "9013FE")!]
        case .analyst:
            return [UIColor(hexString: "00C767")!,UIColor(hexString: "00C767")!]
        case .master:
            return [UIColor(hexString: "414FFF")!,UIColor(hexString: "414FFF")!]
        case .kol:
            return [UIColor(hexString: "FE7835")!,UIColor(hexString: "FE7835")!]
        case .certified:
            return [UIColor(hexString: "FF6933")!,UIColor(hexString: "FF6933")!]
        }
    }
    
    private func icon() -> UIImage? {
        switch self {
        case .licensed:
            return UIImage(named: "kol_tag_licensed_icon")
        case .invest:
            return UIImage(named: "kol_tag_invest_icon")
        case .analyst:
            return UIImage(named: "kol_tag_analyst_icon")
        case .master:
            return UIImage(named: "kol_tag_master_icon")
        case .kol:
            return UIImage(named: "kol_tag_kol_icon")
        case .certified:
            return UIImage(named: "kol_tag_certified_icon")
        }
    }
    
    func headIcon() -> UIImage? {
        switch self {
        case .licensed:
            return UIImage(named: "kol_header_tag_licensed")
        case .invest:
            return UIImage(named: "kol_header_tag_invest")
        case .analyst:
            return UIImage(named: "kol_header_tag_analyst")
        case .master:
            return UIImage(named: "kol_header_tag_master")
        case .kol:
            return UIImage(named: "kol_header_tag_kol")
        case .certified:
            return UIImage(named: "kol_header_tag_certified")
        }
    }
    
    private func title() -> String {
        switch self {
        case .licensed:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_licensed")
        case .invest:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_invest")
        case .analyst:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_analyst")
        case .master:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_master")
        case .kol:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_kol")
        case .certified:
            return YXLanguageUtility.kLang(key: "nbb_kol_tag_certified")
        }
    }
    
    func tagImage() -> QMUIButton {
        let btn = QMUIButton()
        btn.backgroundColor = .clear
        btn.setBackgroundImage(UIImage(gradientColors: self.colors()), for: .normal)
        btn.setImage(self.icon(), for: .normal)
        btn.isUserInteractionEnabled = false
        btn.backgroundColor = .clear
        btn.setTitle(title(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 8)
        btn.titleLabel?.font = .systemFont(ofSize: 10, weight: .semibold)
        return btn
    }
    
}
