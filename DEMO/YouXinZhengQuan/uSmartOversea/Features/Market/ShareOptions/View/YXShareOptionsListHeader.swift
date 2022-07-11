//
//  YXShareOptionsListHeader.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsListHeader: UIView {
    
    let itemTypes: [YXShareOptinosItem] = [.latestPrice, .pctchng, .bidPrice, .askPrice, .netchng, .volume, .amount, .openInt, .premium, .impliedVolatility, .delta, .gamma, .vega, .theta, .rho]
    
    var optionsType: YXShareOptionsType = .call

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
