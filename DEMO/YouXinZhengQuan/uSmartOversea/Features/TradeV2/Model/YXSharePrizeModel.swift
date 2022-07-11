//
//  YXSharePrizeModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXSharePrizeModel: YXResponseModel {
    @objc var isWin = false
    @objc var displayName = ""
    @objc var picUrl = ""

    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "isWin": "data.isWin",
            "displayName": "data.displayName",
            "picUrl": "data.picUrl"
        ]
    }
}
