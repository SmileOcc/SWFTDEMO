//
//  HCNavigatable.swift
//  URLDEMO
//
//  Created by odd on 7/4/22.
//

import UIKit
import URLNavigator

class HCNavigatable<T: ServicesViewModel> {
    var viewModel: T
    var userInfo: [String: Any]?
    required init(viewModel: T, userInfo: [String: Any]? = nil) {
        self.viewModel = viewModel
        self.userInfo = userInfo
    }
}
