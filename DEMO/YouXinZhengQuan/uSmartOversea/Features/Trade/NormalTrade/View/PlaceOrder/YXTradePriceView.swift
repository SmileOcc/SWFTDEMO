//
//  YXTradePriceView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXTradePriceView: UIView, YXTradeHeaderSubViewProtocol, YXTradePriceProtocol {
    
    typealias Params = (market: String, currency: String, tradeOrderType: TradeOrderType, smartOrderType: SmartOrderType, gearType: GearType, latestPrice: String?, conditionPrice: String?)
    
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
        view.useNewStyle()
        view.maxValue = maxPrice
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_price")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()
    
    var params: Params! {
        didSet {
        }
    }
    
    
    @objc func updatePrice(price: String) {
        inputPriceView.updateInput(price)
    }
    
    private var priceDidChange: ((String) -> Void)?
    convenience init(params: Params, priceDidChange: ((String) -> Void)?) {
        self.init()
        
        self.priceDidChange = priceDidChange
        self.params = params
        
        addSubview(titleLabel)
        addSubview(inputPriceView)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        inputPriceView.snp.makeConstraints { (make) in
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

//MARK: Private Methods
protocol YXTradePriceProtocol {
    var spreadTable: [YXSpreadTableManager.SpreadTable]? { set get}
    
    var inputPriceView: TradeInputView { set get }
}

extension YXTradePriceProtocol {
    
    func updateMinChange() {
        guard let spreadTable = spreadTable, spreadTable.count > 0 else { return }

        if let price = Double(inputPriceView.input) {
            for (index, table) in spreadTable.enumerated() {
                let from = table.from
                let to = table.to
                let value = table.value
                
                if price >= from, price < to {
                    inputPriceView.addMinChange = value
                    if price != from {
                        inputPriceView.cutMinChange = value
                    }
                }
                
                if price == to {
                    inputPriceView.cutMinChange = value
                }
                
                if index == spreadTable.count - 1, price >= to {
                    inputPriceView.addMinChange = value
                }
                
                if index == 0, price < from {
                    inputPriceView.resetMinChange(value)
                }
            }
        } else {
            inputPriceView.resetMinChange(spreadTable[0].value)
        }
    }
    
}

extension TradeModel {
    var priceParams: YXTradePriceView.Params {
        return (market: market, currency: currency, tradeOrderType: tradeOrderType, smartOrderType: condition.smartOrderType, gearType: condition.entrustGear, latestPrice: latestPrice, conditionPrice: condition.conditionPrice)
    }
    
    var inputTipParams: YXTradeErrorTipsView.Params {
        if tradeOrderType == .smart {
            return (market: market, currency: currency, tradeOrderType: tradeOrderType, smartOrderType: condition.smartOrderType, latestPrice: latestPrice, basicPrice: condition.conditionPrice, inputPrice: entrustPrice)
        }
        return (market: market, currency: currency, tradeOrderType: tradeOrderType, smartOrderType: nil, latestPrice: latestPrice, basicPrice: latestPrice, inputPrice: entrustPrice)
    }
}

extension YXV2Quote {
    var isInlineWarrant: Bool {
        return type3?.value == OBJECT_SECUSecuType3.stInlineWarrant.rawValue
    }
}
