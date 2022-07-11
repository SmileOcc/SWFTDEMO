//
//  ConfigedIconModel.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class ConfigedIconModel: NSObject {

    ///icon地址（未选中）
    @objc var icon_src_nocheck:String?
    ///icon颜色（选中）
    @objc var color_nocheck:String?
    ///icon颜色（未选中）
    @objc var color_check:String?
    ///icon地址（选中）
    @objc var icon_src_check:String?
    ///导航 id
    @objc var element_id:String?
    
    
    @objc var en_name:String?
    @objc var ar_name:String?
    @objc var position:String?
}
