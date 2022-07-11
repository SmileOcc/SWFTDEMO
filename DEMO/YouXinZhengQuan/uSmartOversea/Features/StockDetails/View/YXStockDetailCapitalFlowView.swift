//
//  YXStockDetailCapitalFlowView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailCapitalSubView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initUI() {
        addSubview(circleView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        circleView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
        }
        circleView.layer.cornerRadius = 5

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(circleView.snp.right).offset(uniSize(6))
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(uniSize(6))
        }

        valueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var circleView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        if YXUserManager.isENMode() {
            label.font = UIFont.systemFont(ofSize: 10)
        } else {
            label.font = UIFont.systemFont(ofSize: 12)
        }
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        if YXUserManager.isENMode() {
            label.font = UIFont.systemFont(ofSize: 10)
        } else {
            label.font = UIFont.systemFont(ofSize: 12)
        }
        label.textAlignment = .right
        label.text = "--"
        return label
    }()

}

class YXStockDetailCapitalFlowView: YXStockDetailBaseView {

    var pushToCashFlowBlock: (() -> Void)?

    func refreshUI(_ model: YXStockAnalyzeCapitalModel) {
        if let offsetValue = model.netin, let priceBase = model.priceBase {
            valueLabel.text = YXToolUtility.stockData(offsetValue, deciPoint: 2, stockUnit: "", priceBase: priceBase)
        } else {
            valueLabel.text = "--"
        }

        let priceBase = model.priceBase ?? 0
        let base = pow(10.0, Double.init(priceBase))
        let bin = self.getDoubleValue(model.bin, base: base)
        let min = self.getDoubleValue(model.min, base: base)
        let sin = self.getDoubleValue(model.sin, base: base)
        let bout = self.getDoubleValue(model.bout, base: base)
        let mout = self.getDoubleValue(model.mout, base: base)
        let sout = self.getDoubleValue(model.sout, base: base)

        let arr = [ bin, min, sin, bout, mout, sout ]

        let a = arr.map{ $0.doubleValue }
        let total = a.reduce(0, +)

        let max = a.max()
        if let max = max, max > 0 {

            sellBigOrderView.valueLabel.text = String(format: "%.02f%%", bout.doubleValue * 100.0 / total)
            sellMiddelOrderView.valueLabel.text = String(format: "%.02f%%", mout.doubleValue * 100.0 / total)
            sellSmallOrderView.valueLabel.text = String(format: "%.02f%%", sout.doubleValue * 100.0 / total)

            buyBigOrderView.valueLabel.text = String(format: "%.02f%%", bin.doubleValue * 100.0 / total)
            buyMiddelOrderView.valueLabel.text = String(format: "%.02f%%", min.doubleValue * 100.0 / total)
            buySmallOrderView.valueLabel.text = String(format: "%.02f%%", sin.doubleValue * 100.0 / total)

            self.chartView.dataArr = [ NSNumber.init(value: bout.doubleValue / total), NSNumber.init(value: mout.doubleValue / total), NSNumber.init(value: sout.doubleValue / total), NSNumber.init(value: sin.doubleValue / total), NSNumber.init(value: min.doubleValue / total), NSNumber.init(value: bin.doubleValue / total)]

        } else {
            sellBigOrderView.valueLabel.text = "--"
            sellMiddelOrderView.valueLabel.text = "--"
            sellSmallOrderView.valueLabel.text = "--"

            buyBigOrderView.valueLabel.text = "--"
            buyBigOrderView.valueLabel.text = "--"
            buyBigOrderView.valueLabel.text = "--"

            self.chartView.dataArr = [NSNumber]()
        }
    }

    func getDoubleValue(_ value: Double?, base: Double ) -> NSNumber {
        if let value = value {
            return NSNumber.init(value: value / base)
        }
        return NSNumber.init(value: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        topView.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
            if ges.state == .ended {
                self.pushToCashFlowBlock?()
            }
        }).disposed(by: rx.disposeBag)

        let colors = [ UIColor.qmui_color(withHexString: "#F1B92D")!, UIColor.qmui_color(withHexString: "#FEDC85")!, UIColor.qmui_color(withHexString: "#FFF1CC")!, UIColor.qmui_color(withHexString: "#CEDEFE")!, UIColor.qmui_color(withHexString: "#8FAFEF")!, UIColor.qmui_color(withHexString: "#0055FF")!]

        let circles = [sellBigOrderView.circleView, sellMiddelOrderView.circleView, sellSmallOrderView.circleView, buySmallOrderView.circleView, buyMiddelOrderView.circleView, buyBigOrderView.circleView]
        for (index, color) in colors.enumerated() {
            if index < circles.count {
                circles[index].backgroundColor = color
            }
        }

        self.chartView.dataArr = [NSNumber]()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initUI() {


        addSubview(topView)
        topView.addSubview(titleLabel)
        topView.addSubview(valueLabel)
        topView.addSubview(arrowImageView)

        var margin:CGFloat = 18
        if YXToolUtility.is4InchScreenWidth() {
            margin = uniSize(16)
        }

        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(10)
        }

        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.width.equalTo(7)
            make.height.equalTo(12)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        var rightMargin:CGFloat = uniSize(20)
        if YXToolUtility.is4InchScreenWidth() {
            rightMargin = uniSize(10)
        }

        addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.height.width.equalTo(uniSize(100))
        }

        addSubview(buyTitleLabel)
        buyTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.right.equalTo(chartView.snp.left).offset(-rightMargin)
            make.height.equalTo(20)
        }

        addSubview(buyBigOrderView)
        buyBigOrderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(buyTitleLabel.snp.bottom).offset(10)
            make.right.equalTo(chartView.snp.left).offset(-rightMargin)
            make.height.equalTo(20)
        }

        addSubview(buyMiddelOrderView)
        buyMiddelOrderView.snp.makeConstraints { (make) in
            make.left.equalTo(buyBigOrderView)
            make.top.equalTo(buyBigOrderView.snp.bottom)
            make.right.equalTo(buyBigOrderView)
            make.height.equalTo(20)
        }

        addSubview(buySmallOrderView)
        buySmallOrderView.snp.makeConstraints { (make) in
            make.left.equalTo(buyBigOrderView)
            make.top.equalTo(buyMiddelOrderView.snp.bottom)
            make.right.equalTo(buyBigOrderView)
            make.height.equalTo(20)
        }


        addSubview(sellTitleLabel)
        sellTitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.left.equalTo(chartView.snp.right).offset(rightMargin)
            make.height.equalTo(20)
        }

        addSubview(sellBigOrderView)
        sellBigOrderView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(sellTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(chartView.snp.right).offset(rightMargin)
            make.height.equalTo(20)
        }

        addSubview(sellMiddelOrderView)
        sellMiddelOrderView.snp.makeConstraints { (make) in
            make.left.equalTo(sellBigOrderView)
            make.top.equalTo(sellBigOrderView.snp.bottom)
            make.right.equalTo(sellBigOrderView)
            make.height.equalTo(20)
        }

        addSubview(sellSmallOrderView)
        sellSmallOrderView.snp.makeConstraints { (make) in
            make.left.equalTo(sellBigOrderView)
            make.top.equalTo(sellMiddelOrderView.snp.bottom)
            make.right.equalTo(sellBigOrderView)
            make.height.equalTo(20)
        }
    }

    lazy var topView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "stock_detail_money_flow")
        return label
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.text = "--"
        return label
    }()

    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "grey_right_arrow")
        return imageView
    }()

    lazy var chartView: YXPieChartView = {
        let view = YXPieChartView.init()
        view.chartView.drawCenterTextEnabled = false
        view.chartYValuePositon = .insideSlice
        view.edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.isDrawValueEnabled = false
        return view
    }()

    lazy var buyTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "buy")
        return label
    }()

    lazy var buyBigOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_large")
        return view
    }()

    lazy var buyMiddelOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_medium")
        return view
    }()

    lazy var buySmallOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_small")
        return view
    }()

    lazy var sellTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "sale")
        return label
    }()

    lazy var sellBigOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_large")
        return view
    }()

    lazy var sellMiddelOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_medium")
        return view
    }()

    lazy var sellSmallOrderView: YXStockDetailCapitalSubView = {
        let view = YXStockDetailCapitalSubView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "analytics_money_small")
        return view
    }()

}
