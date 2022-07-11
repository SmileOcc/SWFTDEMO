//
//  YXMoneyTypeSelectionCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMoneyTypeSelectionCell: UITableViewCell {

    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    lazy var currencyLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = QMUITheme().textColorLevel1()
        return view
    }()

    lazy var exchangeRateLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10)
        view.textColor = QMUITheme().textColorLevel3()
        view.numberOfLines = 2
        view.minimumScaleFactor = 0.8
        return view
    }()

    lazy var checkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "filter_market_type_check")
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        contentView.addSubview(iconImageView)

        let stackView = UIStackView(arrangedSubviews: [currencyLabel, exchangeRateLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        contentView.addSubview(stackView)

        contentView.addSubview(checkImageView)

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

        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-24)
        }
    }

    func bind(to viewModel: YXMoneyTypeSelectionCellViewModel) {
        iconImageView.image = UIImage(named: viewModel.icon)
        currencyLabel.text = viewModel.moneyType.name()
        exchangeRateLabel.text = viewModel.exchangeRateString

        currencyLabel.textColor = viewModel.selected ? QMUITheme().themeTextColor() : QMUITheme().textColorLevel1()
        checkImageView.isHidden = !viewModel.selected
        exchangeRateLabel.isHidden = viewModel.selected

        contentView.backgroundColor =
            viewModel.selected
            ? UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#2E2F47")
            : UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#292933")
    }

}
