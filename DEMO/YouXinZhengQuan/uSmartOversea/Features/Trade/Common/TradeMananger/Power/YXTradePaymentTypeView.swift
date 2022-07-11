//
//  YXTradePaymentTypeView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/11/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum TradePaymentType: Int {
    case cash         // 现金
    case margin       // 融资
    case optionBuy    // 买入
    case sell         // 卖出
}

extension TradePaymentType:EnumTextProtocol{
    var text:String{
        switch self {
        case .cash:
            return YXLanguageUtility.kLang(key: "trade_cash")
        case .margin,
             .optionBuy:
            return YXLanguageUtility.kLang(key: "trade_margin")
        case .sell:
            return YXLanguageUtility.kLang(key: "trade_maxsell")
        }
    }
}

@objc enum PaymentLevel: Int {
    case all
    case oneSecond
    case oneThird
    case oneFourth
}

extension PaymentLevel: CaseIterable {
    var denominator: Float {
        switch self {
        case .all:
            return 1
        case .oneSecond:
            return 0.5
        case .oneThird:
            return 1.0/3.0
        case .oneFourth:
            return 0.25
        }
    }
    
    var stringValue: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "trade_all")
        case .oneSecond:
            return "1/2"
        case .oneThird:
            return "1/3"
        case .oneFourth:
            return "1/4"
        }
    }
}

class YXTradePaymentTypeView: UIView, YXTradeHeaderSubViewProtocol {
    
    lazy var gridView: QMUIGridView = {
        let gridView = QMUIGridView(column: 4, rowHeight: 24)!
        gridView.frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        gridView.separatorColor = .clear
        gridView.separatorWidth = 8
        return gridView
    }()
    
    var isSmart: Bool = false
    
    var currentType:TradePaymentType = .cash
    private var paymentBlock: ((PaymentLevel) -> Void)?
    private(set) var selectView: YXSelectTypeView<TradePaymentType>!
    private var selectedBlock:((TradePaymentType) -> Void)?
    convenience init(typeArr: [TradePaymentType], isSmart: Bool = false, selected: TradePaymentType? = nil, axis: NSLayoutConstraint.Axis = .vertical, selectedBlock:((TradePaymentType) -> Void)?, paymentBlock: ((PaymentLevel) -> Void)? = nil) {
        self.init()
        
        self.isSmart = isSmart
        self.paymentBlock = paymentBlock
        self.selectedBlock = selectedBlock
        selectView = YXSelectTypeView(typeArr: typeArr, selected: selected, contentHorizontalAlignment: .left, selectedBlock: { [weak self] type in
            guard let strongSelf = self else { return }
            
            if strongSelf.currentType != type {
                strongSelf.needResetLevel = true
                strongSelf.resetLevelIfNeed()
            }
            strongSelf.currentType = type
            strongSelf.selectedBlock?(type)
        })
        
        addSubview(selectView)
        addSubview(gridView)
        
        PaymentLevel.allCases.forEach { level in
            let btn = QMUIButton()
            btn.setTitle(level.stringValue, for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14)
            btn.setTitleColor(QMUITheme().mainThemeColor(), for: .selected)
            var color = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
            if YXThemeTool.isDarkMode() {
                color = QMUITheme().mainThemeColor().withAlphaComponent(0.2)
            }
            
            if isSmart {
                btn.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().mainThemeColor(), size: CGSize(width: 44, height: 24), lineWidth: 0.5, cornerRadius: 2), for: .selected)
                btn.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().popSeparatorLineColor(), size: CGSize(width: 44, height: 24), lineWidth: 0.5, cornerRadius: 2), for: .normal)
            } else {
                btn.setBackgroundImage(UIImage.qmui_image(with: color, size: CGSize(width: 48, height: 24), cornerRadius: 2), for: .selected)
                btn.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().blockColor(), size: CGSize(width: 48, height: 24), cornerRadius: 2), for: .normal)
            }
            
            gridView.addSubview(btn)
        
            btn.qmui_tapBlock = { [weak self] sender in
                self?.gridView.subviews.forEach{ ($0 as? UIButton)?.isSelected = false }
            
                sender?.isSelected = true
                self?.paymentBlock?(level)
            }
        }
                        
        if axis == .horizontal {
            selectView.inputBGView.lineView.isHidden = true

            if isSmart {
                selectView.snp.makeConstraints { (make) in
                    make.top.equalTo(14)
                    make.left.equalToSuperview().offset(16)
                    make.width.equalTo(80)
                    make.height.equalTo(24)
                }
                
                gridView.snp.makeConstraints { make in
                    make.top.equalTo(14)
                    make.right.equalToSuperview().offset(-16)
                    make.width.equalTo(210)
                    make.height.equalTo(24)
                }

                contentHeight = 52
            } else {
                selectView.snp.makeConstraints { (make) in
                    make.top.equalTo(16)
                    make.left.equalToSuperview().offset(16)
                    make.width.equalTo(80)
                    make.height.equalTo(24)
                }
                
                gridView.snp.makeConstraints { make in
                    make.top.equalTo(16)
                    make.right.equalToSuperview().offset(-16)
                    make.width.equalTo(210)
                    make.height.equalTo(24)
                }

                contentHeight = 40
            }
        } else {
            
            selectView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(44)
            }
            
            gridView.snp.makeConstraints { make in
                make.top.equalTo(selectView.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(24)
            }
            
            contentHeight = 84
        }
    }
    
    func updateType(_ typeArr: [TradePaymentType]? = nil, selected: TradePaymentType? = nil) {
        selectView.updateType(typeArr, selected: selected)
    }
    

    private var needResetLevel = true
    
    func setCannotResetLevel() {
        needResetLevel = false
    }
    
    func resetLevelIfNeed() {
        if needResetLevel {
            gridView.subviews.forEach{ ($0 as? UIButton)?.isSelected = false }
        } else {
            needResetLevel = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var color = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
        if YXThemeTool.isDarkMode() {
            color = QMUITheme().mainThemeColor().withAlphaComponent(0.2)
        }
        
        gridView.subviews.forEach { subview in
            if let button = subview as? UIButton {
                if isSmart {
                    button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().mainThemeColor(), size: CGSize(width: 44, height: 24), lineWidth: 1.0/UIScreen.main.scale, cornerRadius: 2), for: .selected)
                    button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().popSeparatorLineColor(), size: CGSize(width: 44, height: 24), lineWidth: 1.0/UIScreen.main.scale, cornerRadius: 2), for: .normal)
                } else {
                    button.setBackgroundImage(UIImage.qmui_image(with: color, size: CGSize(width: 48, height: 24), cornerRadius: 2), for: .selected)
                    button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().blockColor(), size: CGSize(width: 48, height: 24), cornerRadius: 2), for: .normal)
                }
            }
        }
    }
}
