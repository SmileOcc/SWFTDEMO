//
//  YXStockDetailBriefCell.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailWarrantsBriefView: UIView {

    var clickStockDetalCallBack: (() -> ())?

    var titles: [YXStockDetailBasicType] = [YXStockDetailBasicType]() {
        didSet {
            if oldValue.count == 0 {
                for view in parameterViews {
                    view.removeFromSuperview()
                }
                for x in 0..<self.titles.count {
                    let type = self.titles[x]
                    let paramView = YXStockParameterView()
                    parameterViews.append(paramView)
                    self.addSubview(paramView)
                    //5行2列(一行一行的约束)
                    paramView.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().offset(16)
                        make.right.equalToSuperview().offset(-16)
                        make.top.equalTo(self.snp.top).offset(x * 40 + 64)
                        make.height.equalTo(40)
                        if x == self.titles.count - 1 {
                            make.bottom.equalToSuperview().offset(-YXConstant.tabBarHeight())
                        }
                    }
                    paramView.titleLabel.text = type.title
                    paramView.valueLabel.text = "--"

                    if type.title == YXLanguageUtility.kLang(key: "stock_detail_stock") {
                        paramView.addSubview(self.propertyRateLabel)
                        paramView.addSubview(self.propertyNameLabel)
                        paramView.addSubview(self.clickControl)

                        self.propertyRateLabel.snp.makeConstraints { (make) in
                            make.right.equalToSuperview()
                            make.height.equalTo(18)
                            make.centerY.equalToSuperview()
                        }

                        self.propertyNameLabel.snp.makeConstraints { (make) in
                            make.right.equalToSuperview().offset(-55)
                            make.height.equalTo(22)
                            make.centerY.equalToSuperview()
                            make.left.equalTo(paramView.titleLabel.snp.right).offset(5)
                        }

                        clickControl.snp.makeConstraints { (make) in
                            make.edges.equalTo(self.propertyNameLabel)
                        }
                    }

                }

            }
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var kwarrantModel: YXHkwarrantModel? {
        didSet {
            refreshUI()
        }
    }

    var roc: Int64? {
        didSet {
            var temp: Int64 = 0
            if let roc = self.roc {
                temp = roc
            } else {
                temp = 0
            }
            let number = YXToolUtility.stockPercentData(Double(temp), priceBasic: 2, deciPoint: 2)
            self.propertyRateLabel.text = number
            self.propertyRateLabel.textColor = YXToolUtility.changeColor(Double(temp))
        }
    }

    var relateStockName: String? = "" {
        didSet {

            propertyNameLabel.text = relateStockName
        }
    }

    var currentStockName: String = "" {
        didSet {
            for (index, type) in titles.enumerated() {
                if type == .name {
                    parameterViews[index].valueLabel.text = currentStockName
                }

            }
        }
    }


    var relatePriceBase: Int = 3 {

        didSet {
            for (index, type) in titles.enumerated() {
                if type == .upperStrike, let priceCeiling = kwarrantModel?.priceCeiling {
                    parameterViews[index].valueLabel.text = YXToolUtility.stockPriceData(priceCeiling, deciPoint: relatePriceBase, priceBase: 0)
                } else if type == .lowerStrike, let priceFloor = kwarrantModel?.priceFloor {
                    parameterViews[index].valueLabel.text = YXToolUtility.stockPriceData(priceFloor, deciPoint: relatePriceBase, priceBase: 0)
                } else if type == .exercise_price, let exercisePrice = kwarrantModel?.exercisePrice {
                     parameterViews[index].valueLabel.text = YXToolUtility.stockPriceData(Double(exercisePrice), deciPoint: relatePriceBase, priceBase: 0)
                }

            }
        }
    }

    func refreshUI() -> Void {

        guard let kwarrantModel = kwarrantModel else {
            return
        }

        for x in 0..<titles.count {
            let type = titles[x]
            switch type {
                case .stock:
                    parameterViews[x].valueLabel.text = ""
                    //parameterViews[x].valueLabel.text = kwarrantModel.targetName ?? "--"
                case .wc_trading_unit:
                    if let tradingUnit = kwarrantModel.tradingUnit {
                        parameterViews[x].valueLabel.text = "\(tradingUnit)"
                    }

                case .days_remain:
                    if var daysRemain = kwarrantModel.daysRemain {
                        if daysRemain > 0 {
                            daysRemain = daysRemain - 1
                        } else {
                            daysRemain = 0
                        }
                        parameterViews[x].valueLabel.text = "\(daysRemain)" + YXLanguageUtility.kLang(key: "common_day_unit")
                    }
                case .maturity_date:
                    if let maturityDate = kwarrantModel.maturityDate {
                        parameterViews[x].valueLabel.text = maturityDate.subString(toCharacterIndex: 10)
                }
                case .last_trade_day:
                    if let lastTradeDay = kwarrantModel.lastTradeDay {
                        parameterViews[x].valueLabel.text = lastTradeDay.subString(toCharacterIndex: 10)
                    }
                case .listed_date:
                    if let listedDate = kwarrantModel.listedDate {
                        parameterViews[x].valueLabel.text = listedDate.subString(toCharacterIndex: 10)
                    }
                case .issue_vol:
                    if let issueVol = kwarrantModel.issueVol {

                        let str = YXToolUtility.stockData(Double(issueVol), deciPoint: 2, stockUnit: "", priceBase: 0)
                        //YXLanguageUtility.kLang(key: "newStock_stock_unit")
                        parameterViews[x].valueLabel.text = str
                    }
                case .ent_ratio:
                    if let entRatio = kwarrantModel.entRatio {
                        parameterViews[x].valueLabel.text = String.init(format: "%.2f", Double(entRatio))
                    }
                case .exercise_price:
                    if let exercisePrice = kwarrantModel.exercisePrice {
                        parameterViews[x].valueLabel.text = YXToolUtility.stockPriceData(Double(exercisePrice), deciPoint: relatePriceBase, priceBase: 0)
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .name:
                    if self.currentStockName.count > 0 {
                        parameterViews[x].valueLabel.text = currentStockName
                    } else {
                        parameterViews[x].valueLabel.text = kwarrantModel.secuName ?? "--"
                    }
                case .secuCode:
                    if let code = kwarrantModel.secuCode {
                        parameterViews[x].valueLabel.text = code
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .upperStrike:
                    if let priceCeiling = kwarrantModel.priceCeiling {
                        parameterViews[x].valueLabel.text = YXToolUtility.stockPriceData(priceCeiling, deciPoint: relatePriceBase, priceBase: 0)
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .lowerStrike:
                    if let priceFloor = kwarrantModel.priceFloor {
                        parameterViews[x].valueLabel.text = YXToolUtility.stockPriceData(priceFloor, deciPoint: relatePriceBase, priceBase: 0)
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .issuer:
                    if let issuer = kwarrantModel.issuer {
                        parameterViews[x].valueLabel.text = issuer
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .callPrice:
                    if let recoveryPrice = kwarrantModel.recoveryPrice {
                        parameterViews[x].valueLabel.text = String.init(format: "%.3f", Double(recoveryPrice))
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .calculation:
                    if kwarrantModel.settlementMode == 1 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_cash_settlement")
                    } else if kwarrantModel.settlementMode == 2 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_stock_settlement")
                    } else if kwarrantModel.settlementMode == 99 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_announce_other")
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                case .stockNature:
                    if kwarrantModel.warrantCharacter == 1 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_call_warrant")
                    } else if kwarrantModel.warrantCharacter == 2 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "warrants_sell")
                    } else if kwarrantModel.warrantCharacter == 3 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "warrants_bull")
                    } else if kwarrantModel.warrantCharacter == 4 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "warrants_bear")
                    } else if kwarrantModel.warrantCharacter == 5 {
                        parameterViews[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_announce_other")
                    } else {
                        parameterViews[x].valueLabel.text = "--"
                    }
                default:
                    print("")
            }
        }

    }

    var parameterViews: [YXStockParameterView] = [YXStockParameterView]()

    func initUI() -> Void {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }
    }

    @objc func clickStockDetail(_ sender: UIControl) {
        self.clickStockDetalCallBack?()
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "stock_detail_briefing")
        return label
    }()

    lazy var propertyNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()

    lazy var propertyRateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy var clickControl: UIControl = {
        let control = UIControl.init()
        control.addTarget(self, action: #selector(self.clickStockDetail), for: .touchUpInside)
        return control
    }()
}

