//
//  OSSVNewInLoadMoreAPI.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVNewInLoadMoreAPI: OSSVBasesRequests {
    
    var specialId:String
    var type:String
    var date:String
    var page:Int
    var pageSize:Int
    
    init(specialId:String,type:String,date:String,page:Int,pageSize:Int) {
        self.specialId = specialId
        self.type = type
        self.date = date
        self.page = page
        self.pageSize = pageSize
    }
    
    
    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(.newInMore)
    }
    
    override func requestMethod() -> STLRequestMethod {
        .POST
    }
    
    override func requestSerializerType() -> STLRequestSerializerType {
        .JSON
    }
    
    override func enableAccessory() -> Bool {
        true
    }
    
    override func requestParameters() -> Any! {
        return [
            "specialId":specialId,
            "type":type,
            "date":date,
            "page":page,
            "pageSize":pageSize
        ]
    }
}
