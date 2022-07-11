//
//  YXSmartOrderTypeView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartOrderTypeView: UIView, YXTradeHeaderSubViewProtocol {
    
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

    var selectView: YXSelectTypeView<SmartOrderType>!
    convenience init(typeArr: [SmartOrderType], selected: SmartOrderType? = nil, selectedBlock:((SmartOrderType) -> Void)?) {
        self.init()
        
        selectView = YXSelectTypeView(typeArr: typeArr, selected: selected, contentHorizontalAlignment: .right, selectedBlock: selectedBlock)
        let maxLengthText = SmartOrderType.stockHandicap.text
        let minWidth = maxLengthText.width(.systemFont(ofSize: 14), limitHeight: .greatestFiniteMagnitude) + 32
        selectView.menuMinimumWidth = max(selectView.menuMinimumWidth, minWidth)
        
        selectView.typeClickBlock = { [weak self] in
            self?.trackViewClickEvent(name: "Down button_Tab")
        }
        
        addSubview(selectView)
        addSubview(titleLabel)
        addSubview(infoIconView)
        addSubview(infoButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(selectView)
        }
                
        selectView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        infoIconView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.centerY.height.equalTo(selectView)
            make.width.equalTo(20)
        }
        
        infoButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(infoIconView)
            make.bottom.top.equalToSuperview()
        }
        
        contentHeight = 56
    }
}
extension SmartOrderType {
    static func typeArr(tradeModel: TradeModel, type1: Int32? = nil) -> [SmartOrderType] {
        var typeArr: [SmartOrderType] = []
        if tradeModel.tradeStatus == .change {
            typeArr = [tradeModel.condition.smartOrderType]
        } else {
            typeArr = [.breakBuy, .lowPriceBuy, .highPriceSell, .breakSell, .stopProfitSell, .stopLossSell, .tralingStop, .stockHandicap]
        }
        return typeArr
    }
}

