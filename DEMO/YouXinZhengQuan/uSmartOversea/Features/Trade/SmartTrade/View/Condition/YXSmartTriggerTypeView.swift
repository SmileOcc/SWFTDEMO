//
//  YXSmartTriggerTypeView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

enum TriggerType: Int, EnumTextProtocol {
    case price
    case percent

    var text: String {
        switch self {
        case .price:
            return YXLanguageUtility.kLang(key: "trade_trigger_type_price")
        case .percent:
            return YXLanguageUtility.kLang(key: "trade_trigger_type_percent")
        }
    }
    
    static let supportTypes: [SmartOrderType] = [.breakBuy, .lowPriceBuy, .highPriceSell, .breakSell, .tralingStop]
}

class YXSmartTriggerTypeView: UIView, YXTradeHeaderSubViewProtocol {

    private lazy var titleLabel: UILabel = {
        let label = UILabel(with: QMUITheme().textColorLevel3(),
                            font: UIFont.systemFont(ofSize: 12),
                            text: YXLanguageUtility.kLang(key: "trade_trigger_type"))
        return label
    }()
    
    private var segmentView: YXTradeSegmentView<TriggerType>!
    convenience init(_ selectType: TriggerType = .price, selectedBlock:((TriggerType) -> Void)?) {
        self.init()
        
        segmentView = YXTradeSegmentView(typeArr: [.price, .percent], selected: selectType, selectedBlock: selectedBlock)
        segmentView.itemSize = CGSize(width: 65, height: 24)
        
        addSubview(segmentView)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(segmentView)
            make.left.equalToSuperview().offset(16)
        }
        
        segmentView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(130)
            make.height.equalTo(24)
            make.top.equalTo(8)
        }
        
        contentHeight = 40
    }
    
    var triggerType: TriggerType {
        segmentView.selectedType
    }
    
    func updateType(_ selected: TriggerType? = nil) {
        segmentView.updateType(selected: selected)
    }
}
