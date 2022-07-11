//
//  YXTradeStatementListReqModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum TradeStatementType:Int {
    //结单类型 0.全部结单 1.日结单 2.月结单
    case all = 0
    case day = 1
    case month = 2

}


extension TradeStatementType: EnumTextProtocol {
    var text:String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "all_StatementList")
        case .day:
            return YXLanguageUtility.kLang(key: "statement_day")
        case .month:
            return YXLanguageUtility.kLang(key: "statement_month")
        default:
            return ""
        }
    }
    
    var textColor:UIColor {
        var color:UIColor = .clear
        switch self {
        case .day:
            color = UIColor.qmui_color(withHexString: "#2177FF")!
        case .month:
            color = UIColor.qmui_color(withHexString: "#FFBA00")!
        default:
            break
            
        }
        return color
    }
    
    var hadLine:Bool {
        return false
    }
}


@objc enum TradeStatementLanguageType:Int {
    //结单语言，1简体 2繁体 3英文
    case chinese = 1
    case traditional = 2
    case en = 3
}

extension  TradeStatementLanguageType: EnumTextProtocol {
    var text:String {
        switch self {
        case .chinese:
            return YXLanguageUtility.kLang(key: "mine_simplified")
        case .traditional:
            return YXLanguageUtility.kLang(key: "mine_traditional")
        case .en:
            return YXLanguageUtility.kLang(key: "mine_english")
        default:
            return ""
        }
    }
    var hadLine:Bool {
        return true
    }
}


@objc enum TradeStatementAccountType:Int {
    // 账户类型 1正股 2日内融 3期权 4跟投 5沽空
    case stock = 1
    case inday = 2
    case option = 3
    case vote = 4
    case shortSell = 5
}

extension TradeStatementAccountType: EnumTextProtocol {
    var text:String {
        switch self {
        case .stock:
            return YXLanguageUtility.kLang(key: "stock_Account")
        case .inday:
            return YXLanguageUtility.kLang(key: "day_margin_account")
        case .option:
            return YXLanguageUtility.kLang(key: "options_account")
        case .vote:
            return YXLanguageUtility.kLang(key: "all_allow_Account")
        case .shortSell:
            return YXLanguageUtility.kLang(key: "short_sell_account")
        default:
            return ""
        }
    }
    
    var icon:String {
        switch self {
        case .stock:
            return "state_trade"
        case .inday:
            return "state_inday"
        case .option:
            return "state_usOption"
        case .vote:
            return "state_all"
        case .shortSell:
            return ""
        default:
            return ""
        }
    }
    
    var hadLine:Bool {
        return false
    }
}

@objc enum TradeStatementTimeType:Int {
    // 时间范围 1.近一个月 3.近三月 6.近六月
    case sixMonth = 6
    case threeMonth = 3
    case oneMonth = 1
    
    case custom = 0  //自定义
}

extension TradeStatementTimeType: EnumTextProtocol, CaseIterable {
    var text:String {
        switch self {
        case .oneMonth:
            return YXLanguageUtility.kLang(key: "recently_one_month")
        case .threeMonth:
            return YXLanguageUtility.kLang(key: "recently_three_month")
        case .sixMonth:
            return YXLanguageUtility.kLang(key: "six_month")
        case .custom:
            return YXLanguageUtility.kLang(key: "history_custom_date")
        }
    }
}

//MARK:查询用户结单列表
class YXTradeStatementListReqModel: YXJYBaseRequestModel {
    
    @objc var accountType:TradeStatementAccountType = .stock
   
    @objc var endTime:Int64 = 0 // 结单时间止
    @objc var startTime:Int64 = 0 // 结单时间起

    @objc var statementType:TradeStatementType = .all // 结单类型
    @objc var timeScope:TradeStatementTimeType = .threeMonth

    @objc var pageNum:Int = 1 //   页码,默认1
    @objc var pageSize:Int = 20  //每页数据数量,默认20
    
    override func yx_requestUrl() -> String {
        return "/statement-center-sg/api/query-user-statement-list/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXTradeStatementModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}

//MARK:查询用户结单语言
class YXTradeStatementQueryLanguangeReqModel: YXJYBaseRequestModel {

    override func yx_requestUrl() -> String {
        return "/statement-center-sg/api/query-user-statement-language/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}


//MARK:修改用户结单语言
class YXTradeStatementChangeLanguangeReqModel: YXJYBaseRequestModel {

    @objc var  statementLanguage:TradeStatementLanguageType = .chinese  //结单语言，1简体 2繁体 3英文
    override func yx_requestUrl() -> String {
        return "/statement-center-sg/api/change-user-statement-language/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.POST
    }
    
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        return ["Content-Type": "application/json"]
    }
}
