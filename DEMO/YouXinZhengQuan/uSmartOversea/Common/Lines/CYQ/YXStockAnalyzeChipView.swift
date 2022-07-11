//
//  YXStockAnalyzeChipView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockAnalyzeChipView: YXStockAnalyzeBaseView {

    @objc var chipDetailBlock: (() -> Void)?
    @objc var chipExplainBlock: (() -> Void)?

    @objc var loginClosure: (() -> Void)?
    @objc var upgradeClosure: (() -> Void)?

    @objc var level: QuoteLevel = .bmp {
        didSet {
            if YXUserManager.isLogin() {
                if level == .delay {
                    emptyView.isHidden = false
                    emptyView.type = .upgrade
                } else {
                    emptyView.isHidden = true
                }
            }
        }
    }

    @objc func chipDetailAction() {

        if emptyView.isHidden == false {

            if emptyView.type == .unLogin {
                self.loginClosure?()
            } else {
                self.upgradeClosure?()
            }
            return
        }

        self.chipDetailBlock?()
    }

    @objc var model: YXCYQModel? {
        didSet {

            refreshUI()
        }
    }

    func refreshUI() {
        if let model = model, let info = model.list?.first {

            let priceBase = model.priceBase == 0 ? 1 : model.priceBase

            if info.winnerRate > 0 {
                winRateView.topLabel.text = String(format: "%.2f%%", Double(info.winnerRate) / 100.0)
            } else {
                winRateView.topLabel.text = "--"
            }

            if info.avgCost > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.avgCost), deciPoint: priceBase, priceBase: priceBase)
                averageView.topLabel.text = value
            } else {
                averageView.topLabel.text = "--"
            }

            if info.supPosition > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.supPosition), deciPoint: priceBase, priceBase: priceBase)
                supportView.topLabel.text = value
            } else {
                supportView.topLabel.text = "--"
            }

            if info.pressPosition > 0 {
                let value = YXToolUtility.stockPriceData(Double(info.pressPosition), deciPoint: priceBase, priceBase: priceBase)
                resistanceView.topLabel.text = value
            } else {
                resistanceView.topLabel.text = "--"
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

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }

        addSubview(promptButton)
        promptButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(2)
            make.width.height.equalTo(16)
        }

        addSubview(smartAnalyzeButton)
        smartAnalyzeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }

        addSubview(winRateView)
        addSubview(averageView)
        addSubview(supportView)
        addSubview(resistanceView)

        let margin: CGFloat = 20
        let width: CGFloat = (YXConstant.screenWidth - 32 - margin) / 2.0
        winRateView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(61)
            make.width.equalTo(width)
        }

        averageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(winRateView)
            make.height.equalTo(61)
            make.width.equalTo(width)
        }

        supportView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(winRateView.snp.bottom)
            make.height.equalTo(61)
            make.width.equalTo(width)
        }

        resistanceView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(winRateView.snp.bottom)
            make.height.equalTo(61)
            make.width.equalTo(width)
        }

        addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }

        if !YXUserManager.isLogin() {
            emptyView.isHidden = false
            emptyView.type = .unLogin
        }

        let tapGes = UITapGestureRecognizer(target: self, action: #selector(chipDetailAction))
        self.addGestureRecognizer(tapGes)
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "chips_title")
        return label
    }()


    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func promptButtonAction() {
        self.chipExplainBlock?()
    }

    lazy var smartAnalyzeButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.isUserInteractionEnabled = false
        //button.addTarget(self, action: #selector(chipDetailAction), for: .touchUpInside)
        return button
    }()

    lazy var winRateView: YXStockAnalyzeChipSubView = {
        let view = YXStockAnalyzeChipSubView(frame: .zero, alignment: .left)
        view.bottomLabel.text = YXLanguageUtility.kLang(key: "profit_ratio")
        return view
    }()

    lazy var averageView: YXStockAnalyzeChipSubView = {
        let view = YXStockAnalyzeChipSubView(frame: .zero, alignment: .left)
        view.bottomLabel.text = YXLanguageUtility.kLang(key: "average_cost")
        return view
    }()

    lazy var supportView: YXStockAnalyzeChipSubView = {
        let view = YXStockAnalyzeChipSubView(frame: .zero, alignment: .left)
        view.bottomLabel.text = YXLanguageUtility.kLang(key: "support_level")
        return view
    }()

    lazy var resistanceView: YXStockAnalyzeChipSubView = {
        let view = YXStockAnalyzeChipSubView(frame: .zero, alignment: .left)
        view.bottomLabel.text = YXLanguageUtility.kLang(key: "pressure_level")
        return view
    }()

    lazy var emptyView: YXCYQEmptyView = {
        let view = YXCYQEmptyView()
        view.isHidden = true
        view.centerYOffset = -40
        view.loginClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.loginClosure?()
        }
        view.upgradeClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.upgradeClosure?()
        }
        return view
    }()
}

class YXStockAnalyzeChipSubView: UIView {

    init(frame: CGRect, alignment: NSTextAlignment) {
        super.init(frame: frame)
        initUI()
        topLabel.textAlignment = alignment
        bottomLabel.textAlignment = alignment
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(topLabel)
        addSubview(bottomLabel)
        topLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
        }

        bottomLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(14)
            make.top.equalTo(topLabel.snp.bottom).offset(4)
        }
    }

    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
}

