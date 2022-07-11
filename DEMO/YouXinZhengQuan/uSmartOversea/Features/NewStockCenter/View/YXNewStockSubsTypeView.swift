//
//  YXNewStockSubsTypeView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXNewStockSubsTypeView: UIView {
    
    typealias SubsTypeBlock = () -> Void
    
    var publicBlock: SubsTypeBlock?
    var internalBlock: SubsTypeBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("YXNewStockSubsTypeView init error")
    }
    
   
    func refreshUI(subsType: YXNewStockEcmType, isModify: Bool) {
        
        switch subsType {
        case .onlyPublic:
            singleTypeLabel.text = YXLanguageUtility.kLang(key: "newStock_public_subscription")
            singleTypeDetailLabel.text = YXLanguageUtility.kLang(key: "newStock_unsupported_internal_subs")
        case .onlyInternal:
            singleTypeLabel.text = YXLanguageUtility.kLang(key: "newStock_internal_placement")
            singleTypeDetailLabel.text = ""
        case .bothButInternalEnd:
            singleTypeLabel.text = YXLanguageUtility.kLang(key: "newStock_public_subscription")
            singleTypeDetailLabel.text = YXLanguageUtility.kLang(key: "newStock_ipo_ecm_ended")
        case .both:
            break
        }
        
        if isModify {
            singleTypeDetailLabel.text = ""
        }
        
        if subsType == .both {
            singleTypeLabel.isHidden = true
            singleTypeDetailLabel.isHidden = true
            publicButton.isHidden = false
            internalButton.isHidden = false
            titleRightConstraint?.activate()
            
        } else {
            singleTypeLabel.isHidden = false
            singleTypeDetailLabel.isHidden = false
            publicButton.isHidden = true
            internalButton.isHidden = true
            titleRightConstraint?.deactivate()
        }
    }
    
    @objc func publicButtonAction() {
        publicButton.isSelected = true
        internalButton.isSelected = false
        resetButtonColor()
        publicBlock?()
    }
    
    @objc func internalButtonAction() {
        publicButton.isSelected = false
        internalButton.isSelected = true
        resetButtonColor()
        internalBlock?()
    }
    
    func resetButtonColor() {
     
        setButtonColor(publicButton, isSelected: publicButton.isSelected)
        setButtonColor(internalButton, isSelected: internalButton.isSelected)
    }
    
    func setButtonColor(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.layer.borderColor = QMUITheme().themeTextColor().cgColor            
            button.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.05)
        } else {
            button.layer.borderColor = QMUITheme().separatorLineColor().cgColor
            button.backgroundColor = QMUITheme().foregroundColor()
        }
    }
    
    var titleRightConstraint: Constraint?
    func initializeView() {
        
        addSubview(publicButton)
        addSubview(internalButton)
        internalButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(13)
            make.width.equalTo(uniHorLength(110))
        }
        
        publicButton.snp.makeConstraints { (make) in
            make.right.equalTo(internalButton.snp.left).offset(-10)
            make.height.equalTo(40)
            make.top.equalTo(internalButton.snp.top)
            make.width.equalTo(uniHorLength(110))
        }
        
        addSubview(singleTypeLabel)
        addSubview(singleTypeDetailLabel)
        singleTypeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(22)
        }
        
        singleTypeDetailLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(singleTypeLabel.snp.bottom).offset(10)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(24)
            titleRightConstraint = make.right.lessThanOrEqualTo(publicButton.snp.left).offset(-5).priorityHigh().constraint
            make.right.lessThanOrEqualTo(singleTypeLabel.snp.left).offset(-5).priorityMedium()
        }
        
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 16.0
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_subs_type")
        return label
    }()
    
    
    lazy var publicButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_public_subscription"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 10.0 / 14.0
        button.layer.cornerRadius = 2
        button.layer.borderWidth = 1.0
        self.setButtonColor(button, isSelected: true)
        button.addTarget(self, action: #selector(publicButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var internalButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_internal_placement"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 10.0 / 14.0
        button.layer.cornerRadius = 2
        button.layer.borderWidth = 1.0
        self.setButtonColor(button, isSelected: false)
        button.addTarget(self, action: #selector(internalButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var singleTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().themeTextColor()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    lazy var singleTypeDetailLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12.0
        label.textAlignment = .right
        return label
    }()
}


class YXNewStockPurchaseTypeView: UIView {
    
    typealias SubsTypeBlock = () -> Void
    
    var cashBlock: SubsTypeBlock?
    var financeBlock: SubsTypeBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("YXNewStockSubsTypeView init error")
    }
    
    enum SubsType {
        case cash
        case finance
        case cashAndFinance
    }
    
    
    //applyType : 0-仅支持现金认购， 1-仅支持融资认购， 2-支持现金和融资认购
    func refreshUI(applyType: SubsType) {
        
        if applyType == .cashAndFinance  {
            singleTypeLabel.isHidden = true
            cashButton.isHidden = false
            financeButton.isHidden = false
            titleRightConstraint?.activate()
        } else  {
            singleTypeLabel.isHidden = false
            cashButton.isHidden = true
            financeButton.isHidden = true
            titleRightConstraint?.deactivate()
            
            if applyType == .cash  {
                singleTypeLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_cash")
            } else {
                singleTypeLabel.text = YXLanguageUtility.kLang(key: "newStock_finance_purchase")
            }
        }
    }
    
    @objc func cashButtonAction() {
        cashButton.isSelected = true
        financeButton.isSelected = false
        cashBlock?()
    }
    
    @objc func financeButtonAction() {
        cashButton.isSelected = false
        financeButton.isSelected = true
        financeBlock?()
    }
    
    var titleRightConstraint: Constraint?
    func initializeView() {
        
        addSubview(cashButton)
        addSubview(financeButton)
        financeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        cashButton.snp.makeConstraints { (make) in
            make.right.equalTo(financeButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        addSubview(singleTypeLabel)
        singleTypeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            titleRightConstraint = make.right.lessThanOrEqualTo(cashButton.snp.left).offset(-5).priorityHigh().constraint
            make.right.lessThanOrEqualTo(singleTypeLabel.snp.left).offset(-5).priorityMedium()
        }

    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 16.0
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "newStock_purchase_type")
        return label
    }()
    
    
    lazy var cashButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_purchase_cash"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setImage(UIImage(named: "settings_nochoose"), for: .normal)
        button.setImage(UIImage(named: "settings_choose"), for: .selected)
        button.spacingBetweenImageAndTitle = 10.0
        button.addTarget(self, action: #selector(cashButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var financeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_finance_purchase"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setImage(UIImage(named: "settings_nochoose"), for: .normal)
        button.setImage(UIImage(named: "settings_choose"), for: .selected)
        button.spacingBetweenImageAndTitle = 10.0
        button.addTarget(self, action: #selector(financeButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var singleTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().themeTextColor()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
}
