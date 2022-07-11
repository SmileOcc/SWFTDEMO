//
//  YXStrongNoticeService.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import UIKit
import Moya

protocol HasYXMessageCenterService {
    var messageCenterService: YXMessageCenterService { get }
}

@objcMembers class YXMessageCenterService: NSObject, YXRequestable {
    static let shared = YXMessageCenterService()
    
    private override init() {
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
    
    @objc public class func buildUrlParam(url : String) -> String {
        let result = url.replacingOccurrences(of: YXNativeRouterConstant.YXZQ_SCHEME_V1, with: YXNativeRouterConstant.YXZQ_SCHEME)
        return "\"showPageUrl\":\"\(result)\""
    }
    
    typealias API = YXMessageCenterAPI
    
    var networking: MoyaProvider<API> {
        messageCenterDataProvider
    }
}
