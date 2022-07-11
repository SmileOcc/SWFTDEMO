//
//  YXTradeExchangeView.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/1/30.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXTradeExchangeView: UIView, UITextFieldDelegate {

    typealias ClosureAction = () -> Void
    typealias ClosureApplyAction = (_ amount: String) -> Void
    
    enum InOutExchangeType {
        case inExchangeType
        case outExchangeType
    }
    
    @objc var refreshClosure: ClosureAction?
    @objc var exchangeListClosure: ClosureAction?
    @objc var applyExchangeClosure: ClosureApplyAction?
    @objc var refreshData: ClosureAction?
    
    @objc var applyExchangeEvent: ClosureApplyAction?    //点击【申请兑换】的响应

    //MARK: -model
    var exchangeModel: YXCurrencyExchangeModel? {
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() {
        
        if let model = exchangeModel {
            //源
            if let sourceCurrency = model.sourceCurrency {
                if sourceCurrency.elementsEqual(YXCurrencyType.sg.requestParam) {//sg
                    sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_sg")
                }
                else if sourceCurrency.elementsEqual(YXCurrencyType.us.requestParam) {//us
                    sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_us")
                }
                else if sourceCurrency.elementsEqual(YXCurrencyType.hk.requestParam) {//hk
                    sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_hk")
                }
            }

            //目标
            if let targetCurrency = model.targetCurrency {
                if targetCurrency.elementsEqual(YXCurrencyType.sg.requestParam) {//sg
                    targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_sg")
                }
                else if targetCurrency.elementsEqual(YXCurrencyType.us.requestParam) {//us
                    targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_us")
                }
                else if targetCurrency.elementsEqual(YXCurrencyType.hk.requestParam) {//hk
                    targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_hk")
                }
            }

            
            fillModel()
        }
    }
    
    private func fillModel() {
        if let model = exchangeModel {
            //可用金额
            if let withdrawBalanceStr = model.sourceWithdrawBalance, let withdrawBalance = Double(withdrawBalanceStr) {
                let textString = moneyFormatter.string(from: NSNumber(value: withdrawBalance))
                exchangeNumLabel.text = String(format: "%@%@", textString!, sourceUnitString)
            }

            //汇率
            if let rate = model.rate {
                let exchangeRatioFormat = "%@%@=%@%@"
                let sourceAmount = model.sourceCurrency == model.baseCurrency ? "1" : rate
                let targetAmount = model.targetCurrency == model.baseCurrency ? "1" : rate
                exchangeRatioNumLable.text = String(format: exchangeRatioFormat, sourceAmount, sourceUnitString, targetAmount, targetUnitString)
            } else {
                exchangeRatioNumLable.text = "--"
            }

            currencyLabel.text = sourceUnitString
            targetLabel.text = targetUnitString
            
            if let withdrawBalanceStr = model.sourceWithdrawBalance, let value = Double(withdrawBalanceStr) {
                if value <= 0.0 {
                    applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                    applyExchangeButton.isEnabled = false
                } else {
                    if let text = currencyText.textField.text, text.count > 0 {
                        if let textDouble = Double(text), textDouble <= value, textDouble > 0 {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor()
                            applyExchangeButton.isEnabled = true
                        } else {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                            applyExchangeButton.isEnabled = false
                        }
                    } else {
                        applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                        applyExchangeButton.isEnabled = false
                    }
                }
            } else {
                applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                applyExchangeButton.isEnabled = false
            }

            if exchangeModel != nil {
                if targetText.textField.isFirstResponder {
                    initExchangeNumber(model: model,by: .inExchangeType)
                } else {
                    initExchangeNumber(model: model,by: .outExchangeType)
                }
            }
        }
    }
    
    //MARK: - textField
    @objc func soureTextChanged() {
        
        if let text = currencyText.textField.text {
            
            if text.count > 0 {
                
                if exchangeModel != nil {
                    initExchangeNumber(model: exchangeModel!,by: .outExchangeType)
                }
                
                if let withdraw = exchangeModel?.sourceWithdrawBalance,
                    let textDouble = Double(text),
                    let withdrawDouble = Double(withdraw) {
                    if textDouble <= withdrawDouble {
                        hidTipMesLabel()

                        if textDouble > 0 {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor()
                            applyExchangeButton.isEnabled = true
                        } else {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                            applyExchangeButton.isEnabled = false
                        }
                    } else {
                        showTipMesLabel(message: YXLanguageUtility.kLang(key: "exchange_exceeded_max_money"))
                        applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                        applyExchangeButton.isEnabled = false
                    }
                }
            } else {
                applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                applyExchangeButton.isEnabled = false
                targetText.textField.text = ""
            }
            
        }
    }
    
    @objc func taegetTextChanged() {
        
        if let text = targetText.textField.text {
            
            if text.count > 0 {
                
                if exchangeModel != nil {
                    initExchangeNumber(model: exchangeModel!,by: .inExchangeType)
                }
                
                if let withdraw = exchangeModel?.sourceWithdrawBalance,
                   let textDouble = Double(currencyText.textField.text ?? ""),
                    let withdrawDouble = Double(withdraw) {
                    if textDouble <= withdrawDouble {
                        hidTipMesLabel()

                        if textDouble > 0 {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor()
                            applyExchangeButton.isEnabled = true
                        } else {
                            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                            applyExchangeButton.isEnabled = false
                        }
                    } else {
                        showTipMesLabel(message: YXLanguageUtility.kLang(key: "exchange_exceeded_max_money"))
                        applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                        applyExchangeButton.isEnabled = false
                    }
                }
            } else {
                applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
                applyExchangeButton.isEnabled = false
                currencyText.textField.text = ""
            }
        }
    }
    
    //MARK: -textField delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, text.count >= 15, !string.elementsEqual("") {
            return false
        } else {
        
            if let text = textField.text, text.count > 0 {
                
                //整数12位, 小数2位
                if !text.contains("."), text.count == 12, !string.elementsEqual("."), !string.elementsEqual("") {
                    return false
                }
                
                //首数字不为0
                if text.elementsEqual("0"), !string.elementsEqual(".") {
                    textField.text = string
                    if exchangeModel != nil {
                        let type: InOutExchangeType = textField == currencyText.textField ? .outExchangeType : .inExchangeType
                        initExchangeNumber(model: exchangeModel!,by: type)
                    }
                    return false
                }
                
                //再次输入小数点
                if text.contains("."), string.elementsEqual(".") {
                    return false
                }
                
                //小数点后2位
                let index = (text as NSString).range(of: ".").location
                if (range.location - index) > 2 {
                    return false
                }
                
            } else {
                
                //首数字不为.
                if string.elementsEqual(".") {
                    return false
                }
            }
            return true
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == currencyText.textField {
            self.currencyText.isSelect = true
            self.targetText.isSelect = false
        } else if textField == targetText.textField {
            self.targetText.isSelect = true
            self.currencyText.isSelect = false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == currencyText.textField {
            self.currencyText.isSelect = false
        } else if textField == targetText.textField {
            self.targetText.isSelect = false
        }
        
    }
    
    //MARK: - 申请兑换 --- 先更新数据
    @objc func applyExchangeButtonEvent(_ button: UIButton) {
        button.isUserInteractionEnabled = false
        if let text = currencyText.textField.text, text.count > 0 {
            currencyText.textField.text = String(format: "%.2f", Double(text)! * 1.0)
        }
        if let closure = applyExchangeEvent {
            closure(currencyText.textField.text ?? "")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            button.isUserInteractionEnabled = true
        }
    }
    
    @objc func applyAmountData() -> Void {
        let withdraw = exchangeModel?.sourceWithdrawBalance
        if withdraw != nil {
            let text = currencyText.textField.text;
            if text != nil {
                if text!.count <= 0 || Double(text!)! <= 0.0 {
                    showTipMesLabel(message: YXLanguageUtility.kLang(key: "exchange_pls_input_exchange_money"))
                } else {
                    //可兑金额>0, text数值>0
                    if Double(text!)! > Double(withdraw!)! {
                        showTipMesLabel(message: YXLanguageUtility.kLang(key: "exchange_exceeded_max_money"))
                    } else {
                        //密码验证页面
                        if let text = currencyText.textField.text, text.count > 0 {
                            if let closure = applyExchangeClosure {
                                closure(text)
                            }
                        }
                    }
                }
            } else {
                showTipMesLabel(message: YXLanguageUtility.kLang(key: "exchange_pls_input_exchange_money"))
            }
        } else {
            applyExchangeButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
            applyExchangeButton.isEnabled = false
        }
    }
    
    //MARK: - 全部兑换
    @objc func totalExchangeButtonEvent() {
        
        if let model = exchangeModel {
            
            let text = String(format: "%.2f", Double(model.sourceWithdrawBalance ?? "0")!)
            if text.count >= 15 {
                currencyText.textField.text = (text as NSString).substring(to: 15)
            } else {
                currencyText.textField.text = text
            }

            self.soureTextChanged()
        }
    }
    
    //MARK: - 更新汇率
    @objc func refreshButtonEvent() {
        
        if let closure = refreshClosure {
            closure()
        }
        
    }
    
    //查看兑换记录
    @objc func exchangeListButtonEvent() {
        
        if let closure = exchangeListClosure {
            closure()
        }
        
    }
    
    //可兑换金额
    func initExchangeNumber(model: YXCurrencyExchangeModel, by type:InOutExchangeType) {
        
        switch type {
        case .outExchangeType:
            if let text = currencyText.textField.text {
                if text.count > 0,
                   let rate = model.calculateRate,
                   let textDouble = Double(text) {
                    let value = textDouble * rate
                    targetText.textField.text = String(format: "%.2f", floor(value * 100) / 100.00)
                } else {
                    targetText.textField.text = ""
                }
            }
        case .inExchangeType:
            if let text = targetText.textField.text {
                if text.count > 0,
                   let rate = model.calculateRate,
                   rate != 0, // 作为除数
                   let textDouble = Double(text) {
                    
                    let calValue = textDouble / rate
                    let floor_calValue = ceil(calValue * 100) / 100.00

                    let value = floor_calValue / rate
                    
                    if value >= textDouble{
                        currencyText.textField.text = String(format: "%.2f", floor_calValue)
                    } else {
                        currencyText.textField.text = String(format: "%.2f", ceil(calValue * 100) / 100.00)
                    }
                } else {
                    currencyText.textField.text = ""
                }
            }
        }
    }
    
    //MARK: - 提示tips
    @objc func showTipMesLabel(message: String) {
        textTipLabel.isHidden = false
        textTipLabel.text = message
        exchangeLabel.isHidden = true
        exchangeNumLabel.isHidden = true
        currencyText.isError = true
    }
    
    @objc func hidTipMesLabel() {
        textTipLabel.isHidden = true
        exchangeLabel.isHidden = false
        exchangeNumLabel.isHidden = false
        currencyText.isError = false
    }
    
    @objc func showAlertView(message: String) {
        let alertView: YXAlertView = YXAlertView.init(title: "", message: message)
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: {[weak alertView] (action) in
            alertView?.hide()
        }))
        let alertController = YXAlertController.init(alert: alertView)!
        let vc = UIViewController.current()
        vc.present(alertController, animated: true, completion: nil)
    }
    
    @objc func showAlertViewWithConfirmAction(message: String) {
        
        let alertView: YXAlertView = YXAlertView.init(title: "", message: message)
        let alertController = YXAlertController.init(alert: alertView)!
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] (action) in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView, weak alertController,weak self] (action) in
            
            alertController?.dismissComplete = {
                if let closure = self?.applyExchangeClosure {
                    if let text = self?.currencyText.textField.text {
                        if text.count > 0 {
                            let amount = text
                            closure(amount)
                        }
                    }
                }
            }
            alertView?.hide()
        }))
        
        let vc = UIViewController.current()
        vc.present(alertController, animated: true, completion: nil)
        
    }
    
    //初始化数据
    func initData(with source:YXCurrencyType, target:YXCurrencyType) {
        
        
        sourceUnitString = source.name()
        targetUnitString = target.name()
        //清空输入，隐藏提示
        currencyText.textField.text = ""
        targetText.textField.text = ""
        hidTipMesLabel()
        fillModel()
        
    }
    
    //MARK: - lazy load
    @objc lazy var exchangeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "exchange_from")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
        
    }()
    
    @objc lazy var exchangeLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "exchange_available_money")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
        
    }()
    
    @objc lazy var exchangeNumLabel: UILabel = {
        
        let label = UILabel()
        label.text = "0.00"
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
        
    }()
    
    @objc lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = sourceUnitString
        return label
    }()
    
    @objc lazy var currencyText: YXTextFieldInputView = {
        
        let inputView = YXTextFieldInputView.init(placeHolder: YXLanguageUtility.kLang(key: "exchange_out"), type: .normal)
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        inputView.textField.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        inputView.textField.adjustsFontSizeToFitWidth = true
        inputView.textField.minimumFontSize = 12
        inputView.textField.keyboardType = UIKeyboardType.decimalPad
        inputView.textField.addTarget(self, action: #selector(soureTextChanged), for: .editingChanged)
        inputView.textField.delegate = self
        inputView.isClear = false
        inputView.leftPadding = 60
        inputView.clearBtnClickClosure = { [weak self] in
            self?.targetText.textField.text = ""
            self?.soureTextChanged()
        }
        inputView.textField.attributedPlaceholder = NSAttributedString(
            string: YXLanguageUtility.kLang(key: "exchange_out"),
            attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 20)]
        )
        return inputView
        
    }()
    
    @objc lazy var totalExchangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(YXLanguageUtility.kLang(key: "exchange_exchange_all"), for: .normal)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.addTarget(self, action: #selector(totalExchangeButtonEvent), for: .touchUpInside)
        return button
        
    }()
    
    // 错误文字
    @objc lazy var textTipLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "exchange_exceeded_max_money2")
        label.textColor = UIColor.qmui_color(withHexString: "#EE3D3D")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    //分割线
    @objc lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view;
        
    }()
    
    @objc lazy var exchangeExpectTitleLabel: UILabel = {
        
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "exchange_estimated")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
        
    }()
    
    @objc lazy var targetLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = targetUnitString
        return label
        
    }()

    
    @objc lazy var targetText: YXTextFieldInputView = {
        
        let inputView = YXTextFieldInputView.init(placeHolder: YXLanguageUtility.kLang(key: "exchange_in"), type: .normal)
        inputView.textField.textColor = QMUITheme().textColorLevel1()
        inputView.textField.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        inputView.textField.keyboardType = UIKeyboardType.decimalPad
        inputView.textField.addTarget(self, action: #selector(taegetTextChanged), for: .editingChanged)
        inputView.textField.delegate = self
        inputView.isClear = false
        inputView.leftPadding = 60
        inputView.clearBtnClickClosure = { [weak self] in
            self?.currencyText.textField.text = ""
            self?.soureTextChanged()
        }
        inputView.textField.attributedPlaceholder = NSAttributedString(
            string: YXLanguageUtility.kLang(key: "exchange_out"),
            attributes: [.foregroundColor: QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 20)]
        )
        return inputView
        
    }()
    
    // 参考汇率
    @objc lazy var exchangeRatioTitleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "exchange_ref_exchange_rate")
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    @objc lazy var exchangeRatioNumLable: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    @objc lazy var refreshButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "refresh_exchange"), for: .normal)
        button.addTarget(self, action: #selector(refreshButtonEvent), for: .touchUpInside)
        return button
    }()
    //MARK: 申请兑换
    @objc lazy var applyExchangeButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle(YXLanguageUtility.kLang(key: "exchange_apply_exchange"), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.4)
        button.layer.cornerRadius = 4
        button.isEnabled = false
        button.addTarget(self, action: #selector(applyExchangeButtonEvent(_:)), for: .touchUpInside)
        return button
        
    }()
    
    @objc lazy var exchangeListButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle(YXLanguageUtility.kLang(key: "exchange_view_exchange_history"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(exchangeListButtonEvent), for: .touchUpInside)
        return button
        
    }()

    @objc lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    
    @objc var sourceUnitString: String = {
        let string = ""
        return string
    }()
    
    @objc var targetUnitString: String = {
        let string = ""
        return string
    }()
    
    @objc required init(frame: CGRect, market: String) {
        super.init(frame: frame)

        if market.lowercased().elementsEqual("hk") {
            sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_hk")
            targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_sg")
        }
        else if market.lowercased().elementsEqual("us") {
            sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_us")
            targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_hk")
        }
        else {
            sourceUnitString = YXLanguageUtility.kLang(key: "exchange_unit_sg")
            targetUnitString = YXLanguageUtility.kLang(key: "exchange_unit_us")
        }

        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(exchangeTitleLabel)
        addSubview(exchangeLabel)
        addSubview(exchangeNumLabel)
        addSubview(currencyText)
        currencyText.addSubview(currencyLabel)
        addSubview(totalExchangeButton)
        addSubview(textTipLabel)
        
        addSubview(lineView)
        addSubview(exchangeExpectTitleLabel)
        addSubview(targetText)
        targetText.addSubview(targetLabel)
        addSubview(exchangeRatioTitleLabel)
        addSubview(exchangeRatioNumLable)
        addSubview(applyExchangeButton)
        addSubview(exchangeListButton)
        addSubview(refreshButton)
        
        //兑出
        exchangeTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
        }

        totalExchangeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.exchangeLabel.snp.centerY)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(20)
        }
        
        currencyText.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
        
        currencyLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        exchangeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(currencyText.snp.bottom).offset(12)
        }
        
        exchangeNumLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.exchangeLabel.snp.centerY)
            make.left.equalTo(self.exchangeLabel.snp.right).offset(15)
        }
        
        textTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.currencyText.snp.left)
            make.centerY.equalTo(self.exchangeLabel.snp.centerY)
            make.height.equalTo(17)
        }
        textTipLabel.isHidden = true
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
            make.top.equalTo(exchangeLabel.snp.bottom).offset(24)
        }
        
        //预计兑入模块
        exchangeExpectTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(lineView.snp.bottom).offset(24)
        }
        
        
        targetText.snp.makeConstraints { (make) in
            make.top.equalTo(exchangeExpectTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
        
        targetLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        exchangeRatioTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(targetText.snp.left)
            make.top.equalTo(targetText.snp.bottom).offset(12)
        }
        
        exchangeRatioNumLable.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.exchangeRatioTitleLabel.snp.centerY)
            make.left.equalTo(self.exchangeRatioTitleLabel.snp.right).offset(16)
        }
        
        refreshButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.exchangeRatioTitleLabel.snp.centerY)
            make.width.equalTo(16)
            make.height.equalTo(16)
            make.left.equalTo(exchangeRatioNumLable.snp.right).offset(8)
        }
        
        applyExchangeButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.exchangeRatioTitleLabel.snp.bottom).offset(41)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(self.snp.right).offset(-16)
            make.height.equalTo(48)
        }
        
        exchangeListButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.applyExchangeButton.snp.bottom).offset(12)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let font = UIFont.systemFont(ofSize: 20)
        let sourceWidth = (sourceUnitString as NSString).width(for: font)
        let targetWidth = (targetUnitString as NSString).width(for: font)
        let maxPadding = max(max(sourceWidth, targetWidth) + 10, 60)
        currencyText.leftPadding = maxPadding
        targetText.leftPadding = maxPadding
    }

}
