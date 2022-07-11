//
//  YXSmartTradeNumberView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartTradeNumberView: UIView, YXTradeHeaderSubViewProtocol {
    
    private let maxNumber: Double = 99999999999
    
    @objc func updateNumber(_ number: NSNumber) {
        inputNumberView.updateInput(number)
    }
            
    lazy var inputNumberView: TradeInputView = {
        let view = TradeInputView(inputType: .number, rightMargin: true, inputDidChange: numberDidChange)
        view.addBtn.backgroundColor = QMUITheme().foregroundColor()
        view.cutBtn.backgroundColor = QMUITheme().foregroundColor()
        view.maxValue = maxNumber
        return view
    }()
    
    lazy var showPaymentButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon_show_num"), for: .normal)
        button.setBackgroundImage(UIImage(named: "icon_show_num_selected"), for: .selected)
        button.adjustsImageWhenHighlighted = false
        button.isSelected = true
        return button
    }()
    
    var numberDidChange: ((String) -> Void)?
    convenience init(numberDidChange: ((String) -> Void)?) {
        self.init()
        
        self.numberDidChange = numberDidChange
        
        addSubview(inputNumberView)
        addSubview(showPaymentButton)
        
        inputNumberView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        showPaymentButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }

        contentHeight = 54
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
