//
//  SearchPostCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchPostCell: SearchBaseCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont14()
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var userButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()

    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()

    lazy var seperator: UIView = {
        let view = UIView.line()
        return view
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(userButton)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(seperator)

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(16)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.right.equalTo(-16)
        }

        userButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.width.height.equalTo(20)
        }

        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userButton.snp.right).offset(8)
            make.right.equalTo(timeLabel.snp.left).offset(-12)
            make.centerY.equalTo(userButton)
        }

        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(userButton)
        }

        seperator.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(QMUIHelper.pixelOne)
            make.bottom.equalToSuperview()
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchPostCellViewModel else {
            return
        }

        titleLabel.numberOfLines = cellViewModel.titleNumberOfLines
        titleLabel.attributedText = cellViewModel.attributedTitle
        titleLabel.lineBreakMode = .byTruncatingTail

        contentLabel.attributedText = cellViewModel.attributedContent
        contentLabel.lineBreakMode = .byTruncatingTail

        userButton.snp.remakeConstraints { make in
            make.left.equalTo(12)
            if let attributedText = contentLabel.attributedText, !attributedText.string.isEmpty {
                make.top.equalTo(contentLabel.snp.bottom).offset(10)
            } else {
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
            make.width.height.equalTo(20)
        }

        userButton.sd_setBackgroundImage(
            with: URL(string: cellViewModel.model.creatorAvatar),
            for: .normal,
            placeholderImage: UIImage(named: "user_default_photo")
        )

        usernameLabel.attributedText = cellViewModel.attributedUsername
        usernameLabel.lineBreakMode = .byTruncatingTail

        timeLabel.text = cellViewModel.createTimeStr
    }

}
