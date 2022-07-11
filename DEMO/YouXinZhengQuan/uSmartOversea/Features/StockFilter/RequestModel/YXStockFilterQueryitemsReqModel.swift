//
//  YXStockFilterQueryitemsReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterQueryitemsReqModel: YXHZBaseRequestModel {
    @objc var market = "hk"
    
    override func yx_requestUrl() -> String {
        return "/quotes-smart/api/v1/screener/queryitems"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXStockPickerResultRequestModel: YXHZBaseRequestModel {

    @objc var market: String = "hk"
    @objc var sortKey: String = "pctchng" //默认涨跌幅排序
    @objc var asc: Bool = false //是否升序排列
    @objc var justCount: Bool = false //是否只返回个数
    @objc var from: Int = 0  //分页起始位置
    @objc var size: Int = 30 //分页大小
    @objc var groups: [YXStokFilterGroup]?


    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func yx_requestUrl() -> String {
        return "/quotes-smart/api/v1/screener/query"
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}


class YXStockFilterSaveResultRequestModel: YXHZBaseRequestModel {

    @objc var market: String = "hk"
    @objc var optType: Int = 1 //操作类型，0：新增、1：更新、2：删除
    @objc var id: Int64 = 0 //次筛选的唯一标识，1：更新、2：删除必须传。
    @objc var name: String = "" //名称。
    @objc var groups: [YXStokFilterGroup]?


    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func yx_requestUrl() -> String {
        return "/quotes-smart/api/v1/screener/queryedit"
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}

class YXStockFilterQueryUserRequestModel: YXHZBaseRequestModel {

    @objc var market: String = "hk" //市场，hk（港股）、us（美股）、hs（A股）,不填则是全部

    override func yx_requestMethod() -> YTKRequestMethod {
        return .GET
    }

    override func yx_requestUrl() -> String {
        return "/quotes-smart/api/v1/screener/userqueries"
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
