//
//  YXStockDetailCasView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailCasView: YXStockDetailBaseView {

    @objc var quote: YXV2Quote? {
        didSet {
            contentView.quote = quote
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
        self.backgroundColor = QMUITheme().foregroundColor()

        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview()
        }
    }

    lazy var contentView: YXStockDetailCasContentView = {
        let view = YXStockDetailCasContentView()

        return view
    }()
}


class YXStockDetailCasContentView: YXStockDetailBaseView {


    @objc var quote: YXV2Quote? {
        didSet {
            if let status = quote?.msInfo?.status?.value, status == OBJECT_MARKETMarketStatus.msCloseCall.rawValue {
                titleLabel.text = YXLanguageUtility.kLang(key: "close_auction_session")
            } else {
                titleLabel.text = YXLanguageUtility.kLang(key: "open_auction_session")
            }
            //cas 不存在保留上一次的值
            if let cas = quote?.cas {
                let priceBase = Int(quote?.priceBase?.value ?? 0)
                if let upperPrice = cas.upperPrice?.value, upperPrice > 0,
                   let lowerPrice = cas.lowerPrice?.value, lowerPrice > 0 {
                    let upperPriceString = YXToolUtility.stockPriceData(Double(upperPrice), deciPoint: priceBase, priceBase: priceBase) ?? ""

                    let lowerPriceString = YXToolUtility.stockPriceData(Double(lowerPrice), deciPoint: priceBase, priceBase: priceBase) ?? ""
                    lowerUpperPriceLabel.text = lowerPriceString + "-" + upperPriceString
                }

                if let refPrice = cas.refPrice?.value, refPrice > 0 {
                    refPriceView.rightLabel.text =
                        YXToolUtility.stockPriceData(Double(refPrice), deciPoint: priceBase, priceBase: priceBase)
                }

                if let iePrice = cas.iePrice?.value, iePrice > 0 {
                    iePriceView.rightLabel.text = YXToolUtility.stockPriceData(Double(iePrice), deciPoint: priceBase, priceBase: priceBase)
                }

                if let ieVol = cas.ieVol?.value, ieVol > 0 {
                    ieVolView.rightLabel.attributedText = YXToolUtility.stocKNumberData(ieVol, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0, number: UIFont.systemFont(ofSize: 14, weight: .medium), unitFont: UIFont.systemFont(ofSize: 12, weight: .medium))
                }

                if let ordImbQty = cas.ordImbQty?.value, ordImbQty > 0 {
                    ordImbQtyView.rightLabel.attributedText = YXToolUtility.stocKNumberData(Int64(ordImbQty), deciPoint: 2, stockUnit: "", priceBase: 0, number: UIFont.systemFont(ofSize: 14, weight: .medium), unitFont: UIFont.systemFont(ofSize: 12, weight: .medium))
                }

                if let imbDirection = cas.imbDirection?.value {
                    if imbDirection == OBJECT_QUOTEIMBDirection.imbBuy.rawValue {
                        imbDirectionView.rightLabel.text = YXLanguageUtility.kLang(key: "buyer")
                    } else if imbDirection == OBJECT_QUOTEIMBDirection.imbSell.rawValue {
                        imbDirectionView.rightLabel.text = YXLanguageUtility.kLang(key: "seller")
                    } else if imbDirection == OBJECT_QUOTEIMBDirection.imbEqule.rawValue {
                        imbDirectionView.rightLabel.text = YXLanguageUtility.kLang(key: "no_premium")
                    } else {
                        imbDirectionView.rightLabel.text = "--"
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
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()

        addSubview(titleLabel)
        addSubview(lowerUpperTitleLabel)
        addSubview(lowerUpperPriceLabel)
        addSubview(refPriceView)
        addSubview(imbDirectionView)
        addSubview(ordImbQtyView)
        addSubview(iePriceView)
        addSubview(ieVolView)

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(20)
        }
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        lowerUpperPriceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
        }

        lowerUpperTitleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(lowerUpperPriceLabel.snp.left).offset(-8)
            make.centerY.equalTo(titleLabel)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(5)
        }

        let margin: CGFloat = 10.0
        let space: CGFloat = 10.0
        let width = (YXConstant.screenWidth - 2.0 * margin - 2.0 * space) / 3.0
        let height: CGFloat = 25

        let arr = [refPriceView, iePriceView, ieVolView,
                   ordImbQtyView, imbDirectionView]

        arr.forEach { [weak self] (view) in
            guard let `self` = self else { return }
            self.addSubview(view)
        }

        for (index, view) in arr.enumerated() {
            view.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(margin + CGFloat(index % 3) * (space + width))
                make.width.equalTo(width)
                make.height.equalTo(height)
                make.top.equalTo(titleLabel.snp.bottom).offset(6.0 + CGFloat(index / 3) * height)
            }
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()


    lazy var lowerUpperTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "price_range")
        return label
    }()

    lazy var lowerUpperPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.text = "--"
        return label
    }()

    lazy var refPriceView: YXStockDetailCasSubView = {
        let view = YXStockDetailCasSubView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "refer_price")
        return view
    }()


    lazy var imbDirectionView: YXStockDetailCasSubView = {
        let view = YXStockDetailCasSubView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "premium_direction")
        view.rightLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return view
    }()

    lazy var ordImbQtyView: YXStockDetailCasSubView = {
        let view = YXStockDetailCasSubView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "premium")
        return view
    }()

    lazy var iePriceView: YXStockDetailCasSubView = {
        let view = YXStockDetailCasSubView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.leftLabel.text = "IEP"
        return view
    }()

    lazy var ieVolView: YXStockDetailCasSubView = {
        let view = YXStockDetailCasSubView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.leftLabel.text = "IEV"
        return view
    }()

}


class YXStockDetailCasSubView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(leftLabel)
        addSubview(rightLabel)

        leftLabel.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(5)
        }
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        if YXToolUtility.is4InchScreenWidth() {
            label.font = UIFont.systemFont(ofSize: 11)
        }
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()
}

