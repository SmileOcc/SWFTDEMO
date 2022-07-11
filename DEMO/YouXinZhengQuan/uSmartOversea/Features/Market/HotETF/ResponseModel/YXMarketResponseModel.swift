//
//  YXMarketResponseModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketResponseModel: YXResponseModel {
    @objc var item: YXMarketDetailItem2?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        ["item": "data"]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["item": YXMarketDetailItem2.self]
    }
}
 
