//
//  SearchStrategyCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchStrategyCellViewModel: SearchCellViewModel {

    let model: SearchStrategyModel
    let attributedName: NSAttributedString?
    let attributedBrief: NSAttributedString?

    init(model: SearchStrategyModel, searchWord: String) {
        self.model = model

        self.attributedName = model.name.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        self.attributedBrief = model.brief.attributedString(
            font: .normalFont12(),
            textColor: QMUITheme().textColorLevel3()
        ).addHighlight(for: searchWord)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        return 70
    }

}
