//
//  YXErrorTips.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeErrorTipsView: UIView, YXTradeHeaderSubViewProtocol {
    
    typealias Params = (market: String, currency: String, tradeOrderType: TradeOrderType, smartOrderType: SmartOrderType?, latestPrice: String?, basicPrice: String?, inputPrice: String?)
    
    private enum ErrorTips {
        case fivePercent
        case condition
        case odd
        case spread(_ minChange: String)
        case none
        
        var stringValue: String {
            switch self {
            case .fivePercent:
                return YXLanguageUtility.kLang(key: "trading_price_over_five_percent")
            case .condition:
                return YXLanguageUtility.kLang(key: "condition_price_tips")
            case .odd:
                return YXLanguageUtility.kLang(key: "odd_lot_order_tips")
            case .spread(let minChange):
                return String(format: YXLanguageUtility.kLang(key: "trading_spread_tips"), minChange)
            default:
                break
            }
            return ""
        }
    }
    
    private(set) lazy var tipsLabel: UILabel = {
        let label = QMUILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#F9A800")
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    var params: Params! {
        didSet {
            updateErrorTips()
        }
    }
    
    weak var tradePriceView: (UIView & YXTradePriceProtocol)?
    
    var isCondition: Bool = false
    convenience init(params: Params, isCondition: Bool = false) {
        self.init()
        
        self.isCondition = isCondition
        self.params = params

        addSubview(tipsLabel)
//        if isCondition {
//            tipsLabel.textAlignment = .right
//        }
//        
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
        
    private func updateErrorTips() {
        guard isCondition == false else {
            updateConditionErrorTips()
            return
        }
        
        var errorTips: ErrorTips = .none
        defer {
            showErrorTips(errorTips)
        }
        guard params.smartOrderType != .stockHandicap,
              let inputPrice = Double(params.inputPrice ?? ""),
              inputPrice > 0 else { return }

        let market = params.market
        let tradeOrderType = params.tradeOrderType
        
        if tradeOrderType == .broken,
           let latestPrice = Double(params.basicPrice ?? ""),
           latestPrice > 0 {
            let brokenPrice: Double = latestPrice * 0.97
            if inputPrice > brokenPrice  {
                errorTips = .odd
                return
            }
        }
        
        if let tradePriceView = tradePriceView {
            if let cutMinChange = tradePriceView.inputPriceView.cutMinChange, let cutMinChangeValue = Double(tradePriceView.inputPriceView.cutMinChange ?? ""), cutMinChangeValue > 0 {
                let tempInputValue = Int64(round(inputPrice * 10000))
                let tempCutMinChangeValue = Int64(round(cutMinChangeValue * 10000))
                
                if tempInputValue % tempCutMinChangeValue != 0 {
                    errorTips = .spread(cutMinChange)
                    return
                }
            }
        }
       
        if market == kYXMarketHK,
           tradeOrderType != .market, tradeOrderType != .bidding {
            if let latestPrice = Double(params.basicPrice ?? ""),
               latestPrice > 0 {
                let upPrice = latestPrice * 1.05
                let downPrice = latestPrice * 0.95
                
                if inputPrice >= upPrice || inputPrice < downPrice {
                    errorTips = .fivePercent
                }
            }
        }
    }
    
    private func showErrorTips(_ errorTips: ErrorTips) {
        if errorTips.stringValue.count == 0 {
            isHidden = true
            contentHeight = 0
        } else {
            let tips = errorTips.stringValue
            tipsLabel.text = tips
            isHidden = false
            contentHeight = max(20, tips.height(.systemFont(ofSize: 12), limitWidth: tipsLabel.width) + 4)
        }
    }

}

///ConditionError
extension YXTradeErrorTipsView {
    private enum ConditionErrorTips: String {
        
        case notHigh = "price_not_high_tips"
        case notLow = "price_not_low_tips"
        case none
    }
    
    func updateConditionErrorTips() {
         var errorTips: ConditionErrorTips = .none
         defer {
             showConditionErrorTips(errorTips)
         }
         
        guard let conditionPrice = Double(params.basicPrice ?? ""),
                conditionPrice > 0 else { return }

         let tradeOrderType = params.tradeOrderType
         if tradeOrderType == .smart {
             let smartOrderType = params.smartOrderType
             if let latestPrice = Double(params.latestPrice ?? "") {
                 switch smartOrderType {
                 case .highPriceSell,
                      .breakBuy:
                     if conditionPrice < latestPrice {
                         errorTips = .notLow
                     }
                 case .lowPriceBuy,
                      .breakSell:
                     if conditionPrice > latestPrice {
                         errorTips = .notHigh
                     }
                 default:
                     errorTips = .none
                     break
                 }
             }
         }
     }
     
     private func showConditionErrorTips(_ errorTips: ConditionErrorTips) {
         if errorTips == .none {
             isHidden = true
             contentHeight = 0
         } else {
             let tips = YXLanguageUtility.kLang(key: errorTips.rawValue)
             tipsLabel.text = tips
             isHidden = false
             contentHeight = max(20, tips.height(.systemFont(ofSize: 12), limitWidth: width - 32) + 10)
         }
     }
}
