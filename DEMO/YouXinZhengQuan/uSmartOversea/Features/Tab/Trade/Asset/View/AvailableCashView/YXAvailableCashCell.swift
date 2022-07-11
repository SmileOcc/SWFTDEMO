//
//  YXAvailableCashCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXAvailableCashCell: UITableViewCell {

    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10)
        view.textColor = QMUITheme().textColorLevel3()
        return view
    }()

    lazy var availableCashLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = QMUITheme().textColorLevel1()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#292933")
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        contentView.addSubview(iconImageView)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, availableCashLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        contentView.addSubview(stackView)

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.width.height.equalTo(18)
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }

    func bind(to viewModel: YXAvailableCashCellViewModel) {
        iconImageView.image = UIImage(named: viewModel.icon)
        titleLabel.text = viewModel.title
        availableCashLabel.text = viewModel.availableCash
    }

}
