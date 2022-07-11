//
//  SearchBeeRichCourseModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum SearchBeeRichCoursePaidType: Int {
    case free
    case charge
}

extension SearchBeeRichCoursePaidType {
    var title: String {
        switch self {
        case .free:
            return YXLanguageUtility.kLang(key: "nbb_title_free")
        default:
            return ""
        }
    }
}

@objcMembers class SearchBeeRichCourseModel: YXModel {
    var courseId = ""
    var paidType: SearchBeeRichCoursePaidType = .free
    var courseName = ""
    var courseCover = ""
    var price: String?
    var priceSymbol = ""
    var coursePaidFlag = false
    var studyProgress: Float = 0
}
