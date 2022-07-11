//
//  YXOrderMutipleConditionsFilterCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/4.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderMutipleConditionsFilterCell: UICollectionViewCell {

    var isChoosed: Bool = false {
        didSet {
            let color = isChoosed ? QMUITheme().themeTintColor() : QMUITheme().textColorLevel1()
            titleLabel.textColor = color

            let borderColor = isChoosed ? QMUITheme().themeTintColor() : QMUITheme().alertButtonLayerColor()
            contentView.layer.borderColor = borderColor.cgColor
        }
    }

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textAlignment = .center
        view.textColor = QMUITheme().textColorLevel1()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.borderWidth = QMUIHelper.pixelOne
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
