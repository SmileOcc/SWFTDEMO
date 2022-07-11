//
//  YXStockAssetResponseModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAssetResponseModel: YXResponseModel {
    @objc var result: YXAssetModel2?
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        ["result": "data"];
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["result": YXAssetModel2.self]
    }
    
}
