//
//  YXStockChipDetailView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockChipDetailView: UIView {

    var priceBase: Int = 0
    var model: YXCYQList? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let info = model {
            let priceBase = self.priceBase 

            if let ninetyPer = info.ninetyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"

                let endPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                ninetyView.rightLabel.text = beginPriceString + "-" + endPriceString
            } else {
                ninetyView.rightLabel.text = "--"
            }

            if let seventyPer = info.seventyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(seventyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                let endPriceString = YXToolUtility.stockPriceData(Double(seventyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                seventyView.rightLabel.text = beginPriceString + "-" + endPriceString
            } else {
                seventyView.rightLabel.text = "--"
            }

            if info.chipCoincidence > 0 {
                coincidenceRateLabel.text = String(format: "  %.2f%%", Double(info.chipCoincidence) / 100.0)
            } else {
                coincidenceRateLabel.text = "--"
            }

            if info.winnerRate > 0 {
                winRateView.rightLabel.text = String(format: "%.2f%%", Double(info.winnerRate) / 100.0)
            } else {
                winRateView.rightLabel.text = "--"
            }

            if info.avgCost > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.avgCost), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                averageView.rightLabel.text = value
            } else {
                averageView.rightLabel.text = "--"
            }

            if info.supPosition > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.supPosition), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                supportView.rightLabel.text = value
            } else {
                supportView.rightLabel.text = "--"
            }

            if info.pressPosition > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.pressPosition), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                pressureView.rightLabel.text = value
            } else {
                pressureView.rightLabel.text = "--"
            }

            if info.tradeDay > 0 {
                dateLabel.text = YXLanguageUtility.kLang(key: "broker_date") + ": " + YXDateHelper.commonDateStringWithNumber(info.tradeDay, format: .DF_MDY, scaleType: .scale, showWeek: false)
            } else {
                dateLabel.text = YXLanguageUtility.kLang(key: "broker_date") + ": --"
            }

            self.chartView.priceBase = priceBase
            self.chartView.model = info

            coincidenceProgressView.priceBase = priceBase
            coincidenceProgressView.model = info
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

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(24)
        }

        addSubview(chipLabel)
        chipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(24)
            make.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-10)
        }


        addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(chipLabel.snp.bottom).offset(24)
            make.height.equalTo(185)
        }

        let averageLineView = colorLineView(color: QMUITheme().themeTextColor(), text: YXLanguageUtility.kLang(key: "average_cost"))
        let supportLineView = colorLineView(color: UIColor.qmui_color(withHexString: "#FF6933"), text: YXLanguageUtility.kLang(key: "support_level"))
        let pressureLineView = colorLineView(color: UIColor.qmui_color(withHexString: "#F9A800"), text: YXLanguageUtility.kLang(key: "pressure_level"))
        addSubview(averageLineView)
        addSubview(supportLineView)
        addSubview(pressureLineView)

        let lineMaXWidth = (YXConstant.screenWidth - 52) / 3.0
        pressureLineView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-26)
            make.top.equalTo(chartView.snp.bottom).offset(22)
            make.height.equalTo(16)
            make.width.lessThanOrEqualTo(lineMaXWidth)
        }

        supportLineView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(chartView.snp.bottom).offset(22)
            make.height.equalTo(16)
            make.width.lessThanOrEqualTo(lineMaXWidth)
        }

        averageLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(26)
            make.top.equalTo(chartView.snp.bottom).offset(22)
            make.height.equalTo(16)
            make.width.lessThanOrEqualTo(lineMaXWidth)
        }

//        let seperatorView = UIView()
//        seperatorView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
//        addSubview(seperatorView)
//        seperatorView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalTo(chartView.snp.bottom).offset(29)
//            make.height.equalTo(4)
//        }

        addSubview(dataAnalyzeLabel)
        dataAnalyzeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(averageLineView.snp.bottom).offset(46)
            make.height.equalTo(24)
        }

        addSubview(winRateView)
        addSubview(averageView)
        addSubview(pressureView)
        addSubview(supportView)

        let width = (YXConstant.screenWidth - 62) / 2.0
        winRateView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(width)
            make.top.equalTo(dataAnalyzeLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }

        averageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(width)
            make.top.equalTo(dataAnalyzeLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }

        pressureView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(width)
            make.top.equalTo(winRateView.snp.bottom)
            make.height.equalTo(40)
        }

        supportView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(width)
            make.top.equalTo(averageView.snp.bottom)
            make.height.equalTo(40)
        }

        addSubview(chipRangeLabel)
        chipRangeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(pressureView.snp.bottom).offset(26)
            make.height.equalTo(24)
        }

        addSubview(ninetyView)
        addSubview(seventyView)

        ninetyView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(chipRangeLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }

        seventyView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(ninetyView.snp.bottom)
            make.height.equalTo(40)
        }


        addSubview(coincidenceLabel)
        coincidenceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            //make.right.equalToSuperview().offset(-12)
            make.top.equalTo(seventyView.snp.bottom).offset(36)
            make.height.equalTo(24)
        }


        addSubview(coincidenceRateLabel)
        coincidenceRateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(coincidenceLabel)
            make.height.equalTo(20)
        }

        addSubview(coincidenceProgressView)
        coincidenceProgressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(coincidenceLabel.snp.bottom).offset(19)
            make.height.equalTo(70)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    lazy var chipLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "chip_chart")
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "broker_date") + ": --"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()



    func colorLineView(color: UIColor?, text: String) -> UIView {

        let view = UIView()

        let indicatorView = UIView()
        indicatorView.backgroundColor = color
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(2)
        }

        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.text = text
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(indicatorView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        return view
    }

    lazy var chartView: YXCYQChartView = {
        let view = YXCYQChartView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 32, height: 185), isChipDetail: true)
        view.lineWidth = 1.0
//        view.layer.borderWidth = 0.5
//        view.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        return view
    }()

    lazy var dataAnalyzeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "chip_analyze")
        return label
    }()


    lazy var chipRangeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "chip_range")
        return label
    }()

    lazy var coincidenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "chip_coincidence")
        return label
    }()

    lazy var coincidenceRateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    lazy var winRateView: YXStockChipDetailLRView = {
        let view = YXStockChipDetailLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "profit_ratio")
        return view
    }()

    lazy var averageView: YXStockChipDetailLRView = {
        let view = YXStockChipDetailLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "average_cost")
        return view
    }()

    lazy var pressureView: YXStockChipDetailLRView = {
        let view = YXStockChipDetailLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "pressure_level")
        return view
    }()

    lazy var supportView: YXStockChipDetailLRView = {
        let view = YXStockChipDetailLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "support_level")
        return view
    }()

    lazy var ninetyView: YXStockChipDetailLeftAlignmentView = {
        let view = YXStockChipDetailLeftAlignmentView(frame: .zero, margin: 26)
        view.leftLabel.text = YXLanguageUtility.kLang(key: "ninety_chips_range")
        return view
    }()

    lazy var seventyView: YXStockChipDetailLeftAlignmentView = {
        let view = YXStockChipDetailLeftAlignmentView(frame: .zero, margin: 26)
        view.leftLabel.text = YXLanguageUtility.kLang(key: "seventy_chips_range")
        return view
    }()


    lazy var coincidenceProgressView: YXStockChipDetailCoincidenceView = {
        let view = YXStockChipDetailCoincidenceView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 70))

        return view
    }()
}

class YXStockChipDetailLRView: UIView {

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
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalTo(leftLabel.snp.right).offset(5)
        }

        leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "--"
        return label
    }()
}


class YXStockChipDetailLeftAlignmentView: UIView {

    init(frame: CGRect, margin: CGFloat = 26) {
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
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(leftLabel.snp.right).offset(30)
//            make.centerY.equalToSuperview()
//            make.right.lessThanOrEqualToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalTo(leftLabel.snp.right).offset(5)
        }

        leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "--"
        return label
    }()
}


class YXStockChipDetailCoincidenceView: UIView {


    var priceBase: Int = 0
    var model: YXCYQList? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let info = model {
            let priceBase = self.priceBase

            var ninetyMin: Double = 0
            var ninetyMax: Double = 0
            var seventyMin: Double = 0
            var seventyMax: Double = 0

            if let ninetyPer = info.ninetyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                let endPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                ninetyMax = Double(ninetyPer.endPrice)
                ninetyMin = Double(ninetyPer.beginPrice)
                bottomMinLabel.text = beginPriceString
                bottomMaxLabel.text = endPriceString
            } else {
                bottomMinLabel.text = "--"
                bottomMaxLabel.text = "--"
            }

            if let seventyPer = info.seventyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(seventyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                let endPriceString = YXToolUtility.stockPriceData(Double(seventyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0.000"
                seventyMax = Double(seventyPer.endPrice)
                seventyMin = Double(seventyPer.beginPrice)
                topMinLabel.text = beginPriceString
                topMaxLabel.text = endPriceString
            } else {
                topMinLabel.text = "--"
                topMaxLabel.text = "--"
            }

            let ninetyRange = ninetyMax - ninetyMin
            let seventyRange = seventyMax - seventyMin
            let minRange = seventyMin - ninetyMin
            var leftScale: CGFloat = 0
            var widthScale: CGFloat = 0
            if ninetyRange > 0, minRange > 0 {
                leftScale = CGFloat(minRange / ninetyRange)
            }

            if ninetyRange > 0, seventyRange > 0 {
                widthScale = CGFloat(seventyRange / ninetyRange)
                if widthScale > 1 {
                    widthScale = 1
                }
            }

            changeProgressView.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(self.maxWidth * leftScale + lrMargin)
                make.width.equalTo(self.maxWidth * widthScale)
            }

            topMinLabel.sizeToFit()
            topMinLabel.center = CGPoint(x: self.maxWidth * leftScale + lrMargin, y: topMinLabel.center.y)

            topMaxLabel.sizeToFit()
            topMaxLabel.center = CGPoint(x: self.maxWidth * leftScale + lrMargin + self.maxWidth * widthScale, y: topMaxLabel.center.y)
            self.adjustTopLabelFrame()

        }

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let maxWidth: CGFloat = (YXConstant.screenWidth - 32.0)
    let lrMargin: CGFloat = 16

    func initUI() {

        //self.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)

        addSubview(backProgressView)
        backProgressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(lrMargin)
            make.right.equalToSuperview().offset(-lrMargin)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }

        addSubview(changeProgressView)
        changeProgressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.maxWidth * 0.15 + lrMargin)
            make.width.equalTo(self.maxWidth * 0.7)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
        }

        addSubview(topMinLabel)
        addSubview(topMaxLabel)
        addSubview(bottomMinLabel)
        addSubview(bottomMaxLabel)

        bottomMinLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(backProgressView.snp.bottom).offset(8)
            make.height.equalTo(16)
        }

        bottomMaxLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(backProgressView.snp.bottom).offset(8)
            make.height.equalTo(16)
        }

        topMinLabel.sizeToFit()
        topMinLabel.frame = CGRect(x:lrMargin + self.maxWidth * 0.15 - topMinLabel.width / 2.0, y: 5, width: topMinLabel.width, height: 16)

        topMaxLabel.sizeToFit()
        topMaxLabel.frame = CGRect(x: lrMargin + self.maxWidth * 0.85 - topMaxLabel.width / 2.0, y: 5, width: topMaxLabel.width, height: 16)
    }

    func adjustTopLabelFrame() {

        if (topMinLabel.frame.minX < 16) {
            topMinLabel.center = CGPoint(x: 16 + topMinLabel.width / 2.0, y: topMinLabel.center.y)
        }

        if (topMaxLabel.frame.maxX > YXConstant.screenWidth - 16.0) {
            topMaxLabel.center = CGPoint(x: YXConstant.screenWidth - 16.0 - topMaxLabel.width / 2.0, y: topMaxLabel.center.y)
        }
    }


    lazy var topMinLabel: UILabel = {
        return self.priceLabel(.center)
    }()

    lazy var topMaxLabel: UILabel = {
        return self.priceLabel(.center)
    }()

    lazy var bottomMinLabel: UILabel = {
        let label = self.priceLabel(.left)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()

    lazy var bottomMaxLabel: UILabel = {
        let label = self.priceLabel(.right)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()

    lazy var backProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()

    lazy var changeProgressView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = QMUITheme().themeTextColor()
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()


    func priceLabel(_ textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = textAlignment
        label.text = "--"
        return label
    }
}

class YXStockChipDetailSliderView: UIView {

    var singleModel: YXCYQModel? {
        didSet {
            if let info = singleModel?.list?.first {
                if info.tradeDay > 0 {
                    if YXUserManager.isENMode() {
                        endDateLabel.text = YXDateHelper.commonDateStringWithNumber(info.tradeDay)
                        currentDateLabel.text = YXDateHelper.commonDateStringWithNumber(info.tradeDay, format: .DF_MD, scaleType: .scale, showWeek: false)
                    } else {
                        let dateModel = YXDateToolUtility.dateTime(withTime: String(info.tradeDay))
                        endDateLabel.text = dateModel.year + "-" + dateModel.month + "-" + dateModel.day
                        currentDateLabel.text = dateModel.month + "-" + dateModel.day
                    }
                    self.currentDateLabel.sizeToFit()
                    self.adjustFitFrame()
                } else {
                    endDateLabel.text = "--"
                    currentDateLabel.text = "--"
                }
            }
        }
    }

    var dateArray: [String] = []

    var model: YXCYQModel? {
        didSet {
            if let list = model?.list {
                dateArray.removeAll()
                self.silderView.maxCount = list.count
                for (index, info) in list.enumerated() {
            
                    let dateString = YXDateHelper.commonDateStringWithNumber(info.tradeDay, format: .DF_MD, scaleType: .scale)
                    
                    if index == 0 {
                        startDateLabel.text = YXDateHelper.commonDateStringWithNumber(info.tradeDay, format: .DF_MDY, scaleType: .scale)
                        
                    } else if index == list.count - 1 {
                        endDateLabel.text = YXDateHelper.commonDateStringWithNumber(info.tradeDay, format: .DF_MDY, scaleType: .scale)
                        currentDateLabel.text = dateString
                        self.currentDateLabel.sizeToFit()
                        self.adjustFitFrame()
                    }

                    dateArray.append(dateString)
                }

            }
        }
    }

    @objc var chipInfoBlock: ((_ info: YXCYQList, _ priceBase: Int) -> Void)?

    let leftMargin: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        silderView.progessBlock = {
            [weak self] (index, progress) in
            guard let `self` = self else { return }

            if index < self.dateArray.count {
                let dateString = self.dateArray[index]
                self.currentDateLabel.text = dateString
                self.currentDateLabel.sizeToFit()
            }
            let prgressWidth = (self.width - self.leftMargin * 2)
            self.currentDateLabel.center = CGPoint(x: (progress * prgressWidth) + self.leftMargin, y: self.currentDateLabel.center.y)
            self.adjustFitFrame()
            if let list = self.model?.list, index < list.count {
                self.chipInfoBlock?(list[index], self.model?.priceBase ?? 0)
            }

        }
    }

    func adjustFitFrame() {
        if self.currentDateLabel.frame.minX < self.leftMargin  {
            self.currentDateLabel.center = CGPoint(x: self.leftMargin + self.currentDateLabel.frame.width / 2.0, y: self.currentDateLabel.center.y)
        }

        if self.currentDateLabel.frame.maxX > self.width - self.leftMargin {
            self.currentDateLabel.center = CGPoint(x: self.width - self.leftMargin - self.currentDateLabel.frame.width / 2.0, y: self.currentDateLabel.center.y)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        //self.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)

        addSubview(silderView)
        addSubview(startDateLabel)
        addSubview(endDateLabel)
        addSubview(currentDateLabel)

        silderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(29)
            make.height.equalTo(20)
        }

        startDateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(silderView.snp.bottom).offset(4)
            make.height.equalTo(16)
        }

        endDateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(silderView.snp.bottom).offset(4)
            make.height.equalTo(16)
        }

        self.currentDateLabel.sizeToFit()
        self.currentDateLabel.frame = CGRect(x: self.width - self.leftMargin - self.currentDateLabel.frame.width, y: 5, width: self.currentDateLabel.frame.width, height: 16)
    }


    lazy var startDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .left
        return label
    }()

    lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .right
        return label
    }()

    lazy var currentDateLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 8, width: 100, height: 16)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.text = "--"
        return label
    }()

    lazy var silderView: YXStockChipDetailSlider = {
        let view = YXStockChipDetailSlider(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 32, height: 20))

        return view
    }()

}


class YXStockChipDetailSlider: UIView {

    var maxCount: Int = 2
    var trackHeight: CGFloat = 12.0
    let thumbWH: CGFloat = 18

    var lastIndex = -1

    var progessBlock: ((_ currentIndex: Int, _ progress: CGFloat) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(trackView)
        addSubview(thumbView)

        trackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(trackHeight)
            make.centerY.equalToSuperview()
        }

        thumbView.frame = CGRect(x: self.width - self.thumbWH, y: (self.height - self.thumbWH) / 2.0, width: self.thumbWH, height: self.thumbWH)

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesAction(_:)))
        self.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGesAction(_:)))
        self.addGestureRecognizer(pan)
    }


    @objc func tapGesAction(_ tap: UITapGestureRecognizer) {

        lastIndex = -1
        handleThumbPosition(tap.location(in: self).x)
    }

    @objc func panGesAction(_ pan: UIPanGestureRecognizer) {

        if pan.state == .began {
            lastIndex = -1
        }
        if pan.state == .ended || pan.state == .changed {
            let moveX = pan.translation(in: self).x
            let centerX = pan.location(in: self).x + moveX
            pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
            handleThumbPosition(centerX)
        }
    }

    func handleThumbPosition(_ position: CGFloat) {
        var centerX = position
        let thumbWidth = self.thumbWH

        if self.maxCount < 2 {
            self.maxCount = 2
        }
        var progress = (centerX / self.frame.width)
        if (progress > 1) {
            progress = 1.0
        }

        if progress < 0 {
            progress = 0
        }
        //let partWidth = self.frame.width / CGFloat(self.maxCount - 1)
        let partIndex = Int(progress * CGFloat(self.maxCount - 1))
        //let currentOffset = CGFloat(partIndex) * partWidth


        if centerX < thumbWidth / 2.0 {
            centerX = thumbWidth / 2.0
        }

        if centerX > self.frame.width - thumbWidth / 2.0 {
            centerX = self.frame.width - thumbWidth / 2.0
        }

        self.thumbView.center = CGPoint(x: centerX, y: self.thumbView.center.y)
        if partIndex >= 0 && partIndex < self.maxCount && lastIndex != partIndex {
            lastIndex = partIndex
            self.progessBlock?(partIndex, progress)
        }
    }

    lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()

    lazy var thumbView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.thumbWH, height: self.thumbWH))
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 9
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2).cgColor

        let width = self.thumbWH - 4
        let imageView = UIImageView(frame: CGRect(x: 2, y: 2, width: width, height: width))
        imageView.backgroundColor = QMUITheme().mainThemeColor()
        imageView.layer.cornerRadius = width / 2.0
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        return view
    }()
}


