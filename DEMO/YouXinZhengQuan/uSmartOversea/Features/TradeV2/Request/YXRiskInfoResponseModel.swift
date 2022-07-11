//
//  YXRiskInfoResponseModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXRiskInfo: NSObject {
    @objc var desc: String = ""
    @objc var name: String = ""
    @objc var radio: String = ""
    @objc var value: Int = 0
}

class YXRiskInfoResponseModel: YXResponseModel {
    @objc var list: [YXRiskInfo] = []
    @objc var total: Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["list": YXRiskInfo.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["list": "data.list",
                "total": "data.total"];
    }
}
