//
//  YXTradeOrderTypeView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/3/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeOrderTypeView: UIView, YXTradeHeaderSubViewProtocol {
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "trade_type")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()
    
    lazy var infoButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var infoIconView: UIImageView = {
        let iconView = UIImageView()
        iconView.image = UIImage(named: "smart_type_info")
        iconView.contentMode = .left
        return iconView
    }()

    var selectView: YXSelectTypeView<TradeOrderType>!
    convenience init(typeArr: [TradeOrderType], selected: TradeOrderType? = nil, selectedBlock:((TradeOrderType) -> Void)?) {
        self.init()
        
        contentHeight = 56
        
        selectView = YXSelectTypeView(typeArr: typeArr, selected: selected, contentHorizontalAlignment: .center, selectedBlock: selectedBlock)
        selectView.isNewStyle = true
        selectView.inputBGView.useNewStyle()
        
        selectView.typeClickBlock = { [weak self] in
            self?.trackViewClickEvent(name: "Down button_Tab")
        }
        
        addSubview(selectView)
        addSubview(titleLabel)
        addSubview(infoIconView)
        addSubview(infoButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.height.equalTo(40)
        }
                
        selectView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.width.equalTo(210)
        }
        
        infoIconView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.centerY.height.equalTo(titleLabel)
            make.width.equalTo(20)
        }
        
        infoButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(infoIconView)
            make.bottom.top.equalTo(titleLabel)
        }
        
    }
}

extension TradeOrderType {
    static func typeArr(tradeModel: TradeModel, quote: YXV2Quote?) -> [TradeOrderType] {
        var typeArr: [TradeOrderType] = []
        if tradeModel.tradeStatus == .change {
            typeArr = [tradeModel.tradeOrderType]
        } else {
            if tradeModel.symbol.count > 0 {
                if tradeModel.tradeType == .intraday {
                    if tradeModel.market == kYXMarketHK {
                        typeArr = [.limitEnhanced, .market]
                    } else {
                        typeArr = [.limit, .market]
                    }
                } else {
                    switch tradeModel.market {
                    case kYXMarketHK:
                        if tradeModel.tradePeriod == .grey {
                            typeArr = [.limit]
                        } else {
                            typeArr = [.limitEnhanced, .market, .bidding, .limitBidding]
                        }
                    case kYXMarketUS:
                        if tradeModel.tradeType == .shortSell, tradeModel.tradeStatus == .limit {
                            typeArr = [.limit]
                        } else {
                            typeArr = [.limit, .market]
                        }
                    case kYXMarketSG:
                        typeArr = [.limit, .market]
                    default:
                        typeArr = [.limit]
                    }
                }
            } else {
                typeArr = [tradeModel.tradeOrderType]
            }
        }
        return typeArr
    }
    
    static func shortCutTypeArr(tradeModel: TradeModel, quote: YXV2Quote?) -> [TradeOrderType] {
        var typeArr: [TradeOrderType] = []
        if tradeModel.symbol.count > 0 {
            if tradeModel.tradeType == .intraday {
                if tradeModel.market == kYXMarketHK {
                    typeArr = [.limitEnhanced, .market]
                } else {
                    typeArr = [.limit, .market]
                }
            } else {
                switch tradeModel.market {
                case kYXMarketHK:
                    if tradeModel.tradePeriod == .grey {
                        typeArr = [.limit]
                    } else {
                        typeArr = [.limitEnhanced, .market, .bidding, .limitBidding]
                    }
                case kYXMarketUS:
                    if tradeModel.tradeType == .shortSell, tradeModel.tradeStatus == .limit {
                        typeArr = [.limit]
                    } else {
                        typeArr = [.limit, .market]
                    }
                case kYXMarketSG:
                    typeArr = [.limit, .market]
                default:
                    typeArr = [.limit]
                }
            }
        } else {
            typeArr = [tradeModel.tradeOrderType]
        }
        return typeArr
    }
}
