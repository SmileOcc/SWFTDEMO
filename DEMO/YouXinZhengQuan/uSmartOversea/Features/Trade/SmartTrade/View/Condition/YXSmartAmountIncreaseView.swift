//
//  YXSmartAmountIncreaseView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXSmartAmountIncreaseView: UIView, UITextFieldDelegate, YXTradeHeaderSubViewProtocol {
    
    private lazy var inputBGView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var percentLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "%"
        label.textAlignment = .right
        return label
    }()
    
    @objc lazy var percentTextFld: YXTextField = {
        let textFld = YXTextField()
        textFld.textColor = QMUITheme().textColorLevel1()
        textFld.font = .systemFont(ofSize: 16, weight: .medium)
        textFld.keyboardType = .decimalPad
        textFld.banAction = true
        
        textFld.inputType = .money
        textFld.integerBitCount = 7
        textFld.decimalBitCount = 2

        textFld.delegate = self
        return textFld
    }()
    
    @objc lazy var bottomTipLab: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    
    var currency: String = YXLanguageUtility.kLang(key: "common_hk_dollar") {
        didSet {
            if oldValue != currency {
                updateBottomTips()
            }
        }
    }
    
    private var costPrice: String? {
        didSet {
            if !isTralingStop {
                basicPrice = costPrice
            } else {
                updateBottomTips()
            }
        }
    }
    
    func updateCostPriceIfNeed(_ costPriceValue: Double) {
        if supportPortfolio {
            if costPriceValue > 0 {
                costPrice = String(format: "%.3f", costPriceValue)
            }
        }
    }
    
    var basicPrice: String? {
        didSet {
            if oldValue != basicPrice {
                updateBottomTips()
            }
        }
    }
    
    var upDownText: String = YXLanguageUtility.kLang(key: "price_up_to")
    var smartOrderType: SmartOrderType = .breakBuy {
        didSet {
            var placeholder = ""
            
            if supportDown {
                upDownText = YXLanguageUtility.kLang(key: "price_down_to")
                placeholder = YXLanguageUtility.kLang(key: "input_down_percent")
                percentTextFld.integerBitCount = 2
            }
            
            if supportUp {
                placeholder = YXLanguageUtility.kLang(key: "input_up_percent")
                upDownText = YXLanguageUtility.kLang(key: "price_up_to")
                percentTextFld.integerBitCount = 7
            }

            if isTralingStop {
                placeholder = YXLanguageUtility.kLang(key: "please_enter_the_percentage")
                upDownText = YXLanguageUtility.kLang(key: "estimated_stop_loss_price") + ":"
                percentTextFld.integerBitCount = 2
            }
            
            percentTextFld.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
            updateBottomTips()
        }
    }
    

    private var supportUp: Bool {
        let supportUpTypes: [SmartOrderType] = [.stopProfitSell, .stopProfitSellOption, .highPriceSell, .breakBuy]
        return supportUpTypes.contains(smartOrderType)
    }
    
    private var supportDown: Bool {
        let supportDownTypes: [SmartOrderType] = [.stopLossSell, .stopLossSellOption, .lowPriceBuy, .breakSell, .tralingStop]
        return supportDownTypes.contains(smartOrderType)
    }
    
    private var supportPortfolio: Bool {
        SmartOrderType.portfolioTypes.contains(smartOrderType)
    }
    
    private var isTralingStop: Bool {
        smartOrderType == .tralingStop
    }
    
    func updateBottomTips() {
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 12)]
        let attr = NSMutableAttributedString()
        if supportPortfolio {
            attr.append(NSAttributedString(string: YXLanguageUtility.kLang(key: "smart_cost_price") + ": ", attributes: attributes))
            
            if let basicPrice = costPrice, let basicPriceValue = Double(basicPrice) {
                let priceString = String(format: "%.3f , ", basicPriceValue)
                attr.append(NSAttributedString(string: priceString, attributes: attributes))
            } else {
                attr.append(NSAttributedString(string: "-- ,", attributes: attributes))
            }
        }
        attr.append(NSAttributedString(string: upDownText, attributes: attributes))
        let currencyAttr = NSAttributedString(string: YXLanguageUtility.kLang(key: "common_en_space") + currency, attributes: attributes)
        
        var valueAttr = NSAttributedString(string: "--", attributes: attributes)
        if let text = percentTextFld.text, let percent = Double(text) {
            
            var increase = 1 + (percent / 100.0)
            if supportDown {
                if percent > 100 {
                    increase = 0
                } else {
                    increase = (1.0 - percent / 100.0)
                }
            }
            
            attributes[.foregroundColor] = QMUITheme().themeTextColor()
            
            let increaseNumber = NSDecimalNumber(string: String(format: "%.4f", abs(increase - 1.0)))

            if let basicPrice = basicPrice, let basicPriceValue = Double(basicPrice), basicPriceValue > 0 {
                let priceString = String(format: "%.3f", basicPriceValue * increase)
                valueAttr = NSAttributedString(string: priceString, attributes: attributes)
                increaseBlock?(increaseNumber, priceString)
            } else {
                increaseBlock?(increaseNumber, nil)
            }
        } else {
            increaseBlock?(nil, nil)
        }
        attr.append(valueAttr)
        attr.append(currencyAttr)
        bottomTipLab.attributedText = attr
        
//        contentHeight = max(82, attr.height(limitWidth: YXConstant.screenWidth - 16 * 4) + 30 - UIFont.systemFont(ofSize: 12).capHeight)
    }
    
    var increaseBlock: ((NSDecimalNumber?, String?)->Void)?
    convenience init(_ amountIncrease: String?, increaseBlock:(@escaping (NSDecimalNumber?, String?)->Void)) {
        self.init()
                
        addSubview(inputBGView)
        inputBGView.addSubview(percentLab)
        inputBGView.addSubview(percentTextFld)
        addSubview(bottomTipLab)
        
        percentTextFld.text = amountIncrease
        
        inputBGView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }
        
        percentLab.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(16)
        }

        percentTextFld.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.right.equalTo(percentLab.snp.left).offset(-24)
        }

        bottomTipLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(inputBGView)
            make.top.equalTo(inputBGView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        Observable.merge([percentTextFld.rx.observeWeakly(String.self, "text").asObservable(), percentTextFld.rx.text.asObservable()]).subscribe { [weak self] (_) in
            self?.updateBottomTips()
        }.disposed(by: rx.disposeBag)
        
        self.increaseBlock = increaseBlock
            
        contentHeight = 82
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""
        text.append(string)
        if string == "0", text == "0.00" {
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "error_input"))
        }
        
        return percentTextFld.textField(_:textField, shouldChangeCharactersIn:range, replacementString:string)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputBGView.isSelect = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.inputBGView.isSelect = false
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
