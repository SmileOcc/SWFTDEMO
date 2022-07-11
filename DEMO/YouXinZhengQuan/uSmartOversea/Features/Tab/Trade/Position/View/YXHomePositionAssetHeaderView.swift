//
//  YXHomePositionAssetHeaderView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXAccountArea: Int {
    case hk
    case us
    case sg
    case usoptions
    case usFraction

    var iconName: String {
        switch self {
        case .hk:
            return "area_hk"
        case .us,
             .usoptions,
             .usFraction:
            return "area_us"
        case .sg:
            return "area_sg"
        }
    }

    var areaName: String {
        switch self {
        case .hk:
            return YXLanguageUtility.kLang(key: "account_hk_area")
        case .us:
            return YXLanguageUtility.kLang(key: "account_us_area")
        case .sg:
            return YXLanguageUtility.kLang(key: "account_sg_area")
        case .usoptions:
            return YXLanguageUtility.kLang(key: "account_option_area")
        case .usFraction:
            return YXLanguageUtility.kLang(key: "account_fraction_area")
        }
    }
}

class YXHomePositionAssetHeaderView: UITableViewHeaderFooterView {

    @objc var model: YXAccountAssetData? {
        didSet {
            if let m = model, m.fundAccountStatus == .opened {
                titleLabel.text = "\(areaType?.areaName ?? "") (\(m.holdInfos.count))"
            } else {
                titleLabel.text = areaType?.areaName
            }
        }
    }

    @objc var expandButtonAction: ((_ isExpand: Bool) -> Void)?

    lazy var areaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "")
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    @objc lazy var expandButton: QMUIButton = {
        let button = QMUIButton()
        button.contentHorizontalAlignment = .right
        button.qmui_outsideEdge = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        button.setImage(UIImage(named: "grey_arrow_down"), for: .normal)
        button.setImage(UIImage(named: "grey_arrow_up"), for: .selected)
        button.isSelected = true
        button.tintColor = QMUITheme().textColorLevel3()
        button.adjustsImageTintColorAutomatically = true

        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] _ in
            guard let button = button else { return }
            button.isSelected = !button.isSelected
            self?.expandButtonAction?(button.isSelected)
        })
        return button
    }()

    @objc lazy var topLineView: UIView = {
        let line = UIView.line()
        return line
    }()

    @objc lazy var bottomLineView: UIView = {
        let line = UIView.line()
        return line
    }()

    var areaType: YXAccountArea?

    @objc init(area: YXAccountArea) {
        self.areaType = area
        super.init(reuseIdentifier: nil)

        contentView.backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(areaImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(expandButton)

        areaImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(15)
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(areaImageView.snp.right).offset(8)
            make.centerY.equalTo(areaImageView.snp.centerY)
        }

        expandButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.height.equalTo(48)
        }

        areaImageView.image = UIImage(named: area.iconName)

        contentView.addSubview(topLineView)
        topLineView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(QMUIHelper.pixelOne)
        }

        contentView.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(QMUIHelper.pixelOne)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
