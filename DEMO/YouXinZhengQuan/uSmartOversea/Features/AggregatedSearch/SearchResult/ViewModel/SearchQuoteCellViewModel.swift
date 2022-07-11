//
//  SearchQuoteCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchQuoteCellViewModel: SearchCellViewModel {

    let model: SearchSecuModel
    let attributedName: NSAttributedString?
    let attributedSymbol: NSAttributedString?

    init(model: SearchSecuModel, searchWord: String) {
        self.model = model

        self.attributedName = model.name.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        self.attributedSymbol = model.symbol.attributedString(
            font: .normalFont12(),
            textColor: QMUITheme().textColorLevel3()
        ).addHighlight(for: searchWord)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        return 60
    }

}
