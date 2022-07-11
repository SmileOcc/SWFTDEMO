//
//  SearchBeeRichCourseCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBeeRichCourseCellViewModel: SearchCellViewModel {

    let model: SearchBeeRichCourseModel
    let attributedTitle: NSAttributedString?
    var priceStr: String?

    init(model: SearchBeeRichCourseModel, searchWord: String) {
        self.model = model

        self.attributedTitle = model.courseName.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        if model.paidType == .free {
            priceStr = YXLanguageUtility.kLang(key: "nbb_free_limit")
        }else {
            if model.coursePaidFlag {
                priceStr = YXLanguageUtility.kLang(key: "nbb_bought")
            }else {
                priceStr = "\(model.priceSymbol)\(model.price ?? "--")"
            }
        }

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        return 124
    }

}
