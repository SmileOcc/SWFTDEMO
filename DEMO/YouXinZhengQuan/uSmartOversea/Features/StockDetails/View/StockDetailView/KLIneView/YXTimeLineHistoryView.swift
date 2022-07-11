//
//  YXTimeLineHistoryView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

class YXTimeLineHistoryView: UIView {

    @objc enum TimeLineDirection: Int {
        case pre
        case next
    }

    @objc var queryTimeLineDataBlock: ((_ model: YXKLine, _ isLeftDirection: Bool) -> Void)?

    @objc var closeClosure: (() -> Void)?

    @objc var longPressStateBlock: ((_ isEnded: Bool) -> Void)?

    @objc var quote: YXV2Quote? {
        didSet {
            if let type1 = quote?.type1?.value, type1 == OBJECT_SECUSecuType1.stIndex.rawValue {

                topInfoView.isIndexStock = true
                if self.quote?.market == kYXMarketHK {
                    timeLineView.isIndexStock = true
                }
            }

            if let quoteModel = quote, YXStockDetailTool.isGemStock(quoteModel) {
                self.timeLineView.isGem = true
            }
        }
    }

    @objc var klineData: YXKLineData? {
        didSet {
            updateButtonEnabled()
        }
    }

    @objc var singleKLine: YXKLine? {
        didSet {
            topToolBar.kline = singleKLine
            topInfoView.kline = singleKLine

            timeLineView.cleanData()
        }
    }

    @objc var queryIndex: Int = -1 {
        didSet {
            updateButtonEnabled()
        }
    }

    @objc var timeLineData: YXTimeLineData? {
        didSet {
            timeLineView.timeLineModel = timeLineData
            timeLineView.reload()
        }
    }

    func updateButtonEnabled() {
        if let lineData = self.klineData, let list = lineData.list, queryIndex < list.count {

            if queryIndex == list.count - 1 {
                self.topToolBar.nextButton.isEnabled = false
                self.topToolBar.preButton.isEnabled = true
            } else if queryIndex == 0 {
                self.topToolBar.preButton.isEnabled = false
                self.topToolBar.nextButton.isEnabled = true
            } else {
                self.topToolBar.nextButton.isEnabled = true
                self.topToolBar.preButton.isEnabled = true
            }

            if list.count == 1 {
                self.topToolBar.nextButton.isEnabled = false
                self.topToolBar.preButton.isEnabled = false
            }
        }
    }

    var isLongPressBegin = false
    let timelineHeight: CGFloat = 160
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        handleBlock()

        self.backgroundColor = QMUITheme().foregroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(topToolBar)
        addSubview(topInfoView)
        addSubview(timeLineView)
        addSubview(timeLineLongPressView)

        topToolBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }

        topInfoView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topToolBar.snp.bottom)
            make.height.equalTo(33)
        }

        timeLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
            make.height.equalTo(timelineHeight)
        }
        timeLineView.reload()

        timeLineLongPressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topToolBar.snp.bottom)
        }
    }

    func handleBlock() {
        timeLineView.timeLineLongPressStartCallBack = {
            [weak self] model in
            guard let `self` = self else { return }
            if self.quote?.type1?.value == OBJECT_SECUSecuType1.stIndex.rawValue {

                if self.quote?.market == kYXMarketHK {
                    self.timeLineLongPressView.hiddenVolume()
                } else if self.quote?.market == kYXMarketUS {
                    self.timeLineLongPressView.hiddenAmount()
                }
            }

            if (!self.isLongPressBegin) {
                self.isLongPressBegin = true
                self.longPressStateBlock?(false)
            }

            self.timeLineLongPressView.isHidden = false
            if let timeModel = model {
                self.timeLineLongPressView.timeSignalModel = timeModel
            }
        }

        timeLineView.timeLineLongPressEndCallBack = {
            [weak self] in
            guard let `self` = self else { return }

            self.timeLineLongPressView.isHidden = true
            self.isLongPressBegin = false
            self.longPressStateBlock?(true)
        }


        topToolBar.closeClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.closeClosure?()
        }

        topToolBar.showPreOrNextClosure = {
            [weak self] direction in
            guard let `self` = self else { return }

            let index = (direction == .pre) ? (self.queryIndex - 1) : (self.queryIndex + 1);

            if let lineData = self.klineData, let list = lineData.list, index < list.count {

                self.queryIndex = index
                let klineData = list[index]
                self.singleKLine = klineData
                self.queryTimeLineDataBlock?(klineData, direction == .pre)
            }
        }

    }

    lazy var topToolBar: YXTimeLineHistoryToolBar = {
        let view = YXTimeLineHistoryToolBar()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var topInfoView: YXTimeLineHistoryTopInfoView = {
        let view = YXTimeLineHistoryTopInfoView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return view
    }()

    lazy var timeLineView: YXTimeLineView  = {
        let view = YXTimeLineView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: timelineHeight))
        view.chartType = .history;
        return view
    }()

    lazy var timeLineLongPressView: YXTimeLineLongPressView = {
        let view = YXTimeLineLongPressView(frame: .zero, andType: .portrait)
        view.isHidden = true
        return view
    }()
}

class YXTimeLineHistoryToolBar: UIView {

    @objc var showPreOrNextClosure: ((_ direction: YXTimeLineHistoryView.TimeLineDirection) -> Void)?

    @objc var closeClosure: (() -> Void)?

    @objc var kline: YXKLine? {
        didSet {

            if let value = kline?.latestTime?.value, value > 0 {
                self.titleLabel.text = YXDateHelper.commonDateStringWithNumber(value, showWeek: true)
            } else {
                self.titleLabel.text = "--"
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
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(nextButton)
        addSubview(preButton)

        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-6)
            make.width.height.equalTo(15)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(150.0 * YXConstant.screenWidth / 375.0)
        }

        nextButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        preButton.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel.snp.left)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        closeButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.closeClosure?()

        }).disposed(by: rx.disposeBag)

        nextButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.showPreOrNextClosure?(.next)

        }).disposed(by: rx.disposeBag)

        preButton.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.showPreOrNextClosure?(.pre)

        }).disposed(by: rx.disposeBag)
    }

    lazy var preButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10

        let image = UIImage(named: "yx_v2_small_arrow")
        button.setImage(image?.qmui_image(withAlpha: 0.4), for: .disabled)
        button.setImage(image?.qmui_image(withTintColor: QMUITheme().themeTextColor()), for: .normal)
        return button
    }()

    lazy var nextButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        let image = UIImage(named: "mine_arrow")
        button.setImage(image?.qmui_image(withAlpha: 0.4), for: .disabled)
        let normalImage = image?.qmui_image(withTintColor: QMUITheme().themeTextColor())
        button.setImage(normalImage, for: .normal)

        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()


    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.setImage(UIImage(named: "yx_v2_small_close3"), for: .normal)
        return button
    }()


}

class YXTimeLineHistoryTopInfoView: UIView {

    class YXTimeLineHistoryTopSubTitleView: UIView {
        var alignment: NSTextAlignment = .left
        init(frame: CGRect, alignment: NSTextAlignment) {
            super.init(frame: frame)
            self.alignment = alignment
            initUI()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        let margin = 40.0 * YXConstant.screenWidth / 375.0

        func initUI() {
            addSubview(leftLabel)
            addSubview(rightLabel)

            if alignment == .left {
                leftLabel.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                }

                rightLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(leftLabel.snp.right).offset(margin)
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview()
                }
            } else {

                rightLabel.snp.makeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.centerY.equalToSuperview()
                }

                leftLabel.snp.makeConstraints { (make) in
                    make.right.equalTo(rightLabel.snp.left).offset(-margin)
                    make.centerY.equalToSuperview()
                    make.left.equalToSuperview()
                }
            }
        }

        lazy var leftLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.textColor = QMUITheme().textColorLevel3()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = self.alignment
            return label
        }()

        lazy var rightLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.textColor = QMUITheme().textColorLevel1()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = self.alignment
            label.text = "--"
            return label
        }()
    }


    //MARK: ---------
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc var isIndexStock = false {
        didSet {
            if isIndexStock {
                rightView.leftLabel.text = YXLanguageUtility.kLang(key: "market_amount")
            } else {
                rightView.leftLabel.text = YXLanguageUtility.kLang(key: "market_volume")
            }
        }
    }

    @objc var kline: YXKLine? {
        didSet {
            leftView.rightLabel.text = YXToolUtility.stockPriceData(Double(kline?.avg?.value ?? 0), deciPoint: Int(kline?.priceBase?.value ?? 0), priceBase: Int(kline?.priceBase?.value ?? 0))
            leftView.rightLabel.textColor = YXToolUtility.stockColor(withData: Double(kline?.avg?.value ?? 0), compareData: Double(kline?.preClose?.value ?? 0))

            if isIndexStock {
                rightView.rightLabel.text = YXToolUtility.stockData(Double(kline?.amount?.value ?? 0), deciPoint: 2, stockUnit: "", priceBase: Int(kline?.priceBase?.value ?? 0))
            } else {
                rightView.rightLabel.text = YXToolUtility.stockData(Double(kline?.volume?.value ?? 0), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
            }

        }
    }

    func initUI() {
        addSubview(leftView)
        addSubview(rightView)

        leftView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
        }

        rightView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview()
        }
    }

    lazy var leftView: YXTimeLineHistoryTopSubTitleView = {
        let view = YXTimeLineHistoryTopSubTitleView(frame: .zero, alignment: .left)
        view.leftLabel.text = YXLanguageUtility.kLang(key: "stock_detail_average_price")
        return view
    }()

    lazy var rightView: YXTimeLineHistoryTopSubTitleView = {
        let view = YXTimeLineHistoryTopSubTitleView(frame: .zero, alignment: .right)

        view.leftLabel.text = YXLanguageUtility.kLang(key: "market_volume")
        return view
    }()
}

