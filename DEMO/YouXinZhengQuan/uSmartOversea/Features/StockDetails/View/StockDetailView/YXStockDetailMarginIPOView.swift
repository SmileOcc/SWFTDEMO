//
//  YXStockDetailMarginIPOView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailMarginIPOView: YXStockDetailBaseView {


    var mortgageRatio: Double = 0.0 {
        didSet {

            rateLabel.text = String(format: YXLanguageUtility.kLang(key: "financing_mortgage_rate"), mortgageRatio * 100)
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
        addSubview(logoLabel)
//        addSubview(supportLabel)
        addSubview(rateLabel)

        logoLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(18)
            make.height.equalTo(16)
        }

//        supportLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(logoLabel.snp.right).offset(6)
//        }

        rateLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(logoLabel.snp.right).offset(6)
            //make.right.equalToSuperview().offset(-18)
        }
        rateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        addSubview(tipButton)
        tipButton.snp.makeConstraints { (make) in
            make.left.equalTo(rateLabel.snp.right).offset(5)
            make.centerY.equalTo(rateLabel)
            make.width.height.equalTo(12)
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    lazy var logoLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "financial_logo_title")
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.white
        label.backgroundColor = QMUITheme().tipsColor()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textAlignment = .center
        //label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return label
    }()

    lazy var supportLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "support_financing_buy")
        return label
    }()

    lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()//QMUITheme().tipsColor() 
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = String(format: YXLanguageUtility.kLang(key: "financing_mortgage_rate"), 0.00)
        return label
    }()

    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.setImage(UIImage(named: "stock_about"), for: .highlighted)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func tipButtonAction() {
        let alertView = YXAlertView(title: nil, message: YXLanguageUtility.kLang(key: "financing_mortgage_toast"), prompt: nil, style: .default, messageAlignment: .left)
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in

        }))

        alertView.showInWindow()
    }

}


class YXStockDetailStockValueView: UIView {

    var tapBlock: (() -> Void)?

    var model: YXStockValueModel? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let valueModel = model {

            if let permission = valueModel.permissionFlag, permission == true,
                let rate = valueModel.info?.valueStatus?.rateOfReturnEstimate {
                returnRateLabel.text = YXLanguageUtility.kLang(key: "expected_returnRate") + String(format: "%.02f%%", rate * 100)
            } else {
                returnRateLabel.text = YXLanguageUtility.kLang(key: "expected_returnRate") + String(format: "**.**%%")
            }

            if let statusString = valueModel.info?.valueStatus?.status {
                if statusString == "under" {
                    statusLabel.text = YXLanguageUtility.kLang(key: "valuation_under")
                    healthView.backgroundColor = UIColor.qmui_color(withHexString: "#84C241")
                }  else if statusString == "over" {
                    statusLabel.text = YXLanguageUtility.kLang(key: "valuation_over")
                    healthView.backgroundColor = UIColor.qmui_color(withHexString: "#ED1B26")
                } else {
                    //"fair"
                    statusLabel.text = YXLanguageUtility.kLang(key: "valuation_fair")
                    healthView.backgroundColor = UIColor.qmui_color(withHexString: "#FEDC85")
                }
            }

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.tapBlock?()
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(tipButton)
        addSubview(valuationLabel)
        addSubview(statusLabel)
        addSubview(healthView)
        addSubview(returnRateLabel)

        tipButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        valuationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tipButton.snp.right).offset(3)
            make.centerY.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(valuationLabel.snp.right)
        }
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        healthView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
            make.left.equalTo(statusLabel.snp.right).offset(5)
            make.right.lessThanOrEqualTo(returnRateLabel.snp.left).offset(-5)
        }

        returnRateLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-18)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.setImage(UIImage(named: "stock_about"), for: .highlighted)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        return button
    }()

    lazy var valuationLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "value_state") + ":" + " "
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = "--"
        return label
    }()

    lazy var healthView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#84C241")
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    lazy var returnRateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "expected_returnRate") + String(format: "**.**%%")
        return label
    }()

    @objc func tipButtonAction() {
        let alertView = YXAlertView(message: "")
        alertView.clickedAutoHide = true
        alertView.addCustomView(self.customView)
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    lazy var customView: UIView = {
        let view = UIView()
        var height: CGFloat = 170
        if YXUserManager.isENMode() {
            height = 250
        }
        view.frame = CGRect(x: 0, y: 0, width: 260, height: height)
        let topTitleLabel = UILabel()
        topTitleLabel.textColor = UIColor.qmui_color(withHexString: "#191919")
        topTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        topTitleLabel.textAlignment = .left
        topTitleLabel.text = YXLanguageUtility.kLang(key: "valuation_status_title")
        view.addSubview(topTitleLabel)

        let topMessageLabel = UILabel()
        topMessageLabel.numberOfLines = 0
        topMessageLabel.textColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65)
        topMessageLabel.font = UIFont.systemFont(ofSize: 12)
        topMessageLabel.textAlignment = .left
        topMessageLabel.text = YXLanguageUtility.kLang(key: "valuation_under_note")
        view.addSubview(topMessageLabel)

        let topMessageLabel2 = UILabel()
        topMessageLabel2.numberOfLines = 0
        topMessageLabel2.textColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65)
        topMessageLabel2.font = UIFont.systemFont(ofSize: 12)
        topMessageLabel2.textAlignment = .left
        topMessageLabel2.text = YXLanguageUtility.kLang(key: "valuation_fair_note")
        view.addSubview(topMessageLabel2)


        let topMessageLabel3 = UILabel()
        topMessageLabel3.numberOfLines = 0
        topMessageLabel3.textColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65)
        topMessageLabel3.font = UIFont.systemFont(ofSize: 12)
        topMessageLabel3.textAlignment = .left
        topMessageLabel3.text = YXLanguageUtility.kLang(key: "valuation_over_note")
        view.addSubview(topMessageLabel3)

        topTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(-15)
        }

        topMessageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topTitleLabel.snp.bottom).offset(5)
        }

        topMessageLabel2.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topMessageLabel.snp.bottom).offset(5)
        }

        topMessageLabel3.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topMessageLabel2.snp.bottom).offset(5)
        }

        let bottomTitleLabel = UILabel()
        bottomTitleLabel.textColor = UIColor.qmui_color(withHexString: "#191919")
        bottomTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        bottomTitleLabel.textAlignment = .left
        bottomTitleLabel.text = YXLanguageUtility.kLang(key: "expect_rate_title")
        view.addSubview(bottomTitleLabel)

        let bottomMessageLabel = UILabel()
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.textColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65)
        bottomMessageLabel.font = UIFont.systemFont(ofSize: 12)
        bottomMessageLabel.textAlignment = .left
        bottomMessageLabel.text = YXLanguageUtility.kLang(key: "expect_rate_note")
        view.addSubview(bottomMessageLabel)

        bottomTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topMessageLabel3.snp.bottom).offset(20)
        }

        bottomMessageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(bottomTitleLabel.snp.bottom).offset(5)
        }
        return view
    }()
}


class YXStockDetailTechnicalInsightView: UIView, YXCycleScrollViewDelegate {

    var tapBlock: ((_ canJump: Bool) -> Void)?
    var closeBlock: (() -> Void)?

    var model: YXStockTechnicalModel? {
        didSet {
            refreshUI()
        }
    }

    var titlesArray: [String] = []
    var statusNames: [String] = []
    var colorsArray: [UIColor] = []

    func refreshUI() {
        if let valueModel = model {
            titlesArray.removeAll()
            statusNames.removeAll()
            colorsArray.removeAll()

            if let signRankList = valueModel.signRankList {
                for info in signRankList {
                    let title = (info.eventTypeName ?? "")
                    titlesArray.append(title)

                    var forcaseString = YXLanguageUtility.kLang(key: "forecase_up")
                    var color = QMUITheme().stockRedColor()
                    if let tradeType = info.tradeType, tradeType.lowercased() == "s" {

                        //S - 看跌， L - 看涨
                        forcaseString = YXLanguageUtility.kLang(key: "forecase_down")
                        color = QMUITheme().stockGreenColor()
                    }

                    var termString = YXLanguageUtility.kLang(key: "short_term")
                    //枚举值 S：短期 I：中期 L：长期
                    if let tempTerm = info.tradingHorizon?.lowercased() {
                        if tempTerm == "l" {
                            termString = YXLanguageUtility.kLang(key: "long_term")
                        } else if tempTerm == "i" {
                            termString = YXLanguageUtility.kLang(key: "mid_term")
                        }
                    }

                    statusNames.append(termString + forcaseString)
                    colorsArray.append(color)
                }
            }

            self.cycleScrollView.imageURLStringsGroup = statusNames
            self.cycleScrollView.titlesGroup = statusNames
        }

    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            var canJump = false
            if let flag = self.model?.jumpH5Flag, flag == true {
                canJump = true
            }
            self.tapBlock?(canJump)
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(logoImageView)
        addSubview(closeButton)
        addSubview(cycleScrollView)
        addSubview(titleLabel)

        logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
            make.left.equalToSuperview().offset(18)
        }

        closeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(logoImageView.snp.right).offset(2)
        }

        cycleScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(closeButton.snp.left).offset(-2)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }


    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "technical_insight")
        return imageView
    }()

    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_detail_close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func closeButtonAction() {
        self.closeBlock?()
    }


    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "morphological_insight") + ": "
        return label
    }()

    lazy var cycleScrollView: YXCycleScrollView = {
        let title = YXLanguageUtility.kLang(key: "morphological_insight") + ": "
        let width = (title as NSString).boundingRect(with: CGSize(width: 300, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).width
        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 36 - 36 - width, height: 34))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self;
        scrollView.titleLabelBackgroundColor = .clear
        scrollView.titleLabelTextColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        scrollView.titleLabelTextFont = .systemFont(ofSize: 12)
        scrollView.titleLabelTextAlignment = .left
        scrollView.scrollDirection = .vertical
        //scrollView.onlyDisplayText = true
        //scrollView.onlyDisplayTextWithImage = true
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 3
        scrollView.disableScrollGesture()
        scrollView.isUserInteractionEnabled = false
        scrollView.pageControlStyle = YXCycleScrollViewPageContolStyleNone
        scrollView.showBackView = false

        return scrollView
    }()


    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {

    }

    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
        YXStockDetailTechnicalInsightCell.self
    }

    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {
        if let cell = cell as? YXStockDetailTechnicalInsightCell {
            if index < statusNames.count {
                cell.statusLabel.text = statusNames[index]
                cell.statusLabel.textColor = colorsArray[index]
            }

            if index < titlesArray.count {
                cell.nameLabel.text = titlesArray[index]
            }
        }
    }
}

class YXStockDetailTechnicalInsightCell: YXCycleViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(5)
        }
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().stockRedColor()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
}

class YXStockDetailEventReminderView: UIView, YXCycleScrollViewDelegate {

    var tapBlock: ((_ eventId: String) -> Void)?
    var closeBlock: ((_ eventId: String, _ remainCount: Int) -> Void)?

    var model: YXStockEventReminderModel? {
        didSet {
            refreshUI()
        }
    }

    var eventContents: [String] = []
    var eventIds: [String] = []
    var currentScrollIndex = 0

    func refreshUI() {
        if let valueModel = model {
            eventContents.removeAll()
            eventIds.removeAll()

            if let noteList = valueModel.noteList {
                for info in noteList {
                    if let eventContent = info.eventContent, !eventContent.isEmpty,
                        let eventId = info.eventId, !eventId.isEmpty {
                        eventContents.append(eventContent)
                        eventIds.append(eventId)
                    }
                }
            }

            self.cycleScrollView.imageURLStringsGroup = []
            self.cycleScrollView.titlesGroup = eventContents
        }

    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            if self.currentScrollIndex < self.eventIds.count {

                self.tapBlock?(self.eventIds[self.currentScrollIndex])
            }
        }).disposed(by: rx.disposeBag)

        self.cycleScrollView.itemDidScrollOperationBlock = {
            [weak self] index in
            guard let `self` = self else { return }
            self.currentScrollIndex = index
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(logoImageView)
        addSubview(closeButton)
        addSubview(cycleScrollView)

        logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
            make.left.equalToSuperview().offset(18)
        }

        closeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        cycleScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(logoImageView.snp.right).offset(5)
            make.right.equalTo(closeButton.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }


    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "event_reminder")
        return imageView
    }()

    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_detail_close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func closeButtonAction() {

        if self.currentScrollIndex < self.eventIds.count {

            self.closeBlock?(self.eventIds[self.currentScrollIndex], self.eventIds.count - 1)
            self.eventIds.remove(at: self.currentScrollIndex)
            self.eventContents.remove(at: self.currentScrollIndex)
            self.cycleScrollView.imageURLStringsGroup = []
            self.cycleScrollView.titlesGroup = eventContents
            self.currentScrollIndex = 0
        }
    }


    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "morphological_insight") + ": "
        return label
    }()

    lazy var cycleScrollView: YXCycleScrollView = {
        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 36 - 36, height: 34))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self;
        scrollView.titleLabelBackgroundColor = .clear
        scrollView.titleLabelTextColor = QMUITheme().textColorLevel1()
        scrollView.titleLabelTextFont = .systemFont(ofSize: 12)
        scrollView.titleLabelTextAlignment = .left
        scrollView.scrollDirection = .vertical
        scrollView.onlyDisplayText = true
        scrollView.onlyDisplayTextWithImage = false
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 5
        scrollView.disableScrollGesture()
        scrollView.isUserInteractionEnabled = false
        scrollView.pageControlStyle = YXCycleScrollViewPageContolStyleNone
        scrollView.showBackView = false

        return scrollView
    }()

}



class YXStockDetailImportantNewsView: UIView, YXCycleScrollViewDelegate {

    var tapBlock: ((_ newsId: String, _ title: String) -> Void)?
    var closeBlock: (() -> Void)?

    var model: YXStockImportantNewsModel? {
        didSet {
            refreshUI()
        }
    }

    var currentScrollIndex = 0
    var ids: [String] = []
    var titlesArr: [String] = []
    func refreshUI() {
        if let valueModel = model {
            ids.removeAll()
            titlesArr.removeAll()
            if let list = valueModel.list {
                for info in list {
                    if let title = info.title, !title.isEmpty,
                        let newsId = info.news_id, !newsId.isEmpty {
                        titlesArr.append(title)
                        ids.append(newsId)
                    }
                }
            }
            self.cycleScrollView.imageURLStringsGroup = []
            self.cycleScrollView.titlesGroup = titlesArr
        }

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.rx.tapGesture().subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            if self.currentScrollIndex < self.ids.count {

                self.tapBlock?(self.ids[self.currentScrollIndex], self.titlesArr[self.currentScrollIndex])
            }
        }).disposed(by: rx.disposeBag)

        self.cycleScrollView.itemDidScrollOperationBlock = {
            [weak self] index in
            guard let `self` = self else { return }
            self.currentScrollIndex = index
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(logoImageView)
        addSubview(closeButton)
        addSubview(cycleScrollView)

        logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
            make.left.equalToSuperview().offset(16)
        }

        closeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }

        cycleScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(logoImageView.snp.right).offset(3)
            make.right.equalTo(closeButton.snp.left).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }


    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "important_news")
        return imageView
    }()

    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_detail_close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func closeButtonAction() {

        self.closeBlock?()
    }

    lazy var cycleScrollView: YXCycleScrollView = {
        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 36 - 36, height: 34))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self;
        scrollView.titleLabelBackgroundColor = .clear
        scrollView.titleLabelTextColor = QMUITheme().textColorLevel1()
        scrollView.titleLabelTextFont = .systemFont(ofSize: 12)
        scrollView.titleLabelTextAlignment = .left
        scrollView.scrollDirection = .vertical
        scrollView.onlyDisplayText = true
        scrollView.onlyDisplayTextWithImage = false
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 5
        scrollView.disableScrollGesture()
        scrollView.isUserInteractionEnabled = false
        scrollView.pageControlStyle = YXCycleScrollViewPageContolStyleNone
        scrollView.showBackView = false

        return scrollView
    }()

}

