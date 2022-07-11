//
//  SearchNewsCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchNewsCell: SearchBaseCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel2()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel3()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(titleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.right.equalTo(-16)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(12)
            make.centerY.equalTo(nameLabel)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let mode = model as? SearchNewsCellViewModel else {
            return
        }

        titleLabel.attributedText = mode.attributedTitle
        titleLabel.lineBreakMode = .byTruncatingTail

        nameLabel.attributedText = mode.attributedName
        nameLabel.lineBreakMode = .byTruncatingTail

        timeLabel.text = mode.timeAgo
    }

}
