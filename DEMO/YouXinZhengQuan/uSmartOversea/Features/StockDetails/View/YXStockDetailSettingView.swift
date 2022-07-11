//
//  YXStockDetailSettingView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

enum YXStockDetailSettingCategory {
    case rehabilitation
    case lineStyle
    case kLineSet
    
    var settingItems: [YXStockDetailSettingType] {
        switch self {
        case .rehabilitation:
            return [.noRehabilitation, .complexbeforeright, .complexbackright]
        case .lineStyle:
            return [.solid, .hollow, .usa]
        case .kLineSet:
            return [.price, .fiveDayIntra] //.cost, .tradPoint
        }
    }
    
    var title: String {
        switch self {
        case .rehabilitation:
            return YXLanguageUtility.kLang(key: "stock_detail_adjust_type")
        case .lineStyle:
            return YXLanguageUtility.kLang(key: "kline_style")
        case .kLineSet:
            return YXLanguageUtility.kLang(key: "kline_set")
        }
    }
}

enum YXStockDetailSettingType {
    case landScape
    case chip
    case chartCompare
    case indexSetting
    
    case noRehabilitation // 不复权
    case complexbeforeright // 前复权
    case complexbackright // 后复权
    
    case solid // 实心阳烛
    case hollow // 空心阳烛
    case usa // 美国线
    
    case price // 现价线
    case cost // 持仓成本线
    case tradPoint // 成交买卖点
    case actionPoint // 公司行动点
    case fiveDayIntra // 5日分时盘中
    
    var title: String {
        switch self {
        case .landScape:
            return YXLanguageUtility.kLang(key: "full_screen")
        case .chip:
            return YXLanguageUtility.kLang(key: "chips")
        case .chartCompare:
            return YXLanguageUtility.kLang(key: "klinevs_title")
        case .indexSetting:
            return YXLanguageUtility.kLang(key: "indicator_settings")
            
        case .noRehabilitation:
            return YXLanguageUtility.kLang(key: "stock_detail_adjusted_none")
        case .complexbeforeright:
            return YXLanguageUtility.kLang(key: "stock_detail_adjusted_forward")
        case .complexbackright:
            return YXLanguageUtility.kLang(key: "stock_detail_adjusted_backward")
        
        case .solid:
            return YXLanguageUtility.kLang(key: "kline_style_solid_candle")
        case .hollow:
            return YXLanguageUtility.kLang(key: "kline_style_hollow_candle")
        case .usa:
            return YXLanguageUtility.kLang(key: "kline_style_ohlc")
        
        case .price:
            return YXLanguageUtility.kLang(key: "now_price_line")
        case .cost:
            return YXLanguageUtility.kLang(key: "hold_cost_price_line")
        case .tradPoint:
            return YXLanguageUtility.kLang(key: "buy_sell_point")
        case .actionPoint:
            return "公司行动点"
        case .fiveDayIntra:
            return YXLanguageUtility.kLang(key: "five_day_intra")
        }
    }
    
    var imageName: [String : String] {
        switch self {
            case .landScape:
                return ["normal": "full_screen", "selected": ""]
            case .chip:
                return ["normal": "chip_distribution", "selected": ""]
            case .chartCompare:
                return ["normal": "chart_compare", "selected": ""]
            case .indexSetting:
                return ["normal": "index_setting", "selected": ""]

            case .noRehabilitation, .complexbeforeright, .complexbackright:
                return ["normal": "unselected_new", "selected": "dot_selected"]
            case .solid:
                return ["normal": "unselected_new", "selected": "dot_selected"]
            case .hollow:
                return ["normal": "unselected_new", "selected": "dot_selected"]
            case .usa:
                return ["normal": "unselected_new", "selected": "dot_selected"]
            case .price, .cost, .tradPoint, .actionPoint, .fiveDayIntra:
                return ["normal": "noSelectStockBg", "selected": "selectStockBg"]

        }
    }
    
}

class YXStockDetailSettingView: UIView {
    var market: String = "hk"
    var shoulShowChip: Bool = false
    var tapButtons: [YXStockDetailSettingButton] = []
    var settingItemViews: [YXStockDetailSettingItemView] = []
    var tapButtonAction: ((_ tapType: YXStockDetailSettingType) -> Void)?
    var selectedAction: ((_ tapType: YXStockDetailSettingType, _ isSeledted: Bool) -> Void)?
    var setDefaultAction: (() -> Void)?
    var rotateAction: (() -> Void)?
    var hideCompleteBlock: (() -> Void)?
    
    func showSetting(hideBlock: (() -> Void)? = nil) {
        self.hideCompleteBlock = hideBlock
        tapButtons.forEach { (button) in
            button.removeFromSuperview()
        }
        settingItemViews.forEach { (button) in
            button.removeFromSuperview()
        }
        
        if shoulShowChip {
            tapButtons = [fullScreenTapButton, chipTapButton, chartCompareTapButton, indexSettingTapButton]
        }else {
            tapButtons = [fullScreenTapButton, chartCompareTapButton, indexSettingTapButton]
        }
        
        if YXKLineConfigManager.shareInstance().lineType == .dayTimeLine || YXKLineConfigManager.shareInstance().lineType == .fiveDaysTimeLine {
            settingItemViews = [kLineSetView]
        }else {
            if self.market == kYXMarketCryptos {
                settingItemViews = [lineStyleView, kLineSetView]
            } else {
                settingItemViews = [rehabilitationView, lineStyleView, kLineSetView]
            }
        }
        
        for button in tapButtons {
            containerView.addSubview(button)
        }
        
        tapButtons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
        tapButtons.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(68)
        }

        for view in settingItemViews {
            containerView.addSubview(view)
        }
        
        // 复权类型可以在k线的横屏页面更改，所以这里要同步修改UI
        for (index, button) in rehabilitationView.buttons.enumerated() {
            if YXKLineConfigManager.shareInstance().adjustType.rawValue == index {
                button.isSelected = true
            }else {
                button.isSelected = false
            }
        }

        for (index, view) in settingItemViews.enumerated() {
            view.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(96 + CGFloat((14 + 80) * index))
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(80)
                if (index == settingItemViews.count - 1) {
                    make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight() - 10)
                }
            }
        }
        
        for button in kLineSetView.buttons {
            if button.settingType == .fiveDayIntra {
                button.isSelected = YXKLineConfigManager.shareInstance().fiveDaysTimelineIntra
            }
        }

        
        let window = UIApplication.shared.keyWindow
        self.frame = window!.bounds//rootVC.view.bounds
        window!.addSubview(self)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()

        self.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: -self.containerView.bounds.size.height)
        }, completion: { (_) in

        })
    }
    
    func hideSetting(animate: Bool = false) {
        self.hideCompleteBlock?()
        if animate {
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }else {
            self.containerView.transform = CGAffineTransform.identity
            self.removeFromSuperview()
            
        }
        
    }
    
    lazy var rotateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "rotate_portrait"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.hideSetting()
            self?.rotateAction?()
        })
        return button
    }()
    
    lazy var setDefaultButton: UIButton = {
        let button = UIButton()
        // 恢复默认
        button.setTitle(YXLanguageUtility.kLang(key: "restore_default"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .right
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            let alertView = YXAlertView.init(message: YXLanguageUtility.kLang(key: "kline_setting_restore"))
            alertView.messageLabel.font = .systemFont(ofSize: 16)
            alertView.messageLabel.textAlignment = .left
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in

            }))

            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak self](action) in
                self?.setDefault()
            }))
            
            alertView.showInWindow()
        })
        
        return button
    }()
    
    func setDefault() {
        for view in self.settingItemViews {
            for button in view.buttons {
                button.isSelected = false
                switch button.settingType {
                case .complexbeforeright, .solid, .price, .cost, .tradPoint:
                    button.isSelected = true
                    self.setDefaultAction?()
                default:
                    break
                }
            }
        }
    }


    func addLineToButton(button: YXStockDetailSettingButton) {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        button.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(28)
            make.top.equalToSuperview().offset(6)
        }
    }

    lazy var fullScreenTapButton: YXStockDetailSettingButton = {
        let button = creatTapButton(type: .landScape)
//        addLineToButton(button: button)
        return button
    }()
    
    lazy var chipTapButton: YXStockDetailSettingButton = {
        let button = creatTapButton(type: .chip)
//        addLineToButton(button: button)
        return button
    }()
    
    lazy var chartCompareTapButton: YXStockDetailSettingButton = {
        let button = creatTapButton(type: .chartCompare)
//        addLineToButton(button: button)
        return button
    }()
    
    lazy var indexSettingTapButton: YXStockDetailSettingButton = {
        return creatTapButton(type: .indexSetting)
    }()
    
    lazy var rehabilitationView: YXStockDetailSettingItemView = {
        let view = YXStockDetailSettingItemView.init(settingCategory: .rehabilitation)
        view.selectedAction = self.selectedAction
        return view
    }()
    
    lazy var lineStyleView: YXStockDetailSettingItemView = {
        let view = YXStockDetailSettingItemView.init(settingCategory: .lineStyle)
        view.selectedAction = self.selectedAction
        return view
    }()
    
    lazy var kLineSetView: YXStockDetailSettingItemView = {
        let view = YXStockDetailSettingItemView.init(settingCategory: .kLineSet)
        view.selectedAction = self.selectedAction
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().popupLayerColor()
        return view
    }()
    
    func creatTapButton(type: YXStockDetailSettingType) -> YXStockDetailSettingButton {
        let button = YXStockDetailSettingButton()
        button.settingType = type
        button.setTitle(type.title, for: .normal)
        button.setImage(UIImage(named: type.imageName["normal"]!), for: .normal)
        button.spacingBetweenImageAndTitle = 7
        button.imagePosition = .top
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.backgroundColor = QMUITheme().popupLayerColor()
        button.adjustsButtonWhenHighlighted = false
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.numberOfLines = 2
        button.contentVerticalAlignment = .top
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.hideSetting()
            self?.tapButtonAction?(type)
        })
        return button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        
        let button = UIButton()
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] e in
            self?.hideSetting(animate: true)
        })
        addSubview(button)
        
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
        }
        
        button.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(
            roundedRect: self.containerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 16, height: 16))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXStockDetailSettingItemView: UIView {
    
    var selectedAction: ((_ tapType: YXStockDetailSettingType, _ isSelected: Bool) -> Void)?
    var buttons: [YXStockDetailSettingButton] = []
    
    func creatSelectButton(type: YXStockDetailSettingType) -> YXStockDetailSettingButton {
        let button = YXStockDetailSettingButton()
        button.settingType = type
        button.setTitle(type.title, for: .normal)
        button.setImage(UIImage(named: type.imageName["selected"]!), for: .selected)
        button.setImage(UIImage(named: type.imageName["normal"]!), for: .normal)
        button.spacingBetweenImageAndTitle = 4
        button.imagePosition = .left
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.titleLabel?.numberOfLines = 2
        return button
    }
    
    init(settingCategory: YXStockDetailSettingCategory) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#212129")
        layer.cornerRadius = 4
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.text = settingCategory.title
        
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
        }

        for (index, settingItem) in settingCategory.settingItems.enumerated() {
            let button = creatSelectButton(type: settingItem)

            switch settingCategory {
                case .rehabilitation:
                    if YXKLineConfigManager.shareInstance().adjustType.rawValue == index {
                        button.isSelected = true
                    }
                case .lineStyle:
                    if YXKLineConfigManager.shareInstance().styleType.rawValue == index {
                        button.isSelected = true
                    }
                case .kLineSet:
                    switch settingItem {
                        case .price:
                            button.isSelected = YXKLineConfigManager.shareInstance().showNowPrice
                        case .cost:
                            button.isSelected = YXKLineConfigManager.shareInstance().showHoldPrice
                        case .tradPoint:
                            button.isSelected = YXKLineConfigManager.shareInstance().showBuySellPoint
                        case .fiveDayIntra:
                            button.isSelected = YXKLineConfigManager.shareInstance().fiveDaysTimelineIntra
                        default:
                            break
                    }

            }

            addSubview(button)
            buttons.append(button)

            _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] in
                guard let `self` = self else { return }
                if settingCategory == .kLineSet {
                    button.isSelected = !button.isSelected
                    self.selectedAction?(settingItem, button.isSelected)

                }else {
                    if button.isSelected {
                        return
                    }
                    for btn in self.buttons {
                        btn.isSelected = false

                    }
                    button.isSelected = true

                    self.selectedAction?(settingItem, true)
                }

            })
        }
        
        var width: CGFloat = 0
        var margin: CGFloat = 0
        let height: CGFloat = 32.0
        var topMargin: CGFloat = 0.0


        width = (YXConstant.screenWidth - 24.0 - margin * 2.0 - 32.0)
        
        let scale: CGFloat = YXConstant.screenWidth / 375.0

        if settingCategory == .kLineSet {
            width = (YXConstant.screenWidth - 24.0 - margin * 2.0 - 32.0) / 2.0
        }

        for (index, button) in buttons.enumerated() {

            button.snp.makeConstraints { (make) in
                if settingCategory == .kLineSet {
                    make.width.equalTo(width)
                    make.left.equalToSuperview().offset(12 + (width + margin) * CGFloat(index % 3))
                } else {
                    if index == 0 {
                        make.width.equalTo(98 * scale)
                        make.left.equalToSuperview().offset(12)
                    } else if index == 1 {
                        make.width.equalTo(140 * scale)
                        make.left.equalToSuperview().offset(12 + 98 * scale)
                    } else {
                        make.width.equalTo(width - 98 * scale - 130 * scale)
                        make.left.equalToSuperview().offset(12 + 98 * scale + 130 * scale)
                    }
                }
                make.height.equalTo(height)
                make.top.equalTo(label.snp.bottom).offset(8 + CGFloat(index / 3) * (height + topMargin))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXStockDetailSettingButton: QMUIButton {
    var settingType: YXStockDetailSettingType!
}
