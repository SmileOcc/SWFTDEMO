//
//  YXSmartTradePriceView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartTradePriceView: UIView, YXTradeHeaderSubViewProtocol, YXTradePriceProtocol {    
    private let maxPrice = 9999999.999
            
    var spreadTable: [YXSpreadTableManager.SpreadTable]? {
        didSet {
            updateMinChange()
        }
    }
    
    var isInlineWarrant: Bool? {
        didSet {
            if isInlineWarrant ?? false {
                inputPriceView.maxValue = 1
            } else {
                inputPriceView.maxValue = maxPrice
            }
        }
    }
    
    private var gearType: GearType {
        selectGearTypeView.selectView.selectedType
    }
    
    lazy var inputPriceView: TradeInputView = {
        let view = TradeInputView(inputType: .price, rightMargin: true) { [weak self] (input) in
            guard let strongSelf = self else { return }
            strongSelf.updateMinChange()
            
            if strongSelf.gearType == .entrust {
                strongSelf.priceDidChange?(.entrust, input)
            } else {
                strongSelf.priceDidChange?(strongSelf.gearType, "")
            }
        }
        view.addBtn.backgroundColor = QMUITheme().foregroundColor()
        view.cutBtn.backgroundColor = QMUITheme().foregroundColor()
        view.maxValue = maxPrice
        return view
    }()
    
    private(set) lazy var selectGearTypeView: YXTradeSelectGearTypeView = {
        let typeArr = GearType.typeArr(market: params.market, smartOrderType: params.smartOrderType)
        var gearType = params.gearType
        if !typeArr.contains(gearType) {
            if typeArr.contains(.entrust) {
                gearType = .entrust
            } else {
                gearType = .latest
            }
        }
        let view = YXTradeSelectGearTypeView(typeArr: typeArr, selected: gearType) {[weak self] type in
            guard let strongSelf = self else { return }
            
            if type == .entrust {
                strongSelf.inputPriceView.setupInput()
            } else {
                strongSelf.inputPriceView.setupInput(desc: type.text)
            }
        }
        return view
    }()
    
    var params: YXTradePriceView.Params! {
        didSet {
            let gearTypeArr = GearType.typeArr(market: params.market, smartOrderType: params.smartOrderType)
            var gearType = params.gearType
            if !gearTypeArr.contains(gearType) {
                if gearTypeArr.contains(.entrust) {
                    gearType = .entrust
                } else {
                    gearType = .latest
                }
            }
            selectGearTypeView.selectView.updateType(gearTypeArr, selected: gearType)
        }
    }
    
    @objc func updatePrice(price: String) {
        if gearType != .entrust {
            selectGearTypeView.selectView.updateType(selected: .entrust)
        }
        inputPriceView.updateInput(price)
    }
    
    private var priceDidChange: ((GearType, String) -> Void)?
    convenience init(params: YXTradePriceView.Params, priceDidChange: ((GearType, String) -> Void)?) {
        self.init()
        
        self.priceDidChange = priceDidChange
        self.params = params
        
        addSubview(inputPriceView)
        
        inputPriceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        addSubview(selectGearTypeView)
        selectGearTypeView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(28)
            make.height.equalTo(52)
            make.bottom.equalTo(inputPriceView)
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



class YXTradeSelectGearTypeView: UIView {
    var selectView: YXSelectTypeView<GearType>!
    convenience init(typeArr: [GearType], selected: GearType? = nil, selectedBlock:((GearType) -> ())?) {
        self.init()

        clipsToBounds = true
                
        selectView = YXSelectTypeView(typeArr: typeArr,
                                      selected: selected,
                                      contentHorizontalAlignment: .right,
                                      arrowImage: UIImage(named: "icon_gear"),
                                      selectedBlock: selectedBlock)
        addSubview(selectView)
        selectView.inputBGView.lineView.backgroundColor = .clear

        selectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


extension GearType: EnumTextProtocol {
    
    var text: String {
        switch self {
        case .ask_5:
            return YXLanguageUtility.kLang(key: "stock_detail_sell_five")
        case .ask_1:
            return YXLanguageUtility.kLang(key: "stock_detail_sell_one")
        case .latest:
            return YXLanguageUtility.kLang(key: "trade_latest_price")
        case .market:
            return YXLanguageUtility.kLang(key: "trade_market_price")
        case .bid_1:
            return YXLanguageUtility.kLang(key: "stock_detail_buy_one")
        case .bid_5:
            return YXLanguageUtility.kLang(key: "stock_detail_buy_five")
        case .entrust:
            return YXLanguageUtility.kLang(key: "trade_lmt_price")
        }
    }
    
    static func typeArr(market: String, smartOrderType: SmartOrderType) -> [GearType] {
        var typeArr: [GearType] = [.bid_5, .bid_1, .entrust, .latest, .market, .ask_1, .ask_5]

        if smartOrderType == .tralingStop {
            typeArr = typeArr.filter{ $0 != .entrust }
        }
        
        if market == kYXMarketUS || market == kYXMarketSG {
            typeArr = typeArr.filter{ $0 != .bid_5 && $0 != .ask_5 }
        } else if market == kYXMarketChinaSH || market == kYXMarketChinaSZ {
            typeArr = typeArr.filter{ $0 != .market }
        }
        return typeArr
    }
}
