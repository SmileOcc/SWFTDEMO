//
//  OSSVSocialsPlatformsModel.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/12.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import ObjectMapper

class OSSVSocialsPlatformsModel: NSObject, Mappable {
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        social_name <- map["social_name"]
        icon_link <- map["icon_link"]
        jump_link <- map["jump_link"]
    }
    
    @objc var social_name: NSString?
    @objc var icon_link: NSString?
    @objc var jump_link: NSString?
    //自定义
    @objc var type:NSInteger = 0
}
