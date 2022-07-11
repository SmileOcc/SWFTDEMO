//
//  YXUndoConditionRequestModel.swift
//  YouXinZhengQuan
//
//  Created by rrd on 2019/2/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUndoConditionRequestModel: YXJYBaseRequestModel {

    @objc var conId = ""    //条件单id
    
    
    override func yx_requestUrl() -> String {
        "/condition-center-sg/api/del-condition/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
}
