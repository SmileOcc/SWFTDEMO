//
//  YXNavigatable.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXNavigatable<T: ServicesViewModel> {
    var viewModel: T
    var userInfo: [String: Any]?
    required init(viewModel: T, userInfo: [String: Any]? = nil) {
        self.viewModel = viewModel
        self.userInfo = userInfo
    }
}
