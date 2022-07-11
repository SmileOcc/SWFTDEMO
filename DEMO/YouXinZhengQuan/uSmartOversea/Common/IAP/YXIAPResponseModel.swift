//
//  YXIAPResponseModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/3/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXIAPResponseModel: YXResponseModel {
    @objc var paymentNo: Int64 = 0
    @objc var flag = false
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["paymentNo": "data.paymentNo",
                "flag": "data.flag"];
    }
}
