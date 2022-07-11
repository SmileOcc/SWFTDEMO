//
//  SearchBeeRichMasterCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBeeRichMasterCell: SearchBaseCell {

    lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()


    override func initialUI() {
        super.initialUI()

        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)

        userImageView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(userImageView.snp.right).offset(16)
            make.centerY.equalTo(userImageView)
            make.right.equalTo(-16)
        }

    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchBeeRichMasterCellViewModel else {
            return
        }

        userImageView.sd_setImage(
            with: URL(string: cellViewModel.model.kolAvatar),
            placeholderImage: UIImage(named: "user_default_photo")
        )

        usernameLabel.attributedText = cellViewModel.attributedName
        usernameLabel.lineBreakMode = .byTruncatingTail
    }

}
