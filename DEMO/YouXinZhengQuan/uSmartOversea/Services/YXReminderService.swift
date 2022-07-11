//
//  YXReminderService.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya

protocol HasYXReminderService {
    var reminderDataProvider: YXReminderService { get }
}

class YXReminderService: YXRequestable {
    
    typealias API = YXRemindAPI
    
    var networking: MoyaProvider<API> {
        reminderDataProvider
    }
}
