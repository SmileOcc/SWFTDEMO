//
//  YXMyAssetsDetailCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailCell: UITableViewCell {

    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = QMUIHelper.pixelOne
        view.layer.borderColor = UIColor.themeColor(withNormalHex: "#DDDDDD", andDarkColor: "#212129").cgColor
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#101014")
        return view
    }()

    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .mediumFont16()
        return view
    }()

    lazy var totalAssetLabel: YXMyAssetsDetailSecretLabel = {
        let view = YXMyAssetsDetailSecretLabel()
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .normalFont14()
        view.textAlignment = .right
        return view
    }()

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fillEqually
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#101014")

        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initSubviews() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        }

        containerView.addSubview(colorView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(totalAssetLabel)

        colorView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalToSuperview()
            make.height.equalTo(54)
        }

        totalAssetLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.top.equalToSuperview()
            make.height.equalTo(54)
        }

        let lineView = UIView()
        lineView.backgroundColor = UIColor.themeColor(withNormalHex: "#DDDDDD", andDarkColor: "#212129")
        containerView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(54)
            make.height.equalTo(QMUIHelper.pixelOne)
        }

        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(70)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }

}

class YXMyAssetsDetailItemView: UIView {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = QMUITheme().textColorLevel3()
        view.font = .normalFont14()
        return view
    }()

    lazy var valueLabel: YXMyAssetsDetailSecretLabel = {
        let view = YXMyAssetsDetailSecretLabel()
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .normalFont14()
        view.textAlignment = .right
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
