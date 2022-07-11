//
//  YXCYQView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXCYQView: UIView {

    var loginClosure: (() -> Void)?
    var upgradeClosure: (() -> Void)?
    var reloadDataClosure: (() -> Void)?
    @objc var clickDetailBlock: (() -> Void)?

    var singleTapClosure: (() -> Void)?
    var doubleTapClosure: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isLand: Bool = false {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
            if isLand {
                tap.numberOfTapsRequired = 2
            }
            self.addGestureRecognizer(tap)
        }
    }

    @objc var market = kYXMarketHK {
        didSet {
            if market == kYXMarketChinaSZ || market == kYXMarketChinaSH {
                emptyView.isHidden = true
            }
        }
    }

    var level: QuoteLevel = .bmp {
        didSet {
            if YXUserManager.isLogin() || market == kYXMarketChinaSZ || market == kYXMarketChinaSH {
                if level == .delay {
                    emptyView.isHidden = false
                    emptyView.type = .upgrade
                } else {
                    emptyView.isHidden = true
                }
            }
        }
    }

    var model: YXCYQModel? {
        didSet {
            if (YXUserManager.isLogin() || market == kYXMarketChinaSZ || market == kYXMarketChinaSH), level != .delay {
                refreshUI()
            }
        }
    }

    func refreshUI() {

        if let model = model {
            if model.list?.isEmpty ?? true {
                emptyView.isHidden = false
                emptyView.type = .noData
            } else {
                emptyView.isHidden = true
                detailView.model = model
                chartView.priceBase = model.priceBase
                chartView.model = model.list?.first
            }
        } else {
            //网络错误
            emptyView.isHidden = false
            emptyView.type = .netWorkError
        }
    }

    func tapGestureAction() {
        if self.isLand {
            self.doubleTapClosure?()
        } else {
            self.singleTapClosure?()
        }
    }
    
    var isFullChart = false {
        didSet {
            if oldValue != isFullChart {
                updateChartViewHeight()
            }
        }
    }

    let kDetailViewHeight: CGFloat = 118
    
    private var topPadding: CGFloat = 0
    
    private var chartHeight: CGFloat {
        
        if isFullChart {
            return self.frame.height - 22 - 44 - 10
        } else {
            return (self.frame.height - 44) * 0.6
        }
        
    }
    
    lazy var scrollerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()

        addSubview(titleLabel)
        addSubview(scrollerView)
        addSubview(emptyView)
        
        scrollerView.addSubview(chartView)
        scrollerView.addSubview(detailView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-5)
        }
        
        scrollerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(22)
            make.width.equalTo(self.frame.width)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalToSuperview().offset(topPadding)
            make.height.equalTo(self.chartHeight)
        }

        detailView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.top.equalTo(chartView.snp.bottom)
            make.height.equalTo(self.kDetailViewHeight)
        }
        
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let leftLineView = UIView()
        leftLineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(leftLineView)
        leftLineView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(0.5)
        }

        if !YXUserManager.isLogin() {
            emptyView.isHidden = false
            emptyView.type = .unLogin
        }
        
        scrollerView.contentSize = CGSize.init(width: self.frame.width, height: chartHeight + kDetailViewHeight + 10)
    }
    
    /// 大小更改的时候触发
    func updateChartViewHeight() {
        
        chartView.snp.updateConstraints { make in
            make.height.equalTo(self.chartHeight)
        }
        chartView.mj_h = self.chartHeight
        chartView.refreshUI()
        scrollerView.contentSize = CGSize.init(width: self.frame.width, height: chartHeight + kDetailViewHeight + 10)
    }

    lazy var chartView: YXCYQChartView = {
        let view = YXCYQChartView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.chartHeight))

        return view
    }()

    lazy var detailView: YXCYQDetailView = {
        let view = YXCYQDetailView()
        view.clickDetailBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.clickDetailBlock?()
        }

        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "chips")
        return label
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
        view.reloadDataClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.reloadDataClosure?()
        }
        return view
    }()
}


class YXCYQEmptyView: UIView {

    @objc var loginClosure: (() -> Void)?
    @objc var upgradeClosure: (() -> Void)?
    @objc var reloadDataClosure: (() -> Void)?

    @objc enum YXCYQType: Int {
        case unLogin  //未登录
        case upgrade  //延时权限升级
        case noData   //暂无数据
        case netWorkError //网络错误
    }

    var type: YXCYQType = .noData {
        didSet {
            if self.type == .noData {
                promptLabel.text = YXLanguageUtility.kLang(key: "common_no_data")
                promptButton.isHidden = true
            } else {
                promptButton.isHidden = false
                if self.type == .unLogin {
                    promptButton.setTitle(YXLanguageUtility.kLang(key: "mine_account_login_reg"), for: .normal)
                    promptLabel.text = YXLanguageUtility.kLang(key: "delay_no_chips")
                    promptLabel.textAlignment = .left
                } else if self.type == .upgrade {
                    promptButton.setTitle(YXLanguageUtility.kLang(key: "common_upgrade"), for: .normal)
                    promptLabel.text = YXLanguageUtility.kLang(key: "delay_no_chips")
                    promptLabel.textAlignment = .left

                } else if self.type == .netWorkError {
                    promptButton.setTitle(YXLanguageUtility.kLang(key: "common_click_refresh"), for: .normal)
                    promptLabel.text = YXLanguageUtility.kLang(key: "common_load_fail")
                    promptLabel.textAlignment = .center
                }
                promptButton.setNeedsDisplay()
                promptButton.layoutIfNeeded()
            }
        }
    }

    var centerYOffset: CGFloat = 0 {
        didSet {
            promptLabel.snp.updateConstraints { (make) in
                make.centerY.equalToSuperview().offset(centerYOffset)
            }
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = QMUITheme().foregroundColor()
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(-10)
        }

        addSubview(promptButton)
        promptButton.snp.makeConstraints { (make) in
            make.top.equalTo(promptLabel.snp.bottom).offset(24)
            make.height.equalTo(48)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    lazy var promptButton: QMUIButton = {
        let button = QMUIButton()
        button.isHidden = true
        button.layer.cornerRadius = 4.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = QMUITheme().themeTextColor().cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        button.titleLabel?.numberOfLines = 2
        return button
    }()

    @objc func promptButtonAction() {
        if self.type == .unLogin {
            self.loginClosure?()
        } else if self.type == .upgrade {
            self.upgradeClosure?()
        } else if self.type == .netWorkError {
            self.reloadDataClosure?()
        }
    }
}



