//
//  YXMyAssetsDetailViaCategoryResModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailViaCategoryResModel: YXResponseModel {

    @objc var moneyType: String?
    @objc var sumNetAsset: NSDecimalNumber?
    @objc var assetDetailList: [YXMyAssetsDetailViaCategroyListItem] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["assetDetailList": YXMyAssetsDetailViaCategroyListItem.self]
    }

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "assetDetailList": "data.assetDetailList",
            "moneyType":"data.moneyType",
            "sumNetAsset":"data.sumNetAsset"
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

@objc enum YXMyAssetsDetailKind: Int {
    case cash = 1
    case stock = 2
    case option = 3
}

extension YXMyAssetsDetailKind {

    var title: String {
        switch self {
        case .cash:
            return YXLanguageUtility.kLang(key: "account_cash_balance")
        case .stock:
            return YXLanguageUtility.kLang(key: "stocks")
        case .option:
            return YXLanguageUtility.kLang(key: "options")
        }
    }

    var color: UIColor {
        switch self {
        case .cash:
            return UIColor.themeColor(withNormalHex: "#414FFF", andDarkColor: "#6671FF")
        case .stock:
            return UIColor.themeColor(withNormalHex: "#00C767", andDarkColor: "#00994F")
        case .option:
            return UIColor.themeColor(withNormalHex: "#FF6933", andDarkColor: "#E05C2D")

        }
    }

}

class YXMyAssetsDetailViaCategroyListItem: YXModel {

    @objc var assetKind: YXMyAssetsDetailKind = .cash
    @objc var hkdAsset: NSDecimalNumber?
    @objc var sgdAsset: NSDecimalNumber?
    @objc var usdAsset: NSDecimalNumber?
    @objc var sumAsset: NSDecimalNumber?
    @objc var sumAssetMoneyType: String?
    @objc var percent: Double = 0

    override class func modelCustomPropertyMapper() -> [String : Any] {
        [:]
    }

}
