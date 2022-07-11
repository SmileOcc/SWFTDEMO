//
//  YXStockAnalyzeBrokerHoldingsView.swift
//  uSmartOversea
//
//  Created by 裴艳东 on 2020/2/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import SnapKit

class YXStockAnalyzeBrokerHoldingsView: YXStockAnalyzeBaseView {

    @objc var tabClickBlock: ((_ type: Int) -> Void)?
    @objc var clickBlock: ((_ params: [String: Any]) -> Void)?
    @objc var arrowClickBlock: ((_ params: [String: Any]) -> Void)?

    var selectIndex: Int = 0

    @objc var model: YXStockAnalyzeBrokerListModel? {
        didSet {
            tradeView.model = model
        }

    }

    @objc var holdingModel: YXStockAnalyzeBrokerListModel? {
        didSet {
            holdingView.model = holdingModel
        }

    }

    @objc func updateLevel(_ level: QuoteLevel) {
        if level != self.level {
            self.level = level

            self.tradeView.updateLevel(level)
        }
    }


    var level: QuoteLevel = .delay
    @objc init(frame: CGRect = .zero, level: QuoteLevel) {
        super.init(frame: frame)
        self.level = level
        initUI()
        handleBlock()
        var brokerDic: [String : Any] = [:]
        if let data = MMKV.default().data(forKey: "hk_brokerListPath"), let tempDic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let dic = tempDic as? [String : Any] {
            if let arr = dic["broker_list"] as? [[String : Any]] {

                var languageKey = "simplified_abb_name"
                //泰语、马来语先用英文
                if YXUserManager.isENMode() {
                    languageKey = "english_abb_name"
                } else if YXUserManager.curLanguage() == .HK {
                    languageKey = "traditional_abb_name"
                }

                for localDic in arr {
                    if let localId = localDic["participant_id"] as? String {
                        let iid = localId.replacingOccurrences(of: " ", with: "")
                        let name = (localDic[languageKey] as? String) ?? ""
                        let idArray = iid.components(separatedBy: ",")
                        for idString in idArray {
                            if !idString.isEmpty {
                                brokerDic.updateValue(name, forKey: idString)
                            }
                        }
                    }

                    if let localId = localDic["participant_id_settle"] as? String {
                        let iid = localId.replacingOccurrences(of: " ", with: "")
                        let name = (localDic[languageKey] as? String) ?? ""
                        let idArray = iid.components(separatedBy: ",")
                        for idString in idArray {
                            if !idString.isEmpty {
                                brokerDic.updateValue(name, forKey: idString)
                            }
                        }
                    }
                }
            }
        }
        tradeView.brokerDic = brokerDic
        holdingView.brokerDic = brokerDic
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleBlock() {

        holdingView.clickBlock = {
            [weak self] param in
            guard let `self` = self else { return }
            self.clickBlock?(param)
        }

        tradeView.tabClickBlock = {
            [weak self] type in
            guard let `self` = self else { return }
            self.tabClickBlock?(type)
        }

        tradeView.clickBlock = {
            [weak self] param in
            guard let `self` = self else { return }
            self.clickBlock?(param)
        }
    }

//    var tradeBottomConstraint: Constraint? = nil
//    var holdingBottomConstraint: Constraint? = nil
    func initUI() {

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        addSubview(promptButton)
        promptButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.width.height.equalTo(16)
        }

        addSubview(arrowButton)
        arrowButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(16)
        }

        addSubview(tapButtonView)
        tapButtonView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }

        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(tapButtonView.snp.bottom)
            make.bottom.equalToSuperview()
        }

        scrollView.addSubview(tradeView)
        scrollView.addSubview(holdingView)
        tradeView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
//            tradeBottomConstraint = make.bottom.equalTo(self).constraint
        }

        holdingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
            make.left.equalTo(tradeView.snp.right)
            make.right.equalToSuperview()
//            holdingBottomConstraint = make.bottom.equalTo(self).constraint
        }

//        tradeBottomConstraint?.activate()
//        holdingBottomConstraint?.deactivate()

    }


    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "broker_stock")
        return label
    }()

    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func promptButtonAction() {
        let alertView = YXAlertView(message: "")
        alertView.clickedAutoHide = true
        alertView.addCustomView(self.customView)
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }

    lazy var arrowButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.expandX = 10
        button.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func arrowButtonAction() {

        self.arrowClickBlock?(["tabIndex" : self.selectIndex,
                               "timeIndex" : self.tradeView.selectIndex,
                               "brokerDic" : self.tradeView.brokerDic])
    }

    lazy var tapButtonView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXLanguageUtility.kLang(key: "broker_buy_sell"), YXLanguageUtility.kLang(key: "broker_percent")])
        view.tapAction = { [weak self] index in
            guard let `self` = self else { return }

            self.selectIndex = index
            if index == 0 {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//                self.tradeBottomConstraint?.activate()
//                self.holdingBottomConstraint?.deactivate()
                self.contentHeight = 460
            }else {
                self.scrollView.setContentOffset(CGPoint(x: YXConstant.screenWidth, y: 0), animated: true)
//                self.tradeBottomConstraint?.deactivate()
//                self.holdingBottomConstraint?.activate()
                self.contentHeight = 440
            }
        }
        return view
    }()

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = false
        view.bounces = false
        view.delaysContentTouches = false
        return view
    }()

    lazy var tradeView: YXStockAnalyzeTradeView = {
        let view = YXStockAnalyzeTradeView(frame: .zero, level: self.level)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var holdingView: YXStockAnalyzeShareHoldingView = {
        let view = YXStockAnalyzeShareHoldingView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var customView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 260, height: 160)
        let topTitleLabel = UILabel()
        topTitleLabel.textColor = QMUITheme().textColorLevel1()
        topTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        topTitleLabel.textAlignment = .left
        topTitleLabel.text = YXLanguageUtility.kLang(key: "broker_buy_sell")
        view.addSubview(topTitleLabel)

        let topMessageLabel = UILabel()
        topMessageLabel.numberOfLines = 0
        topMessageLabel.textColor = QMUITheme().textColorLevel3()
        topMessageLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        topMessageLabel.textAlignment = .left
        topMessageLabel.text = YXLanguageUtility.kLang(key: "stock_broker_sell_buy_tip")
        view.addSubview(topMessageLabel)

        topTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(-10)
        }

        topMessageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topTitleLabel.snp.bottom).offset(5)
        }

        let bottomTitleLabel = UILabel()
        bottomTitleLabel.textColor = QMUITheme().textColorLevel1()
        bottomTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        bottomTitleLabel.textAlignment = .left
        bottomTitleLabel.text = YXLanguageUtility.kLang(key: "broker_percent")
        view.addSubview(bottomTitleLabel)

        let bottomMessageLabel = UILabel()
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.textColor = QMUITheme().textColorLevel3()
        bottomMessageLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bottomMessageLabel.textAlignment = .left
        bottomMessageLabel.text = YXLanguageUtility.kLang(key: "stock_broker_percent_tip")
        view.addSubview(bottomMessageLabel)

        bottomTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(topMessageLabel.snp.bottom).offset(20)
        }

        bottomMessageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(bottomTitleLabel.snp.bottom).offset(5)
        }
        return view
    }()

}

