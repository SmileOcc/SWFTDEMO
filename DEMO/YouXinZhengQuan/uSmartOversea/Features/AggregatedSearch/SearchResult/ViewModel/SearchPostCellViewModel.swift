//
//  SearchPostCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchPostCellViewModel: SearchCellViewModel {

    let model: SearchPostModel
    let attributedTitle: NSMutableAttributedString?
    let attributedContent: NSAttributedString?
    let attributedUsername: NSMutableAttributedString?
    var titleNumberOfLines = 3
    let createTimeStr: String?

    init(model: SearchPostModel, searchWord: String) {
        self.model = model

        var title = model.title
        let content = YXToolUtility.reverseTransformHtmlString(model.content) ?? ""

        if model.title.isEmpty { // 如果标题为空，那么标题显示 content 字段， content 就不用显示了
            title = content
        }

        self.attributedTitle = title.attributedString(
            font: .normalFont16(),
            textColor: QMUITheme().textColorLevel1()
        ).addHighlight(for: searchWord)

        // 添加股票高亮
        let textParser = YXReportTextParser()
        textParser.font = .normalFont16()
        textParser.parseText(self.attributedTitle, selectedRange: nil)

        if !model.title.isEmpty { // 标题不为空才有可能需要显示 content
            self.attributedContent = content.attributedString(
                font: .normalFont14(),
                textColor: QMUITheme().textColorLevel2()
            ).addHighlight(for: searchWord)
        } else {
            self.attributedContent = nil
        }

        if let attributedContent = attributedContent, !attributedContent.string.isEmpty {
            self.titleNumberOfLines = 2
        } else {
            self.titleNumberOfLines = 3
        }
        
        self.attributedUsername = model.creatorNick.attributedString(
            font: .normalFont12(),
            textColor: QMUITheme().textColorLevel2()
        ).addHighlight(for: searchWord)

        self.createTimeStr = YXToolUtility.compareCurrentTime(model.createTime)

        super.init(searchWord: searchWord)
    }

    override func calculateCellHeight() -> CGFloat {
        let maxWidth: CGFloat = YXConstant.screenWidth - 32.0

        var cellHeight: CGFloat = 0

        let top: CGFloat = 16
        cellHeight += top

        if let attributedTitle = attributedTitle {
            let titleHeight = attributedTitle.height(with: maxWidth, maxLines: self.titleNumberOfLines)
            cellHeight += titleHeight
        }

        if let attributedContent = attributedContent, !attributedContent.string.isEmpty {
            cellHeight += 8 // 间距

            let contentHeight = attributedContent.height(with: maxWidth, maxLines: 3) // content 最多显示 3行
            cellHeight += contentHeight
        }

        cellHeight += 8
        cellHeight += 20 // 用户信息行

        let bottom: CGFloat = 16
        cellHeight += bottom

        return cellHeight
    }

}
