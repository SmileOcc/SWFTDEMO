//
//  YXStockFilterRangeInputView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

enum YXStockFilterInputCheck {
    case valid(lowValue: Double, upValue: Double)
    case inValid(msg: String)
    
    var tipText: String {
        switch self {
        case .valid:
            return ""
        case .inValid(let msg):
            return msg
        }
    }
}

enum YXUnitType {
    case none
    // 万
    case tenThousand
    // 亿
    case hundredMillion
    // 千
    case thousand
    // 百万
    case million
    // 十亿
    case billion
    
    var text: String {
        switch self {
        case .none:
            return ""
        case .tenThousand:
            return YXLanguageUtility.kLang(key: "stock_detail_ten_thousand")
        case .hundredMillion:
            return YXLanguageUtility.kLang(key: "common_billion")
        case .thousand:
            return "K"
        case .million:
            return "M"
        case .billion:
            return "B"
        }
    }
    
    func realValue(value: Double) -> Double {
        switch self {
        case .none:
            return value
        case .tenThousand:
            return value * 10000.0
        case .hundredMillion:
            return value * 100000000.0
        case .thousand:
            return value * 1000.0
        case .million:
            return value * 1000000.0
        case .billion:
            return value * 1000000000.0
        }
    }
    
    func unitValue(value: Double) -> String {
        switch self {
        case .none:
            return "\(value)"
        case .tenThousand:
            return String(format: "%.2lf", value/10000.0)
        case .hundredMillion:
            return String(format: "%.2lf", value/100000000.0)
        case .thousand:
            return String(format: "%.2lf", value/1000.0)
        case .million:
            return String(format: "%.2lf", value/1000000.0)
        case .billion:
            return String(format: "%.2lf", value/1000000000.0)
        }
    }
}

enum YXStockFilterUnitType {
    // 无单位
    case noUnit
    // 百分比
    case percent
    // 数量
    case count(unit: YXUnitType)
    
    var text: String {
        switch self {
        case .noUnit:
            return ""
        case .percent:
            return "%"
        case .count(let unit):
            return unit.text
        }
    }
    
    func realValue(value: Double) -> Double {
        switch self {
        case .noUnit:
            return value
        case .percent:
            return value/100.0
        case .count(let unit):
            return unit.realValue(value: value)
        
        }
    }
    
    func unitValue(value: Double) -> String {
        switch self {
        case .noUnit:
            return "\(value)"
        case .percent:
            return String(format: "%.2lf", value*100.0)
        case .count(let unit):
            return unit.unitValue(value: value)
        }
    }
}

class YXStockFilterRangeInputView: UIView, QMUITextFieldDelegate {
    
    let moneyPredicte = NSPredicate(format: "SELF MATCHES %@", "^-{0,1}[0-9]*((\\.|,)[0-9]{0,2})?$")
    let quantityPredicte = NSPredicate(format: "SELF MATCHES %@", String(format: "^([1-9]\\d{0,%ld}|0)$", 12))
    var predicte: NSPredicate?
    
    var customInputCachDic: [String: YXStokFilterListItem]?
    
    // 限制的上下限
    var maxValue: Double = 0.0
    var minValue: Double = 0.0
    
    // 上下限特殊标识，如果用户未输入最大或者最小值，就默认填充此最大最小值
    let minFlag: Double = -9999999999999999.0
    let maxFlag: Double = 9999999999999999.0
    
    var validInputRangeTip: String {
        
        return YXLanguageUtility.kLang(key: "enter_valid_value") + unitType.unitValue(value: minValue) + unitType.text + "~" + unitType.unitValue(value: maxValue) + unitType.text
    }
    
    var unitType: YXStockFilterUnitType {
        switch (filterItem?.unitType ?? 0) {
        case 0:
            return .noUnit
        case 1:
            return .percent
        case 2:
            let max = fabs(maxValue)
            if YXUserManager.isENMode() {
                if max >= 1000.0, max < 10000.0 {
                    return .count(unit: .thousand)
                }else if max >= 10000.0, max < 1000000.0 {
                    return .count(unit: .million)
                }else if max >= 1000000.0 {
                    return .count(unit: .billion)
                }else {
                    return .count(unit: .none)
                }
            }else {
                if max >= 10000.0, max < 100000000.0 {
                    return .count(unit: .tenThousand)
                }else if max >= 100000000.0 {
                    return .count(unit: .hundredMillion)
                }else {
                    return .count(unit: .none)
                }
            }
            
        default:
            return .noUnit
        }
    }
    
    var filterItem: YXStockFilterItem? {
        didSet {
            if let item = filterItem {
                
                var customItem: YXStokFilterListItem?
                
                for itemList in item.queryValueList {
                    for item in itemList.list {
                        if item.key == "custom" {
                            customItem = item
                            break
                        }
                    }
                }
                
                // 如果有缓存取缓存里的
                if let cacheCustomItem = customInputCachDic?[item.key ?? ""] {
                    // 曾经输入过
                    self.minValue = cacheCustomItem.min
                    self.maxValue = cacheCustomItem.max
                    
                }else {
                    // 第一次输入
                    self.minValue = customItem?.min ?? 0.0
                    self.maxValue = customItem?.max ?? 0.0
                }
                
                // 填充值
                self.initTextFieldValue(withFilterItem: item)
                
                let unitType = self.unitType
                titleLabel.text = item.name
                uinitLabel1.text = unitType.text
                uinitLabel2.text = unitType.text
                tipLabel.text = nil
            }
        }
    }
    
    var sureAction: ((_ actionType: YXStockFilterActionType) -> Void)?
    
    lazy var sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            switch self.isValidInput() {
            case .valid(let lowValue, let upValue):
                self.textFieldResignFirstResponder()
                if let item = self.filterItem {
                    let unitType = self.unitType
                    var showText: String
                    if lowValue <= self.minFlag {
                        showText = "<=" + unitType.unitValue(value: upValue) + unitType.text
                    }else if upValue >= self.maxFlag {
                        showText = ">=" + unitType.unitValue(value: lowValue) + unitType.text
                    }else {
                        showText = unitType.unitValue(value: lowValue) + unitType.text + "~" + unitType.unitValue(value: upValue) + unitType.text
                    }
                    self.sureAction?(.customInput(item: item, lowValue: lowValue, upValue: upValue, showText: showText))
                }
                
                self.tipLabel.text = nil
            
            case .inValid(let msg):
                self.tipLabel.text = msg
            }
            
        })
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ad_close"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.textFieldResignFirstResponder()
        })
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var customLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "history_custom_date")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.qmui_color(withHexString: "#FF7127")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var lowTextField: QMUITextField = {
        let textField = self.creatTextField()
        textField.addSubview(self.uinitLabel1)
        self.uinitLabel1.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-3)
        }
        return textField
    }()
    
    lazy var upTextField: QMUITextField = {
        let textField = self.creatTextField()
        textField.addSubview(self.uinitLabel2)
        self.uinitLabel2.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-3)
        }
        return textField
    }()
    
    lazy var uinitLabel1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var uinitLabel2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    func creatTextField() -> QMUITextField {
        let textField = QMUITextField()
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.keyboardType = .numbersAndPunctuation
        textField.qmui_keyboardWillChangeFrameNotificationBlock = { [weak self](keyboardUserInfo) in
            guard let `self` = self else { return }
            QMUIKeyboardManager.handleKeyboardNotification(with: keyboardUserInfo, show: { (info) in
                if let keyBorardInfo = info {
                    self.showWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }) { (info) in
                if let keyBorardInfo = info {
                    self.hideWithKeyBoardUserInfo(info: keyBorardInfo)
                }
            }
        }
        
        return textField
    }
    
    func initTextFieldValue(withFilterItem item: YXStockFilterItem) {
        lowTextField.text = nil
        upTextField.text = nil
        
        for itemList in item.queryValueList {
            for item in itemList.list {
                if item.isSelected, item.key == "custom" {
                    if item.min <= minFlag {
                        lowTextField.text = nil
                    }else {
                        lowTextField.text = unitType.unitValue(value: item.min)
                    }
                    
                    if item.max >= maxFlag {
                        upTextField.text = nil
                    }else {
                        upTextField.text = unitType.unitValue(value: item.max)
                    }
                    
                    break
                }
            }
        }
    }
    
    func isValidInput() -> YXStockFilterInputCheck {
        let lowText = lowTextField.text ?? ""
        let upText = upTextField.text ?? ""
        
        // 输入的值是单位值，比如单位是万，则输入1是1万，但是服务端接收的值是10000
        let lowValue = Double(lowText) ?? 0.0
        let upValue = Double(upText) ?? 0.0
        // 这里根据单位转换成原始值，比如1万，转成10000
        var realLowValue = unitType.realValue(value: lowValue)
        var realUpValue = unitType.realValue(value: upValue)
        
        // 如果用户没有输入，则默认取特殊最小值
        if lowText.count == 0 {
            realLowValue = minFlag
        }
        // 如果用户没输入，则默认取特殊最大值
        if upText.count == 0 {
            realUpValue = maxFlag
        }
        
        if lowText.count == 0, upText.count == 0 {
            // 都不输入
            return .inValid(msg: validInputRangeTip)
        }else if realLowValue > realUpValue {
            return .inValid(msg: validInputRangeTip)
        }else if (realLowValue > minFlag && realLowValue < minValue) || (realUpValue < maxFlag && realUpValue > maxValue) {
            // 输入的最小值小于服务端限定的最小值 或者 输入的最大值大于服务端限定的最大值
            return .inValid(msg: validInputRangeTip)
        }
        
        return .valid(lowValue: realLowValue, upValue: realUpValue)
    }
    
    func showWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = false
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            if let view = self.superview {
                let distanceFromBottom = QMUIKeyboardManager.distanceFromMinYToBottom(in: view, keyboardRect: info.endFrame)
                self.containerView.layer.transform = CATransform3DMakeTranslation(0, (-distanceFromBottom - self.containerView.frame.size.height), 0)
            }
        }, completion: nil)
    }
    
    func hideWithKeyBoardUserInfo(info: QMUIKeyboardUserInfo) {
        self.isHidden = true
        QMUIKeyboardManager.animateWith(animated: true, keyboardUserInfo: info, animations: {
            self.containerView.layer.transform = CATransform3DIdentity
        }, completion: { (finish) in
            
        })
    }
    
    func textFieldResignFirstResponder() {
        if lowTextField.isFirstResponder {
            lowTextField.resignFirstResponder()
        }else if upTextField.isFirstResponder {
            upTextField.resignFirstResponder()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        predicte = moneyPredicte
        self.isHidden = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)//QMUITheme().foregroundColor()
        
        let grayView = UIView()
        grayView.backgroundColor = QMUITheme().backgroundColor()
        
        grayView.addSubview(cancelButton)
        grayView.addSubview(titleLabel)
        grayView.addSubview(sureButton)
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        sureButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        let line = UIView()
        line.backgroundColor = QMUITheme().textColorLevel1()
        
        containerView.addSubview(grayView)
        containerView.addSubview(customLabel)
        containerView.addSubview(lowTextField)
        containerView.addSubview(line)
        containerView.addSubview(upTextField)
        containerView.addSubview(tipLabel)
        
        addSubview(containerView)
        
        grayView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        customLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(grayView.snp.bottom).offset(35)
            make.right.equalTo(lowTextField.snp.left).offset(-3)
        }
        
        lowTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(customLabel)
            make.width.height.equalTo(upTextField)
        }
        
        line.snp.makeConstraints { (make) in
            make.right.equalTo(upTextField.snp.left).offset(-13)
            make.left.equalTo(lowTextField.snp.right).offset(13)
            make.centerY.equalTo(lowTextField)
            make.height.equalTo(2)
            make.width.equalTo(14)
        }
        
        upTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(lowTextField)
            make.width.equalTo(130)
            make.height.equalTo(40)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(lowTextField.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-5)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(140)
            make.top.equalTo(self.snp.bottom)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXStockFilterRangeInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var checkStr = textField.text
        
        let rag = checkStr?.toRange(range)
        checkStr = checkStr?.replacingCharacters(in: rag!, with: string)
        if checkStr?.isEmpty ?? true {//checkStr?.count == 0
            return true
        }
        
        let isCan = predicte?.evaluate(with: checkStr ?? "") ?? true
        
        if isCan {
            tipLabel.text = nil
        }
        
        return isCan
    }
}
