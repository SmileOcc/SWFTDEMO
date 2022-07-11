//
//  YXStockTopView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit


class YXStockTopView: UIView {

    @objc var model: YXV2Quote? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let quote = model {

            if let name = quote.name, !name.isEmpty {
                nameLabel.text = name
            } else {
                nameLabel.text = "--"
            }
            if let symbol = quote.symbol {
                symbolLabel.text = "(\(symbol))"
            } else {
                symbolLabel.text = ""
            }
            
            delayLabel.isHidden = quote.level?.value != 0

            let priceBase = quote.priceBase?.value ?? 0

            var color = QMUITheme().stockGrayColor()

            var changeString = ""
            var changeValue: Int64 = 0

            if let market = quote.market, market == kYXMarketCryptos {

                let decimalCount = YXToolUtility.btDecimalPoint(quote.btRealTime?.now)
                self.nowLabel.text = YXToolUtility.btNumberString(quote.btRealTime?.now, decimalPoint: decimalCount)

                if let valueStr = quote.btRealTime?.netchng, let value = Double(valueStr)  {
                    changeString = YXToolUtility.btNumberString(valueStr, decimalPoint: decimalCount, showPlus: true)
                    changeValue = Int64(value)
                } else {
                    changeString = "0.000"
                }

                if let valueStr = quote.btRealTime?.pctchng, let value = Double(valueStr)  {
                    changeString += String(format: " (%@%%)", (value > 0 ? "+" : "") + valueStr)
                } else {
                    changeString += "(0.00%)"
                }

            } else {
                if let change = quote.netchng?.value {
                    color = YXToolUtility.stockColor(withData: Double(change), compareData: 0)
                    let value = YXToolUtility.stockPriceData(Double(change), deciPoint: Int(priceBase), priceBase: Int(priceBase)) ?? "0.000"
                    changeString = (change > 0 ? "+" : "") + value
                    changeValue = change
                } else {
                    changeString = "0.000"
                }

                if let roc = quote.pctchng?.value {

                    let value = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2) ?? "0.00"
                    changeString += String(format: " (%@)", value)
                } else {
                    changeString += " (0.00%)"
                }

                if let now = quote.latestPrice?.value {
                    nowLabel.text = YXToolUtility.stockPriceData(Double(now), deciPoint: Int(priceBase), priceBase: Int(priceBase)) ?? "--"
                } else {
                    nowLabel.text = "--"
                }
            }


            changeLabel.text = changeString

            nowLabel.textColor = color
            changeLabel.textColor = color

            directionImageView.image = YXStockDetailTool.changeDirectionImage(Double(changeValue))
            if changeValue == 0 {
                directionImageView.snp.makeConstraints { (make) in
                    make.width.equalTo(0)
                }
            } else {
                directionImageView.snp.makeConstraints { (make) in
                    make.width.equalTo(16)
                }
            }

        }


        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(nameLabel)
        addSubview(symbolLabel)
        addSubview(delayLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(21)
        }

        symbolLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.right.lessThanOrEqualToSuperview().offset(-36)
        }
        
        delayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(symbolLabel)
            make.left.equalTo(symbolLabel.snp.right).offset(3)
        }

        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        addSubview(directionImageView)
        addSubview(changeLabel)
        addSubview(nowLabel)


        nowLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.height.equalTo(20)
        }

        directionImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(nowLabel)
            make.left.equalTo(nowLabel.snp.right).offset(12)
            make.width.height.equalTo(16)
        }

        changeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nowLabel)
            make.left.equalTo(directionImageView.snp.right).offset(1)
        }


        addSubview(seperatorView)
        seperatorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

    }



    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()

    lazy var directionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.text = ""
        return label
    }()

    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.text = "0.000"
        return label
    }()

    lazy var nowLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.text = "--"
        return label
    }()
    
    @objc lazy var delayLabel: UILabel = {
        let label = UILabel.delay()!
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.isHidden = true
        return label
    }()

    @objc lazy var seperatorView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
}

