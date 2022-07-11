//
//  YXSmartPriceSpreadView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXSmartPriceSpreadView: UIView, UITextFieldDelegate, YXTradeHeaderSubViewProtocol {

    private lazy var inputBGView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
    @objc lazy var textFld: YXTextField = {
        let textFld = YXTextField()
        textFld.attributedPlaceholder = NSAttributedString(string: YXLanguageUtility.kLang(key: "please_enter_the_spread"), attributes: [.foregroundColor: QMUITheme().textColorLevel4(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        textFld.textColor = QMUITheme().textColorLevel1()
        textFld.font = .systemFont(ofSize: 16, weight: .medium)
        textFld.keyboardType = .decimalPad
        textFld.banAction = true
        
        textFld.inputType = .money
        textFld.integerBitCount = 7
        textFld.decimalBitCount = 3

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
            if oldValue != costPrice {
                updateBottomTips()
            }
        }
    }
    
    func updateCostPriceIfNeed(_ costPriceValue: Double) {
        if costPriceValue > 0 {
            costPrice = String(format: "%.3f", costPriceValue)
        }
    }
    
    var basicPrice: String? {
        didSet {
            if oldValue != basicPrice {
                updateBottomTips()
            }
        }
    }
    
    func updateBottomTips() {
        var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 12)]
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: YXLanguageUtility.kLang(key: "smart_cost_price") + ": ", attributes: attributes))
        
        if let basicPrice = costPrice, let basicPriceValue = Double(basicPrice) {
            let priceString = String(format: "%.3f , ", basicPriceValue)
            attr.append(NSAttributedString(string: priceString, attributes: attributes))
        } else {
            attr.append(NSAttributedString(string: "-- ,", attributes: attributes))
        }
        attr.append(NSAttributedString(string: YXLanguageUtility.kLang(key: "estimated_stop_loss_price") + ": ", attributes: attributes))
        let currencyAttr = NSAttributedString(string: YXLanguageUtility.kLang(key: "common_en_space") + currency, attributes: attributes)
        
        var valueAttr = NSAttributedString(string: "--", attributes: attributes)

        if let text = textFld.text, let spread = Double(text) {
            
            attributes[.foregroundColor] = QMUITheme().themeTextColor()
            
            if let basicPrice = basicPrice, let basicPriceValue = Double(basicPrice), basicPriceValue > 0 {
                let priceString = String(format: "%.3f", basicPriceValue - spread)
                valueAttr = NSAttributedString(string: priceString, attributes: attributes)
                spreadBlock?(text, priceString)
            } else {
                spreadBlock?(text, nil)
            }
        } else {
            spreadBlock?(nil, nil)
        }
        attr.append(valueAttr)
        attr.append(currencyAttr)
        bottomTipLab.attributedText = attr
    }
    
    var spreadBlock: ((String?, String?)->Void)?
    convenience init(_ spread: String?, spreadBlock:(@escaping (String?, String?)->Void)) {
        self.init()
                
        addSubview(inputBGView)
        inputBGView.addSubview(textFld)
        addSubview(bottomTipLab)
        
        textFld.text = spread
        
        inputBGView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }
        
        textFld.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(16)
        }

        textFld.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.right.equalToSuperview()
        }

        bottomTipLab.snp.makeConstraints { (make) in
            make.left.right.equalTo(inputBGView)
            make.top.equalTo(inputBGView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        Observable.merge([textFld.rx.observeWeakly(String.self, "text").asObservable(), textFld.rx.text.asObservable()]).subscribe { [weak self] (_) in
            self?.updateBottomTips()
        }.disposed(by: rx.disposeBag)
        
        self.spreadBlock = spreadBlock
            
        contentHeight = 82
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text ?? ""
        text.append(string)
        
        return textFld.textField(_:textField, shouldChangeCharactersIn:range, replacementString:string)
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
