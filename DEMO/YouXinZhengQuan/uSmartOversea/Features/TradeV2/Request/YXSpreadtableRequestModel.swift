//
//  YXSpreadtableRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSpreadtableRequestModel: YXHZBaseRequestModel {
    
    @objc var market = ""   //市场标识
    
    override func yx_requestUrl() -> String {
        "quotes-dataservice-app/api/v2-1/spreadtable"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
}
