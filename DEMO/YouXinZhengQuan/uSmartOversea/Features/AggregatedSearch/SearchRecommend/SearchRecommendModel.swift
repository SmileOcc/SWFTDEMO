//
//  SearchRecommendModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class SearchRecommendModel: YXResponseModel {

    var stockList: [SearchSecuModel] = []

    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "stockList": "data.stock",
        ]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "stockList": SearchSecuModel.self,
        ]
    }

}
