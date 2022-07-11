//
//  SearchBeeRichCourseCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBeeRichCourseCell: SearchBaseCell {

    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont16()
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont14()
        label.textColor = QMUITheme().themeTextColor()
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var learnNowBtn: YXCourseLearnButton = {
        let btn = YXCourseLearnButton()
        return btn
    }()

    override func initialUI() {
        super.initialUI()

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(learnNowBtn)

        coverImageView.snp.makeConstraints { make in
            make.top.left.equalTo(16)
            make.width.equalTo(128)
            make.height.equalTo(92)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.top.equalTo(coverImageView)
            make.right.equalTo(-16)
        }

        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.bottom.equalTo(coverImageView)
        }

        learnNowBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(coverImageView).offset(-4)
            make.size.equalTo(30)
        }
    }

    override func refreshUI() {
        super.refreshUI()

        guard let cellViewModel = model as? SearchBeeRichCourseCellViewModel else {
            return
        }

        coverImageView.sd_setImage(
            with: URL(string: cellViewModel.model.courseCover),
            placeholderImage: UIImage(named: "banner_placeholder1")
        )

        titleLabel.attributedText = cellViewModel.attributedTitle
        titleLabel.lineBreakMode = .byTruncatingTail

        priceLabel.text = cellViewModel.priceStr

        learnNowBtn.setProgress(value: CGFloat(cellViewModel.model.studyProgress))
        learnNowBtn.isSelected = true
    }

}
