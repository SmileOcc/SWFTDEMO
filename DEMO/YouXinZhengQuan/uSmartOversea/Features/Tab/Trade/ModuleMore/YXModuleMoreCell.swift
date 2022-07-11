//
//  YXModuleMoreCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/3/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXModuleMoreCell: UICollectionViewCell {

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 2
        view.font = UIFont.systemFont(ofSize: 12)
        view.adjustsFontSizeToFitWidth = true
        view.textColor = QMUITheme().textColorLevel2()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = QMUITheme().blockColor()

        initSubivews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubivews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(32.0 / 76.0)
            make.height.equalTo(imageView.snp.width)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-2)
        }
    }

    func bind(to model: ModuleCategory) {
        imageView.image = UIImage(named: model.icon)
        titleLabel.text = model.title
    }

}
