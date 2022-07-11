//
//  YXShareOptionsDateResModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsDateResModel: YXModel {
    @objc var list : [YXShareOptionsDateItem] = []
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXShareOptionsDateItem.self]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
}

class YXShareOptionsDateItem: YXModel {
    @objc var maturityDate : String?
    @objc var remainingTime : Int = 0
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}
