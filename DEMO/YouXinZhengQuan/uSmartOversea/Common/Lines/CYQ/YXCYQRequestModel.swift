//
//  YXCYQRequestModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCYQRequestModel: YXHZBaseRequestModel {

    @objc var id = "" //股票id,如：hk00700
    @objc var nextPageRef: UInt64 = 0 //起始时间戳，如：20181129151500000 ，0表示从最新数据开始，除0之外，请求下一页数据，将上一次结果的nextPageRef带回
    @objc var count: Int = 1 //分页条数  批量120个自然日传88
    @objc var rights: Int = 1 //复权类型，0：不复权，1：前复权，2：后复权

    override func yx_requestUrl() -> String {
        "/quotes-dataservice-app/api/v1/positioncost"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
