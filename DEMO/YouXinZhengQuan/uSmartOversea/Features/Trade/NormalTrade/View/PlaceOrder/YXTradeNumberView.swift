//
//  YXTradeNumberView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeNumberView: UIView, YXTradeHeaderSubViewProtocol {
    
    private let maxNumber: Double = 9999999999
    
    @objc func updateNumber(_ number: NSNumber) {
        inputNumberView.updateInput(number)
    }
            
    lazy var inputNumberView: TradeInputView = {
        let view = TradeInputView(inputType: .number, inputDidChange: numberDidChange)
        view.useNewStyle()
        view.maxValue = maxNumber
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "quantity")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()
    
    lazy var showPaymentButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_show_num_n"), for: .normal)
        button.setBackgroundImage(UIImage(named: "icon_show_num_n_selected"), for: .selected)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    
    var numberDidChange: ((String) -> Void)?
    convenience init(numberDidChange: ((String) -> Void)?) {
        self.init()
        
        self.numberDidChange = numberDidChange
        
    
        addSubview(titleLabel)
        addSubview(showPaymentButton)
        addSubview(inputNumberView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        showPaymentButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(16)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        inputNumberView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-64)
            make.width.equalTo(162)
        }

        contentHeight = 56
    }
    
    var paymentHidden: Bool = false {
        didSet {
            if paymentHidden {
                showPaymentButton.isHidden = true
                
                inputNumberView.snp.updateConstraints { make in
                    make.right.equalToSuperview().offset(-16)
                    make.width.equalTo(210)
                }
            } else {
                showPaymentButton.isHidden = false
                inputNumberView.snp.updateConstraints { make in
                    make.right.equalToSuperview().offset(-64)
                    make.width.equalTo(162)
                }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

class YXFractionalTradeNumberView: UIView, YXTradeHeaderSubViewProtocol {
    
    private let maxNumber: Double = 9999999.9999
    
    @objc func updateNumber(_ number: NSNumber) {
        inputNumberView.updateInput(number)
    }
    
    func refreshMinChange(with price: String) {
        let priceValue = Double(price) ?? 0
        
        if priceValue >= 10000 {
            inputNumberView.resetMinChange("0.0001")
        } else if priceValue >= 1000 {
            inputNumberView.resetMinChange("0.001")
        } else if priceValue >= 100 {
            inputNumberView.resetMinChange("0.01")
        } else {
            inputNumberView.resetMinChange("0.1")
        }
    }
    
    lazy var inputNumberView: TradeInputView = {
        let view = TradeInputView(inputType: .fractionalNumber, inputDidChange: numberDidChange)
        view.useNewStyle()
        view.maxValue = maxNumber
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "quantity")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()
    
    var numberDidChange: ((String) -> Void)?
    convenience init(numberDidChange: ((String) -> Void)?) {
        self.init()
        
        self.numberDidChange = numberDidChange
        
    
        addSubview(titleLabel)
        addSubview(inputNumberView)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        inputNumberView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(210)
        }

        contentHeight = 56
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
