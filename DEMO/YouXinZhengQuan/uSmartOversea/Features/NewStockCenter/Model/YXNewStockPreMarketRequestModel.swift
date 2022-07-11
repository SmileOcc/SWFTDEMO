//
//  YXNewStockPreMarketRequestModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/20.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockPreMarketRequestModel: YXJYBaseRequestModel {
    
    @objc var orderBy = "end_time"
    @objc var orderDirection = 1
    @objc var pageNum = 1
    @objc var pageSize = 30
    @objc var pageSizeZero = false
    @objc var status = 0  //Tab页类别(0-公开认购中，1-待上市)
    // 0-港股,5-美股，50-查询港美股，不传默认港股-兼容老版本app
    @objc var exchangeType = 50
    
    override func yx_requestUrl() -> String {
        return "/stock-order-server/api/ipo-list/v2"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
}
