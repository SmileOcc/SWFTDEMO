//
//  YXCreatePostRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCreatePostRequestModel: YXHZBaseRequestModel {
    @objc var content: String = ""
    @objc var pictures: [String] = []
    @objc var stock_id_list: [String] = []
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/sg/v1/create-post"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
