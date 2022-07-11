//
//  SubscribedStrategyListRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SubscribedStrategyListRequestModel: YXHZBaseRequestModel {

    override func yx_responseModelClass() -> AnyClass {
        return SubscribedStrategyListReponseModel.self
    }

    override func yx_requestUrl() -> String {
        return "/news-strategyserver/api/v3/query/mysubscribe_brief"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

}
