//
//  YXOtherAdvertisementRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBannerAdvertisementRequestModel: YXHZBaseRequestModel {
    
    @objc var show_page = 8
    
    override func yx_requestUrl() -> String {
        "news-configserver/api/v1/query/banner_advertisement"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Content-Type": "application/x-www-form-urlencoded"]
    }
}

class YXOtherAdvertisementRequestModel: YXHZBaseRequestModel {

    @objc var show_page = 8
    
    override func yx_requestUrl() -> String {
        return "/news-configserver/api/v1/query/other_advertisement"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
}
