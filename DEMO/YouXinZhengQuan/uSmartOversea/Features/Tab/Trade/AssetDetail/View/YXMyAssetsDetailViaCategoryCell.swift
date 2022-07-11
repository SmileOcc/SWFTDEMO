//
//  YXMyAssetsDetailViaCategoryCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailViaCategoryCell: YXMyAssetsDetailCell {

    lazy var usView: YXMyAssetsDetailItemView = {
        let view = YXMyAssetsDetailItemView()
        return view
    }()

    lazy var sgView: YXMyAssetsDetailItemView = {
        let view = YXMyAssetsDetailItemView()
        return view
    }()

    lazy var hkView: YXMyAssetsDetailItemView = {
        let view = YXMyAssetsDetailItemView()
        return view
    }()

    override func initSubviews() {
        super.initSubviews()
        stackView.addArrangedSubview(usView)
        stackView.addArrangedSubview(sgView)
        stackView.addArrangedSubview(hkView)
    }

    func bind(to model: YXMyAssetsDetailViaCategroyListItem) {
        colorView.backgroundColor = model.assetKind.color

        titleLabel.text = "\(model.assetKind.title) (\(model.sumAssetMoneyType ?? ""))"

        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "###,##0.00"
        numberFormatter.locale = Locale(identifier: "zh")

        totalAssetLabel.value =  numberFormatter.string(from: model.sumAsset ?? .zero)

        usView.valueLabel.value = numberFormatter.string(from: model.usdAsset ?? .zero)
        sgView.valueLabel.value = numberFormatter.string(from: model.sgdAsset ?? .zero)
        hkView.valueLabel.value = numberFormatter.string(from: model.hkdAsset ?? .zero)

        switch model.assetKind {
        case .cash:
            usView.titleLabel.text = "USD"
            sgView.titleLabel.text = "SGD"
            hkView.titleLabel.text = "HKD"
        case .stock:
            usView.titleLabel.text = "\(YXLanguageUtility.kLang(key: "account_us_area")) (USD)"
            sgView.titleLabel.text = "\(YXLanguageUtility.kLang(key: "account_sg_area")) (SGD)"
            hkView.titleLabel.text = "\(YXLanguageUtility.kLang(key: "account_hk_area")) (HKD)"
        case .option:
            usView.titleLabel.text = "\(YXLanguageUtility.kLang(key: "account_option_area")) (USD)"
            sgView.titleLabel.text = ""
            hkView.titleLabel.text = ""
        }

        sgView.isHidden = model.assetKind == .option
        hkView.isHidden = model.assetKind == .option
    }

}
