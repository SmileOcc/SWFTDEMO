//
//  NewInLoadMoreModel.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import ObjectMapper

class OSSVNewInLoadMoreResp: Mappable {
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        statusCode <- map["statusCode"]
        message <- map["message"]
    }
    
    var result:OSSVNewInLoadMoreResultModel?
    var statusCode:Int?
    var message:String?
    
    
}

class OSSVNewInLoadMoreResultModel: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        pageSize <- map["pageSize"]
        specialId <- map["specialId"]
        type <- map["type"]
        currentPage <- map["currentPage"]
        total <- map["total"]
        ranking <- map["ranking"]
        totalPage <- map["totalPage"]
        channelSort <- map["channelSort"]
        goodsList <- map["goodsList"]
    }
    
    
    var pageSize:Int?
    var specialId:Int?
    var type:String?
    var currentPage:Int?
    var total:String?
    var ranking:Int?
    var totalPage:Int?
    var channelSort:Int?
    var goodsList:[GoodsItem]?
    
    ///状态管理
    var section:Int!
    var timeIndex:Int!
    var hasMore:Bool{
        return (totalPage ?? 0) > (currentPage ?? 0)
    }
}
