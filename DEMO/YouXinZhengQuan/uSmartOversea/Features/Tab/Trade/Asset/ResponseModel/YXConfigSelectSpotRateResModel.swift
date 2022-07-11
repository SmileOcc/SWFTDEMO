//
//  YXConfigSelectSpotRateResModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXConfigSelectSpotRateResModel: YXResponseModel {

    @objc var list: [YXExchangeRateModel] = []

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXExchangeRateModel.self]
    }

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.spotRateRespDTOList"];
    }

}

class YXExchangeRateModel: YXModel {

    @objc var exchangeRate: NSDecimalNumber? // 正向汇率
    @objc var exchangeRateReverse: NSDecimalNumber? // 反向汇率
    @objc var fromMoneyType = "" // 正向币种
    @objc var toMoneyType = "" // 反向币种

}
