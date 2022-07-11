//
//  YXSecuGroupResponseModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXSecuGroupResponseModel: YXResponseModel {
    @objc var sortflag: UInt32 = 0
    @objc var version: Int = 0
    @objc var group: [YXSecuGroup] = []
    @objc var lastDealGroup: YXSecuGroup?

    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        ["sortflag": "data.sortflag", "version": "data.version", "group": "data.group", "lastDealGroup": "data.last_deal_group"]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["group": YXSecuGroup.self, "lastDealGroup": YXSecuGroup.self]
    }
}
