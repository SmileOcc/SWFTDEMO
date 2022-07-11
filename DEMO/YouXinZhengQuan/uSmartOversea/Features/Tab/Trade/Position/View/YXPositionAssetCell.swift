//
//  YXPositionAssetCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXPositionAssetCell: UITableViewCell {

    @objc var detailButtonAction: (() -> Void)?

    @objc var model: YXAccountAssetData? {
        didSet {
            if let m = model {
                var marketValue: String?
                var dailyHoldingBalance: String?
                var totalHoldingBalance: String?

                marketValue = m.marketValue?.stringValue
                dailyHoldingBalance = m.todayProfit?.stringValue
                totalHoldingBalance = m.totalHoldingBalance?.stringValue

                if let market = model?.exchangeType?.lowercased() {
                    let exchangeType = YXExchangeType.exchangeType(market)
                    positionValueTitleLabel.text = "\(YXLanguageUtility.kLang(key: "account_position_value")) (\(exchangeType.text))"
                } else {
                    positionValueTitleLabel.text = YXLanguageUtility.kLang(key: "account_position_value")
                }

                // 持仓市值
                if !positionValueLabel.shouldShowStar {
                    positionValueLabel.text = moneyFormatValue(value:marketValue)
                }

                // 今日盈亏
                if dailyPLLabel.shouldShowStar {
                    dailyPLLabel.textColor = QMUITheme().textColorLevel1()
                } else {
                    let value = Double(dailyHoldingBalance ?? "") ?? 0
                    if (value > 0) {
                        dailyPLLabel.textColor = QMUITheme().stockRedColor()
                        dailyPLLabel.value = "+" + moneyFormatValue(value: dailyHoldingBalance)
                    } else if value < 0 {
                        dailyPLLabel.textColor = QMUITheme().stockGreenColor()
                        dailyPLLabel.value = moneyFormatValue(value: dailyHoldingBalance)
                    } else {
                        dailyPLLabel.textColor = QMUITheme().stockGrayColor()
                        dailyPLLabel.value = moneyFormatValue(value: dailyHoldingBalance)
                    }
                }

                // 持仓盈亏
                if totalPLLabel.shouldShowStar {
                    totalPLLabel.textColor = QMUITheme().textColorLevel1()
                } else {
                    let value = Double(totalHoldingBalance ?? "") ?? 0
                    if (value > 0) {
                        totalPLLabel.textColor = QMUITheme().stockRedColor()
                        totalPLLabel.value = "+" + moneyFormatValue(value: totalHoldingBalance)
                    } else if value < 0 {
                        totalPLLabel.textColor = QMUITheme().stockGreenColor()
                        totalPLLabel.value = moneyFormatValue(value: totalHoldingBalance)
                    } else {
                        totalPLLabel.textColor = QMUITheme().stockGrayColor()
                        totalPLLabel.value = moneyFormatValue(value: totalHoldingBalance)
                    }
                }
            }
        }
    }

    // 金额格式化
    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

    // 持仓市值
    lazy var positionValueTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont10()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "account_position_value")
        return label
    }()

    lazy var positionValueLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.font = .mediumFont14()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    lazy var shareButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        button.setImage(UIImage(named: "hold_share"), for: .normal)
        button.tintColor = QMUITheme().textColorLevel3()
        button.adjustsImageTintColorAutomatically = true

        button.rx.tap.subscribe { [weak self]_ in
            guard let `self` = self else { return }
            if let market = self.model?.exchangeType?.lowercased() {
                let exchangeType = YXExchangeType.exchangeType(market)
                YXHoldShareView.showShareView(
                    type: .asset,
                    exchangeType: exchangeType.rawValue,
                    model: self.model
                )
            }
        }.disposed(by: rx.disposeBag)

        return button
    }()

    lazy var dailyPLTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "hold_daily_profit_loss")
        return label
    }()

    // 今日盈亏
    lazy var dailyPLLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textAlignment = .right
        label.font = .mediumFont12()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    lazy var totalPLTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "hold_total_balance")
        return label
    }()

    // 持仓盈亏
    lazy var totalPLLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textAlignment = .right
        label.font = .mediumFont12()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    @objc lazy var detailButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: -12)
        button.tintColor = QMUITheme().textColorLevel4()
        button.adjustsImageTintColorAutomatically = true
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "account_asset_arrow"), for: .normal)
        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            self?.detailButtonAction?()
        })
        return button
    }()

    @objc lazy var assetView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F")
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true

        view.addSubview(positionValueTitleLabel)
        view.addSubview(positionValueLabel)
        view.addSubview(shareButton)
        view.addSubview(dailyPLTitleLabel)
        view.addSubview(dailyPLLabel)
        view.addSubview(totalPLTitleLabel)
        view.addSubview(totalPLLabel)
        view.addSubview(detailButton)

        positionValueTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(12)
        }

        positionValueLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-12)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(dailyPLTitleLabel)
            make.right.equalTo(dailyPLTitleLabel.snp.left).offset(-4)
        }

        dailyPLTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dailyPLLabel)
            make.right.equalTo(dailyPLLabel.snp.left).offset(-4)
        }

        dailyPLLabel.snp.makeConstraints { make in
            make.top.equalTo(11)
            make.right.equalTo(detailButton.snp.left).offset(-14)
        }

        totalPLTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(totalPLLabel)
            make.right.equalTo(totalPLLabel.snp.left).offset(-4)
        }

        totalPLLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-11)
            make.right.equalTo(detailButton.snp.left).offset(-14)
        }

        detailButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(assetView)
        assetView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func moneyFormatValue(value: String?) -> String {
        if let v = Double(value ?? "") {
            return moneyFormatter.string(from: NSNumber(value: v)) ?? "0.00"
        }else {
            return "0.00"
        }
    }

}
