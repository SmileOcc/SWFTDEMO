//
//  YXOptionalBannerRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXOptionalBannerRequestModel: YXHZBaseRequestModel {
    @objc var show_page: Int = 14
    override func yx_requestUrl() -> String {
        return "/news-configserver/api/v1/query/banner_advertisement"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXOptionalBannerResponseModel.self
    }
}
