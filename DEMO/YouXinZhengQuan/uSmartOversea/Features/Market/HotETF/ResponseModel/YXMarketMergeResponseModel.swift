//
//  YXMarketMergeResponseModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketMergeResponseModel: YXResponseModel {
    @objc var list: [[String: Any]]?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        ["list": "data.list"]
    }
    
}
