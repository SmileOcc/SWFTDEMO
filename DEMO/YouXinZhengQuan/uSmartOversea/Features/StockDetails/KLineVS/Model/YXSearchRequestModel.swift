//
//  YXSearchRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit

class YXSearchRequestModel: YXHZBaseRequestModel {
    @objc var word = ""
    @objc var mkts: String? = nil
    @objc var type1: String? = nil
    @objc var size: Int = 50
    @objc var dailyMargin: Int = 0 // 用来过滤日内融数据，0：全部 1：非日内融 2： 日内融
   
    @objc override class func modelCustomPropertyMapper() -> [String : Any]? {
        return ["word": "q"]
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXSearchResponseModel.self
    }

    override func yx_requestUrl() -> String {
        return "/quotes-search/api/v4-2/stocks"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
}
