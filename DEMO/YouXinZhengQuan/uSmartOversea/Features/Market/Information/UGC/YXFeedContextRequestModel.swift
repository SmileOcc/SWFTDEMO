//
//  YXFeedContextRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/6/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXFeedContextRequestModel: YXHZBaseRequestModel {
    @objc var cid: String = ""
    @objc var query_token: String = ""
    @objc var show_time: String = ""
    @objc var page_size: Int = 1

    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v2/query-feed-context"
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
