//
//  YXSmartPushSettnsModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartPushSettingsModel: Codable {
    let uid: String?
    let list: YXSmartPushSettingList?
}

class YXSmartPushSettingList: Codable {
    var group: [YXSmartPushSettingGroup]?
}

class YXSmartPushSettingGroup: Codable {
    let groupName: String?
    let groupID: Int?
    var signal: [YXSmartPushSettingSignal]?
    
    enum CodingKeys: String, CodingKey {
        case groupName = "GroupName"
        case groupID = "GroupId"
        case signal
    }
}

class YXSmartPushSettingSignal: Codable {
    let signalName: String?
    var signalID, defult: Int?
    
    enum CodingKeys: String, CodingKey {
        case signalName = "SignalName"
        case signalID = "SignalId"
        case defult = "Defult"
    }
}
