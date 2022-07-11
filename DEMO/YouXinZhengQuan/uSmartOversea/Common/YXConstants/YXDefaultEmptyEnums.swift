//
//  YXDefaultEmptyEnums.swift
//  uSmartOversea
//
//  Created by usmart on 2021/5/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

@objc enum YXDefaultEmptyEnums: Int {
    case failed
    case noNetwork
    case noData
    case noHistory
    case noSearch
    case noPositon
    case noOrder
    case noSmartOrder
    case noCommnet
    case noPermission
    
    func image() -> UIImage? {
        switch self {
        case .failed:
            return UIImage.init(named: "network_nodata")
        case .noNetwork:
            return UIImage.init(named: "network_nodata")
        case .noCommnet,
             .noData:
            return UIImage.init(named: "empty_noData")
        case .noHistory:
            return UIImage.init(named: "icon_search_empty")
        case .noSearch:
            return UIImage.init(named: "icon_search_noData")
        case .noPositon:
            return UIImage.init(named: "empty_no_position")
        case .noOrder,
             .noSmartOrder:
            return UIImage.init(named: "empty_noOrder")
        case .noPermission:
            return UIImage.init(named: "empty_no_permission")
        }
    }
    
    func tip() -> String {
        switch self {
        case .failed:
            return YXLanguageUtility.kLang(key: "common_loadFailed")
        case .noNetwork:
            return YXLanguageUtility.kLang(key: "common_noNetwork")
        case .noData:
            return YXLanguageUtility.kLang(key: "common_string_of_emptyPicture")
        case .noHistory:
            return YXLanguageUtility.kLang(key: "search_history_empty")
        case .noSearch:
            return YXLanguageUtility.kLang(key: "search_result_empty")
        case .noPositon:
            return YXLanguageUtility.kLang(key: "hold_no_data")
        case .noOrder:
            return YXLanguageUtility.kLang(key: "hold_no_order")
        case .noSmartOrder:
            return YXLanguageUtility.kLang(key: "trade_no_smart_order_record")
        case .noCommnet:
            return YXLanguageUtility.kLang(key: "nbb_saysomething")
        case .noPermission:
            return YXLanguageUtility.kLang(key: "option_no_permission")
        }
    }
}
