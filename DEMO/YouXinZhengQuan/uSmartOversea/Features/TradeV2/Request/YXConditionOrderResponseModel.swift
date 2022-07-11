//
//  YXConditionOrderResponseModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/2/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXConditionOrderResponseModel: YXResponseModel {
    @objc var list: [YXConditionOrderModel] = []
    @objc var pageNum: Int = 0
    @objc var pageSize: Int = 0
    @objc var total: Int = 0
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.list",
                "total": "data.total",
                "pageSize": "data.pageSize",
                "pageNum": "data.pageNum"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXConditionOrderModel.self]
    }
}
