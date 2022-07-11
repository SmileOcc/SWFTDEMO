//
//  TradeInputView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class TradeInputView: UIView, YXTradeHeaderSubViewProtocol {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var isEnabled: Bool = true {
        didSet {
            inputTextField.isEnabled = isEnabled
            addBtn.isEnabled = isEnabled
            cutBtn.isEnabled = isEnabled
            
            inputTextField.attributedPlaceholder = NSAttributedString(string: customPlaceHolder ?? inputType.placeHolder, attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        }
    }
    
    func setupInput(desc: String? = nil) {
        if let desc = desc {
            isEnabled = false
            inputTextField.text = desc
        } else {
            isEnabled = true
    
            if let inputText = inputTextField.text,
               Double(inputText.replacingOccurrences(of: ",", with: "")) != nil {
                updateInput(inputText)
            } else {
                updateInput("")
            }
        }
    }
    
    var customPlaceHolder: String? {
        didSet {
            inputTextField.attributedPlaceholder = NSAttributedString(string: customPlaceHolder ?? inputType.placeHolder, attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        }
    }
    
    var addMinChange: String? {
        didSet {
//            addNumLabel.text = addMinChange
            if inputType == .price || inputType == .lowPrice {
                if addMinChange == "0.0001" {
                    inputType = .lowPrice
                    inputTextField.decimalBitCount = 4
                } else {
                    inputType = .price
                    inputTextField.decimalBitCount = 3
                }
            }
        }
    }
    
    var cutMinChange: String? {
        didSet {
//            cutNumLabel.text = cutMinChange
        }
    }
    
    var maxValue: Double?

    private(set) var input: String = "" {
        didSet {
            if oldValue != input {
                inputDidChange?(input)
            }
        }
    }
    
    private var longPressTask: DispatchQueue.Task?
    
    private(set) lazy var addBtn: UIButton = {
        let btn = operateButton()
        btn.setImage(UIImage(named: "trade_input_add"), for: .normal)
        btn.layer.cornerRadius = 2
        return btn
    }()
    
    private(set) lazy var cutBtn: UIButton = {
        let btn = operateButton()
        btn.setImage(UIImage(named: "trade_input_cut"), for: .normal)
        btn.layer.cornerRadius = 2
        return btn
    }()
    
    private(set) lazy var inputTextField: YXTextField = {
        let textField = self.inputType.textField()
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
        
        Observable.merge([textField.rx.text.asObservable(), textField.rx.observeWeakly(String.self, "text").asObservable()]).subscribe { [weak self] (_) in
            self?.input = textField.text ?? ""
        }.disposed(by: rx.disposeBag)
        
        return textField
    }()
    
    private lazy var inputBGView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
//
//    private lazy var cutNumLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = QMUITheme().textColorLevel3()
//        label.font = .systemFont(ofSize: 12)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
//        label.textAlignment = .center
//        return label
//    }()
//
//    private lazy var addNumLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = QMUITheme().textColorLevel3()
//        label.font = .systemFont(ofSize: 12)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
//        label.textAlignment = .center
//        return label
//    }()
    
    var inputDidBeginEditing: (() -> ())?
    
    private var inputType: InputType!
    private var rightMargin: Bool!
    private var inputDidChange: ((String) -> Void)?
    convenience init(inputType: InputType,
                     rightMargin: Bool = false,
                     inputDidChange: ((String) -> Void)?) {
        self.init()
        
        self.inputType = inputType
        self.rightMargin = rightMargin
        self.inputDidChange = inputDidChange
        
        setupUI()
    }
    
    private var isNewStyle = false
    
    func useNewStyle() {
        isNewStyle = true
        inputBGView.useNewStyle()
        
        inputTextField.textAlignment = .center
        
        addBtn.snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        cutBtn.snp.remakeConstraints { (make) in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        inputTextField.snp.remakeConstraints { (make) in
            make.left.equalTo(cutBtn.snp.right).offset(8)
            make.height.equalTo(28)
            make.centerY.equalToSuperview()
            make.right.equalTo(addBtn.snp.left).offset(-8)
        }

    }
    
    private func setupUI() {
        
        addSubview(inputBGView)
        addSubview(addBtn)
        addSubview(cutBtn)
//        addSubview(addNumLabel)
//        addSubview(cutNumLabel)
        addSubview(inputTextField)
        
        let rightOffset = rightMargin ? 52 : 0
        
        addBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-rightOffset)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        cutBtn.snp.makeConstraints { (make) in
            make.right.equalTo(addBtn.snp.left).offset(-24)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
//        addNumLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(addBtn.snp.bottom).offset(2)
//            make.centerX.equalTo(addBtn)
//            make.bottom.equalToSuperview()
//            make.width.equalTo(28)
//        }
//
//        cutNumLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(cutBtn.snp.bottom).offset(2)
//            make.centerX.equalTo(cutBtn)
//            make.bottom.equalToSuperview()
//            make.width.equalTo(28)
//        }
        
        
        inputBGView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalTo(cutBtn.snp.left).offset(-24)
        }
    }
}

//MARK: InputType
enum InputType: Int {
    case price
    case lowPrice
    case number
    case fractionalNumber
    case amount
}

extension InputType {
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        
        switch self {
        case .price:
            formatter.maximumFractionDigits = 3
        case .lowPrice:
            formatter.maximumFractionDigits = 4
        case .number:
            formatter.groupingSize = 3
            formatter.groupingSeparator = ","
        case .fractionalNumber:
            formatter.maximumFractionDigits = 4
            formatter.groupingSize = 3
            formatter.groupingSeparator = ","
        case .amount:
            formatter.maximumFractionDigits = 2
            formatter.groupingSize = 3
            formatter.groupingSeparator = ","
        }
        return formatter
    }
    
    func formatterString(with number: NSNumber?) -> String {
        guard let number = number else {
            return ""
        }
        
        return numberFormatter.string(from: number) ?? ""
    }
    
    var placeHolder: String {
        switch self {
        case .price,
            .lowPrice:
            return YXLanguageUtility.kLang(key: "trade_input_price")
        case .number,
             .fractionalNumber:
            return YXLanguageUtility.kLang(key: "trade_input_quantity")
        case .amount:
            return YXLanguageUtility.kLang(key: "trade_input_amount")
        }
    }
    
    func textField() -> YXTextField {
        let textFld = YXTextField()
        textFld.textColor = QMUITheme().textColorLevel1()
        textFld.keyboardType = .decimalPad
        textFld.font = .systemFont(ofSize: 16, weight: .medium)
        textFld.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        textFld.banAction = true

        switch self {
        case .price:
            textFld.inputType = .money
            textFld.integerBitCount = 7
            textFld.decimalBitCount = 3
        default:
            break
        }
        return textFld

    }
}

//MARK: Input Method
extension TradeInputView {
    func updateInput(_ number: NSNumber?, needFix:Bool = true, addMinChange: String? = nil, cutMinChange: String? = nil) {
        updateInput(inputType.formatterString(with: number), needFix: needFix, addMinChange: addMinChange, cutMinChange: cutMinChange)
    }
    
    func updateInput(_ input: String, needFix:Bool = true, addMinChange: String? = nil, cutMinChange: String? = nil) {
        if let addMinChange = addMinChange {
            self.addMinChange = addMinChange
        }
        
        if let cutMinChange = cutMinChange {
            self.cutMinChange = cutMinChange
        }
        
        if isEnabled {
            if needFix == true {
                inputTextField.text = inputFix(input)
            } else {
                inputTextField.text = input
            }
        } else {
            inputTextField.text = ""
        }

        if inputType != .price, inputType != .lowPrice {
            inputTextField.fixSelectRangeTxt()
        }
    }
    
    func inputFixIfNeed(fixUp: Bool) {
        if let cutMinChangeValue = Double(cutMinChange ?? ""),
           cutMinChangeValue > 0,
           let inputValue = Double(inputTextField.text ?? "") {
            let tempInputValue = Int64(round(inputValue * 10000))
            let tempCutMinChangeValue = Int64(round(cutMinChangeValue * 10000))
            
            if tempInputValue % tempCutMinChangeValue != 0 {
                inputTextField.text = inputFix(inputTextField.text, fixUp: fixUp)
            }
        }
    }
    
    private func inputFix(_ input: String? = nil, fixUp: Bool? = nil) -> String {
        var text = ""
        if let input = input {
            text = input
        } else {
            text = inputTextField.text ?? ""
        }

        if text.count < 1 || Double(text) == 0 {
            if fixUp != nil, let minChange = addMinChange, minChange.count > 0 {
                text = minChange
                return inputType.formatterString(with: NSNumber(value: Double(text) ?? 0))
            }
            return ""
        }
        
        guard let addMinChange = addMinChange,
              let cutMinChange = cutMinChange,
              let inputValue = Double(text.replacingOccurrences(of: ",", with: "")),
              let addMinChangeValue = Double(addMinChange),
              let cutMinChangeValue = Double(cutMinChange),
              addMinChangeValue > 0,
              cutMinChangeValue > 0,
              inputValue > 0 else {
            return text
        }
        
        let tempInput = Int64(round(inputValue * 10000.0))
        let tempCutMinChange = Int64(round(cutMinChangeValue * 10000.0))
        
        if tempInput % tempCutMinChange != 0 {
            var newValue = floor(inputValue / cutMinChangeValue) * cutMinChangeValue
            if let fixUp = fixUp, fixUp == true {
                newValue = ceil(inputValue / cutMinChangeValue) * cutMinChangeValue
            }
            
            if newValue > 0, newValue <= maxValue ?? Double.greatestFiniteMagnitude {
                return inputType.formatterString(with: NSNumber(value: newValue))
            } else if let max = maxValue, newValue > max {
                return inputType.formatterString(with: NSNumber(value: max))
            }
        } else {
            if let fixUp = fixUp {
                var newValue = inputValue - cutMinChangeValue
                if fixUp == true {
                    newValue = inputValue + addMinChangeValue
                } else {
                    if inputType == .price || inputType == .lowPrice {
                        if cutMinChange == "0.0001" {
                            inputType = .lowPrice
                            inputTextField.decimalBitCount = 4
                        } else {
                            inputType = .price
                            inputTextField.decimalBitCount = 3
                        }
                    }
                }
                if newValue > 0, newValue <= maxValue ?? Double.greatestFiniteMagnitude {
                    return inputType.formatterString(with: NSNumber(value: newValue))
                } else if let max = maxValue, newValue > max {
                    return inputType.formatterString(with: NSNumber(value: max))
                }
            }
        }
        return text
    }
    
    func resetMinChange(_ minChange: String? = nil) {
        addMinChange = minChange
        cutMinChange = minChange
    }
    
    func setupMinChange() {
        updateInput(cutMinChange ?? "")
    }
}

//MARK: Action
extension TradeInputView {
    private func operateButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = QMUITheme().blockColor()
        btn.setBackgroundImage( UIImage.qmui_image(with:QMUITheme().textColorLevel1().withAlphaComponent(0.1), size: CGSize(width: 24, height: 24), cornerRadius: 2), for: .highlighted)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longPress.minimumPressDuration = 1.0
        btn.addGestureRecognizer(longPress)
        btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc private func longPressAction(_ sender: UIGestureRecognizer) {
        guard addMinChange != nil else { return }
        guard cutMinChange != nil else { return }

        inputDidBeginEditing?()
        
        func endLongPress() {
            DispatchQueue.cancel(longPressTask)
        }
        
        func startLongPress(_ isAdd: Bool) {
            longPressTask = DispatchQueue.delay(0.05) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.inputTextField.text = strongSelf.inputFix(fixUp: isAdd)
                if strongSelf.inputType != .price, strongSelf.inputType != .lowPrice {
                    strongSelf.inputTextField.fixSelectRangeTxt()
                }
                strongSelf.shakeAction()
                startLongPress(isAdd)
            }
        }

        if sender.state == .began {
            if sender.view == addBtn {
                startLongPress(true)
            } else{
                startLongPress(false)
            }
        } else if sender.state == .ended {
            endLongPress()
        }
    }
    
    @objc private func clickAction(_ sender: UIButton) {
        guard addMinChange != nil else { return }
        guard cutMinChange != nil else { return }
        
        inputDidBeginEditing?()
        
        if sender == addBtn {
            inputTextField.text = inputFix(fixUp: true)
        } else {
            inputTextField.text = inputFix(fixUp: false)
        }
        if inputType != .price, inputType != .price {
            inputTextField.fixSelectRangeTxt()
        }
        shakeAction()
    }
    
    private func shakeAction() {
        let impactLight: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactLight.impactOccurred()
    }
}

//MARK: TextFieldDelegate
extension TradeInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if inputType != .price, inputType != .lowPrice {
            var checkStr = textField.text
            let rag = checkStr?.toRange(range)
            checkStr = checkStr?.replacingCharacters(in: rag!, with: string)
            checkStr = checkStr?.replacingOccurrences(of: ",", with: "")

            
            if checkStr == "" {
                textField.openMicrometerLevelFormat()
                return true
            }
            
            var regex = "^([1-9]\\d{0,9})$"
            if inputType == .number {
                if checkStr == "0" {
                    return false
                }
            } else if inputType == .fractionalNumber {
                regex = "^([1-9]\\d{0,6}|0)(\\.\\d{0,4})?$"
            } else if inputType == .amount {
                regex = "^([1-9]\\d{0,6}|0)(\\.\\d{0,2})?$"
            }
            let t = self.isValid(checkStr: checkStr ?? "", regex: regex)
            if !t {
                return false
            }
           
            textField.openMicrometerLevelFormat()
            
            return true
        }
        return (textField as? YXTextField)?.textField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? false
    }
    
    private func isValid(checkStr:String , regex:String) -> Bool {
        let predicte = NSPredicate(format: "SELF MATCHES %@",regex)
        return predicte.evaluate(with:checkStr)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputBGView.isSelect = true
        
        inputDidBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.inputBGView.isSelect = false
    }
}

extension YXTextField {
    
    func fixSelectRangeTxt() {
        reformat(asMicrometerLevel: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.setSelectedRange(NSRange(location: (self.text?.count ?? 0), length: 0))
            self.configSelectedRange()
        }
    }
}
