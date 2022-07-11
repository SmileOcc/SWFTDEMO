//
//  SeachRecommendRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SeachRecommendRequestModel: YXHZBaseRequestModel {

    override func yx_responseModelClass() -> AnyClass {
        return SearchRecommendModel.self
    }

    override func yx_requestUrl() -> String {
        return "quotes-search/api/v1/recommend"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

}
