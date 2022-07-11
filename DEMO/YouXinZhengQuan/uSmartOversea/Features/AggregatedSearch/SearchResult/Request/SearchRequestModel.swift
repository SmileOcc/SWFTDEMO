//
//  SearchRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchRequestAPI: YXHZBaseRequestModel {
    @objc var q = ""
    @objc var searchTypes: [Int] = []
    @objc var from: Int = 0
    @objc var size: UInt = 20
    @objc var filters = ["symbolFilter": ["excludeMktsArr": ["sh", "sz"]]]

    override func yx_responseModelClass() -> AnyClass {
        return SearchResultModel.self
    }

    override func yx_requestUrl() -> String {
        return "quotes-search/api/v1/search"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
}
