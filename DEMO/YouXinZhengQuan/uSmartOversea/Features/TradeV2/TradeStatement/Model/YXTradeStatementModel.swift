//
//  YXTradeStatementModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeStatementModel: YXResponseModel {
    
    @objc var list:[YXStatementListItemModel] = []  //数据
    @objc var pageNum:Int32 = 0   //当前页码int32
    @objc var pageSize:Int32 = 0   //分页大小int32
    @objc var pages:Int32 = 0  //页码数int32
    @objc var total:Int32 = 0  //记录数int64
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list",
            "pageNum" : "data.pageNum",
            "pageSize" : "data.pageSize",
            "pages" : "data.pages",
            "total" : "data.total"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXStatementListItemModel.self,
        ]
    }
}


class YXStatementListItemModel: YXModel {
    @objc var account:String = ""   //  账户号码string
    @objc var accountType:TradeStatementAccountType = .stock  //  账户类型 1正股 2日内融 3期权 4跟投 5沽空int32
    @objc var cosUrl:String = "" //   结单文件地址string
    @objc var statementDate:String = ""    //结单时间date-time
    @objc var statementType:TradeStatementType = .day   //  结单类型 1.日结单 2.月结单
    @objc var market: String = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
}

class YXStatementListSectionModel: YXModel  {
    @objc var time:String = ""
    
    @objc var list:[YXStatementListItemModel] = []
}
