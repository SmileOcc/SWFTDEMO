//
//  YXOrderResponseModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderResponseModel: YXResponseModel {
    @objc var list: [YXOrderModel] = []
//    @objc var pageNum: Int = 0
//    @objc var pageSize: Int = 0
//    @objc var total: Int = 0
//    @objc var nowDate: String = ""
    @objc var processingNum: Int = 0
    @objc var tradedNum: Int = 0
    @objc var cancellNum: Int = 0
    @objc var allCount: Int = 0
    @objc var otherCount: Int = 0

    
//    @objc class func modelCustomPropertyMapper() -> [String : Any] {
//        ["list": "data.todayEntrustByAppResponseList",
//         "processingNum": "data.processingNum",
//         "tradedNum": "data.tradedNum",
//         "cancellNum": "data.cancellNum",
//         ];
//    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.dataList",
         "allCount": "data.allCount",
         "tradedNum": "data.tradedCount",
         "cancellNum": "data.otherCount",
         "processingNum": "data.processCount",

         ];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXOrderModel.self]
    }
}
