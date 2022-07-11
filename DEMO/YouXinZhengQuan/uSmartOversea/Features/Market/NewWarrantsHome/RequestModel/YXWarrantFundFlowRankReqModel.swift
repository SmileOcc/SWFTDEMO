//
//  YXWarrantFundFlowRankReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantFundFlowRankReqModel: YXHZBaseRequestModel {
    @objc var sortDirection = 1 // 排序方向，0：升序；1：降序
    @objc var pageDirection = 0 // 排序方向，0：向下翻页；1：向上翻页
    @objc var sortRule = 1 // 排序类型：1：好仓，2：认购证，3：牛证，4：淡仓，5：认沽证，6：熊证
    @objc var from = 0 // 分页起始位置
    @objc var  count = 30 // 每页数据大小
    
    override func yx_requestUrl() -> String {
        return "/quotes-derivative-app/api/v1/warrantcbbc/netinflowrank"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
