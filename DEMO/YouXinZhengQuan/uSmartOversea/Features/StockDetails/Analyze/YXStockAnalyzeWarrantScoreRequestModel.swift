//
//  YXStockAnalyzeWarrantScoreRequestModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnalyzeWarrantScoreRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""

    override func yx_requestUrl() -> String {
        return "/quotes-derivative-app/api/v1/warrantcbbc/score"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
