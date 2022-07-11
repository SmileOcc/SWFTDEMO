//
//  YXBondTodayOrderResponseModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/8/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXBondTodayOrderResponseModel: YXResponseModel {
    @objc var list: [YXBondOrderModel2] = []
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXBondOrderModel2.self]
    }
}
