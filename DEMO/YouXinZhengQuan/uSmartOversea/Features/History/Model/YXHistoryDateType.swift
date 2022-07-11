//
//  YXHistoryDateType.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

public enum YXHistoryDateType:String, CaseIterable {
    case All = "全部日期"
    case LastMonth = "近1个月"
    case LastThreeMonth = "近3个月"
    case LastYear = "近1年"
    case WithinThisYear = "今年内"
    case Custom = "自定义"
    case Today = "今天"
    case Week = "近一周"
    
    // 旧代码旧功能筛选使用
    var index:Int {
        switch self {
        case .All:
            return 0
        case .LastMonth:
            return 1
        case .LastThreeMonth:
            return 2
        case .LastYear:
            return 3
        case .WithinThisYear:
            return 4
        case .Custom:
            return 5
        default:
            return -1
        }
    }
    
    // 订单筛选使用
    var orderIndex: Int {
        switch self {
        case .Today:
            return 0
        case .Week:
            return 1
        case .LastMonth:
            return 2
        case .LastThreeMonth:
            return 3
        case .LastYear:
            return 4
        case .WithinThisYear:
            return 5
        case .Custom:
            return 6
        default:
            return -1
        }
    }
    // 订单筛选入参定义
    var orderFilterRequestValue: String {
        switch self {
        case .All:
            return "7"
        case .Today:
            return "0"
        case .Week:
            return "1"
        case .LastMonth:
            return "2"
        case .LastThreeMonth:
            return "3"
        case .LastYear:
            return "4"
        case .WithinThisYear:
            return "5"
        case .Custom:
            return "6"
        }
    }

    // 智能订单筛选入参定义
    var smartOrderFilterRequestValue: String {
        switch self {
        case .All:
            return ""
        case .Today:
            return "1"
        case .Week:
            return "2"
        case .LastMonth:
            return "3"
        case .LastThreeMonth:
            return "4"
        case .LastYear:
            return "5"
        case .WithinThisYear:
            return "6"
        case .Custom:
            return ""
        }
    }
}

extension YXHistoryDateType {
    var title: String {
        switch self {
        case .All:
            return ""
        case .Today:
            return YXLanguageUtility.kLang(key: "history_date_type_today")
        case .Week:
            return YXLanguageUtility.kLang(key: "history_date_type_last_week")
        case .LastMonth:
            return YXLanguageUtility.kLang(key: "history_date_type_last_month")
        case .LastThreeMonth:
            return YXLanguageUtility.kLang(key: "history_date_type_last_three_month")
        case .LastYear:
            return YXLanguageUtility.kLang(key: "history_date_type_last_year")
        case .WithinThisYear:
            return YXLanguageUtility.kLang(key: "history_date_type_within_this_year")
        case .Custom:
            return YXLanguageUtility.kLang(key: "history_date_type_custom")
        }
    }
}

public enum YXHistoryFilterStatus: Int {
    case all
    case successful
    case processing
    case failed
}

extension YXHistoryFilterStatus: CaseIterable {
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "history_filter_all_status")
        case .successful:
            return YXLanguageUtility.kLang(key: "history_filter_successful")
        case .processing:
            return YXLanguageUtility.kLang(key: "history_filter_processing")
        case .failed:
            return YXLanguageUtility.kLang(key: "history_filter_failed")
        }
    }

    var requestParam: String {
        switch self {
        case .all:
            return ""
        case .successful:
            return "Processed"
        case .processing:
            return "Pending"
        case .failed:
            return "Rejected"
        }
    }
}
