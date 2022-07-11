//
//  SearchBeeRichMasterModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/3.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum SearchUserRoleType: Int {
    case normal = 1
    case pro1 = 2
    case pro2 = 4
    case pro3 = 5
}

extension SearchUserRoleType {
    var icon: String {
        switch self {
        case .normal:
            return ""
        case .pro1:
            return "VIP1"
        case .pro2:
            return "VIP2"
        case .pro3:
            return "VIP3"
        }
    }

    var title: String {
        switch self {
        case .normal:
            return ""
        case .pro1:
            return "V1 PRO"
        case .pro2:
            return "V1 PRO"
        case .pro3:
            return "V1 PRO"
        }
    }
}

/// 用户
@objcMembers class SearchBeeRichMasterModel: YXModel {
    var kolUid = "" // 用户ID
    var kolNickName = "" // 昵称
    var kolAvatar = "" // 用户头像
}

