//
//  YXTradeAmoutView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/4/22.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeAmountView: UIView, YXTradeHeaderSubViewProtocol {
    
    
    private let maxAmount = 9999999.999
            
    lazy var inputAmountView: TradeInputView = {
        let view = TradeInputView(inputType: .amount) { [weak self] (input) in
            guard let strongSelf = self else { return }
            strongSelf.amountDidChange?(input)
        }
        view.resetMinChange("1")
        view.useNewStyle()
        view.maxValue = maxAmount
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "trade_amount")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()
    
    
    private var amountDidChange: ((String) -> Void)?
    convenience init(amountDidChange: ((String) -> Void)?) {
        self.init()
        
        self.amountDidChange = amountDidChange
        
        addSubview(titleLabel)
        addSubview(inputAmountView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        inputAmountView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(16)
            make.height.equalTo(40)
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
