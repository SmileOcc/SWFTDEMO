//
//  SearchBeeRichMasterCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBeeRichMasterCellViewModel: SearchCellViewModel {

    let model: SearchBeeRichMasterModel
    let attributedName: NSAttributedString?

    init(model: SearchBeeRichMasterModel, searchWord: String) {
        self.model = model

        self.attributedName = model.kolNickName.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        return 56
    }

}
