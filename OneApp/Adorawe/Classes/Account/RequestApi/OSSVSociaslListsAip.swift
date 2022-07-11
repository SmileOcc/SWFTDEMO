//
//  OSSVSociaslListsAip.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/12.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVSociaslListsAip: OSSVBasesRequests {

    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(String.socialList)
    }
    
    override func requestMethod() -> STLRequestMethod {
        .POST
    }
    
    override func requestSerializerType() -> STLRequestSerializerType {
        .JSON
    }
    
    override func enableAccessory() -> Bool {
        false
    }
    
}
