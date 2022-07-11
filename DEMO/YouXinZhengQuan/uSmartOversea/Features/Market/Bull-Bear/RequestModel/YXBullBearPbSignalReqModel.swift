//
//  YXBullBearPbSignalReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearPbSignalReqModel: YXHZBaseRequestModel {
    @objc var type = ""
    @objc var nextPageSeqNum = 0
    @objc var nextPageUnixTime = 0
    @objc var size = 20
    @objc var idString: String?
    
    override func yx_requestUrl() -> String {
        "/quotes-derivative-app/api/v1/warrantcbbc/pbsignal"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override class func modelCustomPropertyMapper() -> [String : Any] {
        ["idString": "id"];
    }
}
