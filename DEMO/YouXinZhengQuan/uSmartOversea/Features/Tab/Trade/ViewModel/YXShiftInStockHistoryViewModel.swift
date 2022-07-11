//
//  YXShiftInStockHistoryViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXShiftInStockHistoryViewModel: YXWebViewModel {
    //交易类别(0-香港,5-美股)
    var exchangeType: YXExchangeType = .hk
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        
        if let exchangeType = dictionary["exchangeType"] {
            self.exchangeType = exchangeType as? YXExchangeType ?? YXExchangeType.hk
        }
    }
}
