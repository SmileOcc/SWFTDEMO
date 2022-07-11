//
//  YXSquareStockeCommentRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSquareStockeCommentRequestModel: YXHZBaseRequestModel {
    @objc var stock_id_list = [""]
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/v1/query-post-newest"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXSquareHotDiscussionRequestModel: YXHZBaseRequestModel {
    
    @objc var limit = 20
    @objc var offset = 0
    
    override func yx_requestUrl() -> String {
        return "/zt-stock-discussion-apiserver/api/v1/query-hot-post"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
