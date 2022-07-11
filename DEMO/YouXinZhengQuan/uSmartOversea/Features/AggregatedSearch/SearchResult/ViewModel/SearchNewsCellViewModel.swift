//
//  SearchNewsCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchNewsCellViewModel: SearchCellViewModel {

    let model: SearchNewsModel
    let attributedTitle: NSAttributedString
    let attributedName: NSAttributedString
    let timeAgo: String?

    init(model: SearchNewsModel, searchWord: String) {
        self.model = model

        self.attributedTitle = model.title.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        self.attributedName = model.source.attributedString(
            font: .normalFont12(),
            textColor: QMUITheme().textColorLevel2()
        )

        timeAgo = YXToolUtility.compareCurrentTime(model.publishDate)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        let maxWidth: CGFloat = YXConstant.screenWidth - 32.0

        var cellHeight: CGFloat = 0

        let top: CGFloat = 16
        cellHeight += top

        let titleHeight = attributedTitle.height(with: maxWidth, maxLines: 2)
        cellHeight += titleHeight

        cellHeight += 8 // 间距

        let nameAndTimeAgoHeight = attributedName.height(with: maxWidth)
        cellHeight += nameAndTimeAgoHeight

        let bottom: CGFloat = 16
        cellHeight += bottom

        return cellHeight
    }

}
