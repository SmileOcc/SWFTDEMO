//
//  YXStockFilterTabViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterTabViewModel: YXViewModel {

    var market = kYXMarketHK
    var operateType: YXStockFilterOperationType = .new
    var editModel: YXStockFilterUserFilterList?
    override init(services: YXViewModelServices, params: [AnyHashable : Any]?) {
        super.init(services: services, params: params)
        if let tempMarket = params?["market"] as? String{
            self.market = tempMarket
        }

        if let model = params?["userGroup"] as? YXStockFilterUserFilterList {
            operateType = .edit
            editModel = model
        }
    }
}
