//
//  SearchHelpCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchHelpCell: SearchBaseCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont14()
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(19)
            make.right.equalTo(-16)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalTo(-16)
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchHelpCellViewModel else {
            return
        }

        titleLabel.attributedText = cellViewModel.attributedTitle
        titleLabel.lineBreakMode = .byTruncatingTail

        contentLabel.attributedText = cellViewModel.attributedContent
        contentLabel.lineBreakMode = .byTruncatingTail

    }

}
