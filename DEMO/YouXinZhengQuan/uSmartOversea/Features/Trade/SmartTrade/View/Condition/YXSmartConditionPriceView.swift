//
//  YXSmartCondtionPriceView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartConditionPriceView: UIView, YXTradeHeaderSubViewProtocol, YXTradePriceProtocol {
    
    private let maxPrice = 9999999.999
            
    var spreadTable: [YXSpreadTableManager.SpreadTable]? {
        didSet {
            updateMinChange()
        }
    }
    
    var isInlineWarrant: Bool? {
        didSet {
            if isInlineWarrant ?? false {
                self.inputPriceView.maxValue = 1
            } else {
                self.inputPriceView.maxValue = maxPrice
            }
        }
    }
    
    lazy var inputPriceView: TradeInputView = {
        let view = TradeInputView(inputType: .price) { [weak self] (input) in
            guard let strongSelf = self else { return }
            strongSelf.updateMinChange()
            strongSelf.priceDidChange?(input)
            
        }
        view.customPlaceHolder = YXLanguageUtility.kLang(key: "trade_input_condition_price")
        view.addBtn.backgroundColor = QMUITheme().foregroundColor()
        view.cutBtn.backgroundColor = QMUITheme().foregroundColor()
        view.maxValue = maxPrice
        return view
    }()
    
    
    var params: YXTradePriceView.Params! {
        didSet {
            let currency = (params.currency.count > 0 ? "(\(params.currency))" : "")
            if params.smartOrderType == .breakBuy
                || params.smartOrderType == .highPriceSell {
                inputPriceView.customPlaceHolder = YXLanguageUtility.kLang(key: "up_price") + currency
            } else  {
                inputPriceView.customPlaceHolder = YXLanguageUtility.kLang(key: "down_price") + currency

            }
        }
    }
    
    
    @objc func updatePrice(price: String) {
        inputPriceView.updateInput(price)
    }
    
    
    private var priceDidChange: ((String) -> Void)?
    convenience init(params: YXTradePriceView.Params, priceDidChange: ((String) -> Void)?) {
        self.init()
        
        self.priceDidChange = priceDidChange
        self.params = params
        
        addSubview(inputPriceView)
        
        inputPriceView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }
        contentHeight = 60
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
