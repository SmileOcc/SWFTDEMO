//
//  SearchStrategyCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchStrategyCell: SearchBaseCell {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var briefLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel3()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(nameLabel)
        contentView.addSubview(briefLabel)

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }

        briefLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchStrategyCellViewModel else {
            return
        }

        nameLabel.attributedText = cellViewModel.attributedName
        nameLabel.lineBreakMode = .byTruncatingTail

        briefLabel.attributedText = cellViewModel.attributedBrief
        briefLabel.lineBreakMode = .byTruncatingTail
    }
    
}
