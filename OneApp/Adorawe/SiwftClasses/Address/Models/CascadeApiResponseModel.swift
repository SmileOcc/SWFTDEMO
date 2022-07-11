//
//  CascadeApiResponseModel.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import ObjectMapper

class CascadeApiResponseModel: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result.list"]
        statusCode <- map["statusCode"]
        message <- map["message"]
    }
    
    var result:[AddressItemModel]?
    var statusCode:Int?
    var message:String?
}

class AddressItemModel: Mappable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        address_id <- map["address_id"]
        country_code <- map["country_code"]
        address_name <- map["address_name"]
        have_children <- map["have_children"]
        need_zip_code <- map["need_zip_code"]
        map_check     <- map["map_check"]
    
    }
    
    var address_id:String?
    var country_code:String?
    var address_name:String?
    var have_children:String?
    ///0 -->非必填   1-->必填
    var need_zip_code:Int?
    //0不展示， 1展示  定位图标
    var map_check:Int?
    
}
