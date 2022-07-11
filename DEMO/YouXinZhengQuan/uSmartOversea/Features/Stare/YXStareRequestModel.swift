//
//  YXStareRequestModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


// MARK: - 首页的列表
class YXStareRequestModel: YXHZBaseRequestModel {

    
    // 类型， 0：港股市场，1：美股市场，2：A股市场，3：自选/持仓
    @objc var type = 0
    // 子类型 0：全部，1：行业，2：次新股，3：指数，4：持仓，5：自选
    @objc var subType = 0
    // 叶子标识，如：请求具体行业的时候，这里传的是行业的id，列如shBK0001 ，指数则传递指数id
    @objc var leafIndentifer = ""
    //
    @objc var count = 0
    // 起始seqNum,0表示从最新数据开始,后续把列表的最后一个对象的SeqNum带入
    @objc var seqNum = 0
    // unix时间戳
    @objc var unixTime = 0
    
    @objc var stockList = [Any]()
    
    override func yx_requestUrl() -> String {
        "/quotes-smart/api/v2/signal/list"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}

// MARK: - 信号列表
class YXStareSettinglistRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        "/quotes-smart/api/v2/signal/settinglist"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}

// MARK: - 信号设置
class YXStareUpdateSettingListtRequestModel: YXHZBaseRequestModel {
    
    @objc var list = [Any]()

    override func yx_requestUrl() -> String {
        "/quotes-smart/api/v2/signal/setting"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}

// MARK: - 推送列表
class YXStarePsuhSettinglistRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        "/quotes-smart/api/v2/push/settinglist"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}

// MARK: - 设置推送
class YXStareUpdatePsuhSettinglistRequestModel: YXHZBaseRequestModel {
    // 设置类型，0：自选股，1：行业列表，2：智能筛选，3：次新股，4：微信，5：持仓
    @objc var type = 0
    
    @objc var list = [Any]()
    
    override func yx_requestUrl() -> String {
        "/quotes-smart/api/v2/push/setting"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }

}


class YXStockStareIndustryRequestModel: YXHZBaseRequestModel {

    @objc var version_a: Int = 0
    @objc var version_hk: Int = 0
    @objc var version_us: Int = 0

    override func yx_requestUrl() -> String {
        "/news-basicinfo/api/v1/industrycategory/stocknum"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}

class YXStockStareIndexRequestModel: YXHZBaseRequestModel {

    @objc var version: Int = 0

    override func yx_requestUrl() -> String {
        "/news-basicinfo/api/v1/indexstocknum"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


class YXBrokerSellDetailRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""
    // 翻页方向，0：由最新的时间开始，1：由最老的时间开始
    @objc var direction = ""
    // 下一页的起始点，由上一页的结果返回
    @objc var nextPageRef: String?
    override func yx_requestUrl() -> String {
        "/quotes-analysis-app/api/v1/sellingratio"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}

class YXBrokerHKVolumnDetailRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""
    // 翻页方向，0：由最新的时间开始，1：由最老的时间开始
    @objc var direction = ""
    // 下一页的起始点，由上一页的结果返回
    @objc var nextPageRef: String?
    override func yx_requestUrl() -> String {
        "/quotes-analysis-app/api/v1/hshkconnratio/list"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}

class YXBrokerHKVolumnChangeRequestModel: YXHZBaseRequestModel {

    @objc var market = ""
    @objc var symbol = ""
    override func yx_requestUrl() -> String {
        "/quotes-analysis-app/api/v1/hshkconnratio/change"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


class YXStockAnalyzeDiagnoseScoreRequestModel: YXHZBaseRequestModel {

    @objc var symbol = ""

    override func yx_requestUrl() -> String {
        "/news-stockdiagnosis/api/v1/query/diagnosescore-app"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    // 暂时
    //    override func yx_baseUrl() -> String {
    //        return "http://hz-dev.yxzq.com"
    //    }
}


class YXStockAnalyzeDiagnosenumberRequestModel: YXHZBaseRequestModel {

    override func yx_requestUrl() -> String {
        "/news-stockdiagnosis/api/v2/query/diagnosenumber"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}


class YXStockAnalyzeTechnicalInsightRequestModel: YXHZBaseRequestModel {

    @objc var stockId = ""
    override func yx_requestUrl() -> String {
        "/zt-gold-stock-apiserver-dolphin/api/v1/stock-pick/form-insight-brief"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
}
