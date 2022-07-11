//
//  YXModuleMoreHeaderView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/3/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXModuleMoreHeaderView: UICollectionReusableView {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = QMUITheme().textColorLevel3()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(21)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
