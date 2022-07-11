//
//  SearchHelpCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchHelpCellViewModel: SearchCellViewModel {

    let model: SearchHelpModel
    let attributedTitle: NSAttributedString
    let attributedContent: NSAttributedString

    init(model: SearchHelpModel, searchWord: String) {
        self.model = model

        self.attributedTitle = model.title.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        self.attributedContent = model.content.attributedString(
            font: .normalFont14(),
            textColor: QMUITheme().textColorLevel2()
        ).addHighlight(for: searchWord)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        let maxWidth: CGFloat = YXConstant.screenWidth - 32.0

        var cellHeight: CGFloat = 0

        let top: CGFloat = 19
        cellHeight += top

        let titleHeight = attributedTitle.height(with: maxWidth, maxLines: 1) // title 最多显示 1 行
        cellHeight += titleHeight

        if !attributedContent.string.isEmpty {
            cellHeight += 8 // 间距

            let contentHeight: CGFloat = attributedContent.height(with: maxWidth, maxLines: 2)
            cellHeight += contentHeight
        }

        let bottom: CGFloat = 16
        cellHeight += bottom

        return cellHeight
    }

}
