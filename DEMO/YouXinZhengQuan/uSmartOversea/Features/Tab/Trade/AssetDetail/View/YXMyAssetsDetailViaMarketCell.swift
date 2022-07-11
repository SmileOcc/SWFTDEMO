//
//  YXMyAssetsDetailViaMarketCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailViaMarketCell: YXMyAssetsDetailCell {

    lazy var cashBalanceView: YXMyAssetsDetailItemView = {
        let view = YXMyAssetsDetailItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "account_cash_balance")
        return view
    }()

    lazy var positonValueView: YXMyAssetsDetailItemView = {
        let view = YXMyAssetsDetailItemView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "account_position_value")
        return view
    }()

    override func initSubviews() {
        super.initSubviews()

        stackView.addArrangedSubview(cashBalanceView)
        stackView.addArrangedSubview(positonValueView)
    }

    func bind(to model: YXMyAssetsDetailViaMarketListItem) {
        colorView.backgroundColor = model.color

        titleLabel.text = "\(model.marketName) (\(model.moneyType))"

        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "###,##0.00"
        numberFormatter.locale = Locale(identifier: "zh")

        totalAssetLabel.value =  numberFormatter.string(from: model.exchangeAsset ?? .zero)

        cashBalanceView.valueLabel.value = numberFormatter.string(from: model.cashAsset ?? .zero)
        positonValueView.valueLabel.value = numberFormatter.string(from: model.marketValue ?? .zero)
    }
    
}
