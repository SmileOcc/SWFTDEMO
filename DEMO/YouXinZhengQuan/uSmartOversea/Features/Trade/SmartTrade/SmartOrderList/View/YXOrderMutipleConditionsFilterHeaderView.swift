//
//  YXCollectionReusableView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/4.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderMutipleConditionsFilterHeaderView: UICollectionReusableView {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .center
        view.textColor = QMUITheme().textColorLevel1()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
