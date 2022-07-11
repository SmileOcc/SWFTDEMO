//
//  YXAccountAssetReqModel.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAccountAssetReqModel: YXJYBaseRequestModel {
    @objc var userId = ""
    @objc var accountBusinessType = 100
    @objc var moneyType = ""

    override func yx_requestUrl() -> String {
        "/asset-center-dolphin/api/app-stockHoldAsset/v3"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


class YXCconfigMortgageRateQueryReqModel: YXJYBaseRequestModel {
    @objc var stockCode = ""
    @objc var exchangeType = ""

    override func yx_requestUrl() -> String {
//        if YXConstant.appTypeValue == .OVERSEA {
//            return "/asset-center-dolphin/api/app-config-configMortgageRate-query/v1"
//        } else if YXConstant.appTypeValue == .OVERSEA_SG  {
//            return "/asset-center-sg/api/app-config-configMortgageRate-query/v1"
//        }
        return "/asset-center-dolphin/api/app-config-configMortgageRate-query/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
}

/// 查询即期汇率配置
class YXConfigSelectSpotRateReqModel: YXJYBaseRequestModel {

    @objc var sourceMoneyType = ""
    @objc var targetMoneyType = ""

    override func yx_requestUrl() -> String {
        return "/asset-center-dolphin/api/app-config-selectSpotRate"
    }

    override func yx_responseModelClass() -> AnyClass {
        YXConfigSelectSpotRateResModel.self
    }

}
