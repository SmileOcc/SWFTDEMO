//
//  YXA-HKRankViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXA_HKRankPageViewModel: YXViewModel {
    var marketType: YXA_HKMarket!
    
    init(services: YXViewModelServices, market: YXA_HKMarket) {
        super.init(services: services, params: [:])
        marketType = market
    }
}
