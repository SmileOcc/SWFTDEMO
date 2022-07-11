//
//  YXFractionalTradeTypeView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2022/4/22.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit


class YXFractionalTradeTypeView: UIView, YXTradeHeaderSubViewProtocol {
    
    var tradeModel: TradeModel? {
        didSet {
            if let tradeModel = tradeModel, tradeModel.symbol.count > 0 {
            } else {
            }
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel(with: QMUITheme().textColorLevel3(),
                            font: UIFont.systemFont(ofSize: 14),
                            text: YXLanguageUtility.kLang(key: "trading_type"))
        return label
    }()
    
    
    private var segmentView: YXTradeSegmentView<FractionalTradeType>!
    convenience init(_ selectType: FractionalTradeType = .amount, selectedBlock:((FractionalTradeType) -> Void)?) {
        self.init()
        
        segmentView = YXTradeSegmentView(typeArr: [.amount, .shares], selected: selectType, selectedBlock: selectedBlock)
        segmentView.itemSize = CGSize(width: 105, height: 28)
        segmentView.useNewStyle()
        
        addSubview(titleLabel)
        addSubview(segmentView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(28)
        }
        
        segmentView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(210)
            make.top.equalTo(16)
            make.height.equalTo(28)
        }

        contentHeight = 44
    }
    
    func updateType(_ typeArr: [FractionalTradeType]? = [.amount, .shares], selected: FractionalTradeType? = nil) {
        segmentView.updateType(typeArr, selected: selected)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
