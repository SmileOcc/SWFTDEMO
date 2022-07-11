//
//  YXMarketFilterCell.swift
//  uSmartOversea
//
//  Created by Evan on 2021/12/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderMarketFilterCell: QMUITableViewCell {

    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textColor = QMUITheme().textColorLevel1()
        return view
    }()

    lazy var checkImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = UIImage(named: "filter_market_type_check")
        return view
    }()


    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
//        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkImageView)

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }

    override var isSelected: Bool {
        didSet {
            checkImageView.isHidden = !isSelected
            contentView.backgroundColor = isSelected ? QMUITheme().blockColor() : QMUITheme().foregroundColor()
        }
    }
}
