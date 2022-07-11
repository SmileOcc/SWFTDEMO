//
//  NewChannelApis.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/9.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

class OSSVNewInApi:OSSVBasesRequests{
    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(.newInPath)
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
}

