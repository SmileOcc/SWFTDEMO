//
//  Models.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/3.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import UIKit

class AddressGroupModel: NSObject {
    var cells:[UITableViewCell]?
    var groupTitle:String?
}

///范型分组
class GroupedModel<T>:NSObject{
    var key:String?
    var list:[T] = []
}

