//
//  YXMyAssetsDetailViaMarketResModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailViaMarketResModel: YXResponseModel {

    @objc var moneyType: String?
    @objc var sumNetAsset: NSDecimalNumber?
    @objc var assetDetailList: [YXMyAssetsDetailViaMarketListItem] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["assetDetailList": YXMyAssetsDetailViaMarketListItem.self]
    }

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "assetDetailList": "data.assetDetailList",
            "moneyType": "data.moneyType",
            "sumNetAsset": "data.sumNetAsset"
        ]
    }

    /// 是否存在负资产
    var hasNegativeAsset: Bool {
        for item in assetDetailList {
            if let value = item.sumAsset?.doubleValue, value < 0 {
                return true
            }
        }

        return false
    }

}

class YXMyAssetsDetailViaMarketListItem: YXModel {

    @objc var exchangeType: String?
    @objc var cashAsset: NSDecimalNumber?
    @objc var marketValue: NSDecimalNumber?
    @objc var sumAsset: NSDecimalNumber?
    @objc var exchangeAsset: NSDecimalNumber?
    /// 资产占比
    @objc var percent = 0.0

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}

extension YXMyAssetsDetailViaMarketListItem {

    var color: UIColor {
        switch exchangeType {
        case "US":
            return UIColor.themeColor(withNormalHex: "#3489FF", andDarkColor: "#2A6ECC")
        case "SG":
            return UIColor.themeColor(withNormalHex: "#F2397B", andDarkColor: "#BF2D61")
        case "HK":
            return UIColor.themeColor(withNormalHex: "#944EFF", andDarkColor: "#763ECC")
        default:
            return .clear
        }
    }

    var marketName: String {
        switch exchangeType {
        case "US":
            return YXLanguageUtility.kLang(key: "us_market")
        case "SG":
            return YXLanguageUtility.kLang(key: "sg_market")
        case "HK":
            return YXLanguageUtility.kLang(key: "hk_market")
        default:
            return ""
        }
    }

    var moneyType: String {
        switch exchangeType {
        case "US":
            return "USD"
        case "SG":
            return "SGD"
        case "HK":
            return "HKD"
        default:
            return ""
        }
    }

}
