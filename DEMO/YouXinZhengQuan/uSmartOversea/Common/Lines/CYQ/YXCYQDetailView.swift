//
//  YXCYQDetailView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCYQDetailView: UIView {

    @objc var clickDetailBlock: (() -> Void)?

    var model: YXCYQModel? {
        didSet {

            refreshUI()
        }
    }

    func refreshUI() {
        if let model = model, let info = model.list?.first {

            let priceBase = model.priceBase

            if let ninetyPer = info.ninetyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0"
                let endPriceString = YXToolUtility.stockPriceData(Double(ninetyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0"
                ninetyView.rightLabel.text = beginPriceString + "-" + endPriceString
            } else {
                ninetyView.rightLabel.text = "--"
            }

            if let seventyPer = info.seventyPer {
                let beginPriceString = YXToolUtility.stockPriceData(Double(seventyPer.beginPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0"
                let endPriceString = YXToolUtility.stockPriceData(Double(seventyPer.endPrice), deciPoint: priceBase, priceBase: priceBase) ?? "0"
                seventyView.rightLabel.text = beginPriceString + "-" + endPriceString
            } else {
                seventyView.rightLabel.text = "--"
            }

            if info.chipCoincidence > 0 {
                coincidenceView.rightLabel.text = String(format: "%.2f%%", Double(info.chipCoincidence) / 100.0)
            } else {
                coincidenceView.rightLabel.text = "--"
            }

            if info.winnerRate > 0 {
                winRateView.rightLabel.text = String(format: "%.2f%%", Double(info.winnerRate) / 100.0)
            } else {
                winRateView.rightLabel.text = "--"
            }

//            if info.tradeDay > 0 {
//                let dateModel = YXDateToolUtility.dateTime(withTime: String(info.tradeDay))
//                dateView.rightLabel.text = dateModel.year + "-" + dateModel.month + "-" + dateModel.day
//            } else {
//                dateView.rightLabel.text = "--"
//            }
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

//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().textColorLevel1()
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.top.equalToSuperview()
//            make.height.equalTo(0.5)
//        }

        var stackHeight: CGFloat = 25;
        var itemHeight: CGFloat = 18;
        if YXUserManager.isENMode() {
            stackHeight = 29
            itemHeight = 17
        }
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(stackHeight)
        }

        stackView.addArrangedSubview(averageView)
        stackView.addArrangedSubview(supportView)
        stackView.addArrangedSubview(pressureView)

        addSubview(ninetyView)
        ninetyView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom)
            make.height.equalTo(itemHeight)
        }

        addSubview(seventyView)
        seventyView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(ninetyView.snp.bottom)
            make.height.equalTo(itemHeight)
        }

        addSubview(coincidenceView)
        coincidenceView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(seventyView.snp.bottom)
            make.height.equalTo(itemHeight)
        }

        addSubview(winRateView)
        winRateView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(coincidenceView.snp.bottom)
            make.height.equalTo(itemHeight)
        }

//        addSubview(dateView)
//        dateView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(coincidenceView.snp.bottom).offset(5)
//            make.height.equalTo(14)
//        }

        addSubview(detailButton)
        detailButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(3)
            make.right.equalToSuperview().offset(-3)
            make.top.equalTo(winRateView.snp.bottom)
            make.height.equalTo(18)
        }

    }

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .top
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()

    lazy var averageView: YXCYQSubTitleView = {
        let view = YXCYQSubTitleView(frame: .zero, lineColor: QMUITheme().themeTextColor())
        view.contentLabel.text = YXLanguageUtility.kLang(key: "average_cost2")
        return view
    }()

    lazy var supportView: YXCYQSubTitleView = {
        let view = YXCYQSubTitleView(frame: .zero, lineColor: UIColor.qmui_color(withHexString: "#FF6933"))
        view.contentLabel.text = YXLanguageUtility.kLang(key: "support_level2")
        return view
    }()

    lazy var pressureView: YXCYQSubTitleView = {
        let view = YXCYQSubTitleView(frame: .zero, lineColor: UIColor.qmui_color(withHexString: "#F9A800"))
        view.contentLabel.text = YXLanguageUtility.kLang(key: "pressure_level2")
        return view
    }()

    lazy var ninetyView: YXCYQSubLRView = {
        let view = YXCYQSubLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "ninety_chips")
        return view
    }()

    lazy var seventyView: YXCYQSubLRView = {
        let view = YXCYQSubLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "seventy_chips")
        return view
    }()

    lazy var coincidenceView: YXCYQSubLRView = {
        let view = YXCYQSubLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "chip_coincidence")
        return view
    }()

    lazy var winRateView: YXCYQSubLRView = {
        let view = YXCYQSubLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "profit_ratio")
        return view
    }()

    lazy var dateView: YXCYQSubLRView = {
        let view = YXCYQSubLRView()
        view.leftLabel.text = YXLanguageUtility.kLang(key: "broker_date")
        return view
    }()

    lazy var detailButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "see_detail"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
//        button.imagePosition = .right
//        button.spacingBetweenImageAndTitle = 2
//        button.setImage(UIImage(named: "chip_arrow"), for: .normal)
        button.addTarget(self, action: #selector(detailButtonAction), for: .touchUpInside)
        button.layer.borderColor = QMUITheme().pointColor().cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 2.0

        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        return button
    }()

    @objc func detailButtonAction() {
        self.clickDetailBlock?()
    }

}


class YXCYQSubTitleView: UIView {

    var lineColor = UIColor.qmui_color(withHexString: "#0C9CC5")
    init(frame: CGRect, lineColor: UIColor?) {
        super.init(frame: frame)

        self.lineColor = lineColor
        initUI()
        indicatorView.backgroundColor = self.lineColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(indicatorView)
        addSubview(contentLabel)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(2.0)
        }

        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(indicatorView.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-1)
            //make.height.equalTo(11)
        }
    }

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 8, weight: .regular)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var indicatorView: UIView = {
        let view = UIView()
        return view
    }()

}


class YXCYQSubLRView: UIView {

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
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
            make.left.equalTo(leftLabel.snp.right).offset(uniHorLength(5))
        }

        leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 8, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
}
