//
//  YXMarketIconLabel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc class YXMarketIconLabel: QMUILabel {
    
    @objc var market: String? {
        didSet {
            if let m = market {
                let marketType = YXMarketType.init(rawValue: m.lowercased())
                self.backgroundColor = marketType?.iconBackgroundColor
                if marketType == .Cryptos {
                    self.text = "B"
                }else if marketType == .USOption {
                    self.text = YXMarketType.US.rawValue.uppercased()
                }else if marketType == .SG{
                    self.text = YXMarketType.SG.rawValue.uppercased()
                }
                else {
                    self.text = marketType?.rawValue.uppercased()
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentEdgeInsets = UIEdgeInsets.init(top: 1, left: 2, bottom: 1, right: 2)
        font = .systemFont(ofSize: 8, weight: .medium)
        textAlignment = .center
        layer.cornerRadius = 2
        layer.masksToBounds = true
        textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
