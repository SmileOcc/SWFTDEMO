//
//  YXQuoteWebViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/7/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXQuoteWebViewModel: YXWebViewModel {

    var market: String = ""
    var symbol: String = ""
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        
        if let market = dictionary["market"] as? String {
            self.market = market
        }
        
        if let symbol = dictionary["symbol"] as? String {
            self.symbol = symbol
        }
    }
}
