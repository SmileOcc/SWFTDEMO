//@strongify(self)//  YXQuoteApi.swift
//  uSmartOversea
//
//  Created by ellison on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

//let quotesDataProvider = MoyaProvider<YXQuotesDataAPI>(requestClosure: requestTimeoutClosure)

let quotesDataProvider = MoyaProvider<YXQuotesDataAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXQuotesDataAPI {

    case timeLine(_ id: String, _ type: String?, _ level: QuoteLevel?)
    case batchTimeLine(_ ids: [String], _ days: String?, _ level: QuoteLevel?)
    case marketStatus(_ ids: [String], _ level: QuoteLevel?)
    case detail(_ ids: [String], _ props: [String]?, _ level: QuoteLevel?)
    case quote(_ ids: [String], _ props: [String]?, _ level: QuoteLevel?)
    case kline(_ id: String, _ type: String?, _ direction: String?, _ level: QuoteLevel?)
    case companyIntro(_ stock: String)
    case articleInfo(_ stockKey: String, _ articleId: String, _ pageSize: Int, _ enlangType: Int?)
    case financialIncomes(_ stock: String, quartertype: String?, isHS: Bool)
    case financialBalance(_ stock: String, quartertype: String?, isHS: Bool)
    case financialCashflow(_ stock: String, quartertype: String?, isHS: Bool)
    case spreadTable(market :String)
    case hkwarrant(_ stock: String )
    case ygExit(_ stockCode: String, _ market: String)
    case newStockDetail(_ stockCode: String, _ exchangeType: Int)
    case announceInfo(_ index: Int, _ num: Int, _ type: Int ,_ stock: String)
    case HSAnnounceInfo(_ index: Int, _ num: Int, _ type: Int ,_ stock: String)
    case warrants(_ market: String, _ security_code: String, _ from: Int, _ count: Int, _ sort_type: Int, _ sort_direction: Int, _ filter: NSDictionary, _ page_direction: Int)
    case highTimeSharing(_ stockCode: String, _ days: String,  _ level: QuoteLevel)
    case highKline(_ stockCode: String, _ type: String, _ start: String, _ direction: String, _ count: Int, _ level: QuoteLevel)
    case tickData(_ stockCode: String, _ start: String, _ count: String, _ tradeTime: String, _ level: QuoteLevel)
    case getBrokerList(version: Int)
    case listBalancesheet(_ stock: String, quarter: String, periodtype: String) //资产负债 List
    case listIncomestatement(_ stock: String, quarter: String, periodtype: String) //利润表 List
    case listCashFlow(_ stock: String, quarter: String, periodtype: String) //现金流表 List
    case AListFinanceindicators(_ stock: String, quarter: String) //A股 资产负债、利润、现金流表 List
    case hsListProfit(_ stock: String, quarter: String) //A股 利润 List
    case hsListAsset(_ stock: String, quarter: String) //A股 资产负债 List
    case hsListCashFlow(_ stock: String, quarter: String) //A股 现金流表 List
    case getStockBond(stockCode: String, stockMarket: Int) //stockMarket : 1-港股，2美股
    case getFund(_ moduleBitmap: Int) //stockMarket : 1-港股，2美股
    case marketFinancial(_ stock: String, quarter: String) //主要指标
    case stockValue(_ stockId: String)  //价值掘金
    case technical(_ stockId: String)  //技术洞察
    case eventReminder(_ code: String) //大事提醒
    case closeEventReminder(_ code: String, eventId: String)  //关闭大事提醒某个事件
    case announceEventReminder(_ code: String) //大事提醒
    case importantNews(_ stock: String) //资讯提醒
    case optionAggravate(market: String, code: String) //期权张数
    case shortSell(_ code: String, accountLevel: Int)
    case articleInfoBylang(_ stockKey: String, _ lastTime: Int, _ pageSize: Int, _ lang: Int, _ market: String?) //个股资讯列表(全平台,用户选择语言)

}

extension YXQuotesDataAPI: YXTargetType {
    public var path: String {
        switch self {
        case .detail:
            return servicePath + "detail"
        case .quote(_, _, _):
            return servicePath + "quote"
        case .timeLine:
            return servicePath + "hktimesharing"
        case .batchTimeLine:
            return servicePath + "batchtimesharing"
        case .marketStatus:
            return servicePath + "status"
        case .kline:
            return servicePath + "hkkline"
        case .companyIntro:
            return servicePath + "companyprofile"
        case .articleInfo:
            return servicePath + "query/sgindividual"
        case .financialIncomes:
            return servicePath + "incomestatementchart"
        case .financialBalance:
            return servicePath + "balancesheetchart"
        case .financialCashflow:
            return servicePath + "cashflowchart"
        case .spreadTable(_):
            /*   /quotes-dataservice-app/api/v2/spreadtable    */
            return servicePath + "spreadtable"
        case .hkwarrant(_):
            return servicePath + "hkwarrant"
        case .ygExit:
            return servicePath + ""
        case .newStockDetail(_,_):
            return servicePath + ""
        case .announceInfo(_, _, _, _):
            return servicePath + "announcementinfo"
        case .HSAnnounceInfo(_, _, _, _):
            return servicePath + "a/announcement"
        case .warrants(_, _, _, _, _, _, _, _):
            return servicePath + ""
        case .highTimeSharing(_, _, _):
            return servicePath + "timesharing"
        case .highKline(_, _, _, _, _,_):
            return servicePath + "kline"
        case .tickData:
            return servicePath + "tick"
        case .getBrokerList:
            return servicePath + "query/broker_release_list"
        case .listBalancesheet:
            return servicePath + "balancesheet"
        case .listIncomestatement:
            return servicePath + "incomestatement"
        case .listCashFlow:
            return servicePath + "cashflow"
        case .AListFinanceindicators:
            return servicePath + "a/financeindicators"
        case .hsListProfit:
            return servicePath + "a/incomestatementbrief"
        case .hsListAsset:
            return servicePath + "a/balancesheetbrief"
        case .hsListCashFlow:
            return servicePath + "a/cashflowbrief"
        case .getStockBond:
            return servicePath + "get-stock-bond/v1"
        case .getFund:
            return servicePath + "get-fund-homepage-info/v1"
        case .marketFinancial:
            return servicePath + "financeindicatorchart"
        case .stockValue:
            return servicePath + "stock-pick/get-gold-stock-pick-brief"
        case .technical:
            return servicePath + "stock-pick/form-insight-brief"
        case .eventReminder:
            return servicePath + "v1/unexpired-note"
        case .closeEventReminder:
            return servicePath + "v1/close-note"
        case .announceEventReminder:
            return servicePath + "v1/announcement"
        case .importantNews:
            return servicePath + "query/selected"
        case .optionAggravate:
            return servicePath + "optionaggregate"
        case .shortSell:
            return servicePath + "config-short-info-query/v1"
        case .articleInfoBylang:
            return servicePath + "query/individualbylang"
        }
    }

    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .detail(let ids, let props, let level),.quote(let ids, let props, let level):
            params["ids"] = ids
            params["props"] = props
            params["level"] = level?.rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .timeLine(let id, let type, let level):
            params["id"] = id
            params["type"] = type
            params["level"] = level?.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .batchTimeLine(let ids, let days, let level):
            params["ids"] = ids
            params["days"] = days ?? "1"
            params["level"] = level?.rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .marketStatus(let ids, let level):
            params["ids"] = ids
            params["level"] = level?.rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .kline(let id, let type, let direction, let level):
            params["id"] = id
            params["type"] = type
            params["direction"] = direction
            params["level"] = level?.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .companyIntro(let stock):
            params["stock"] = stock
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .articleInfo(let stockKey, let articleId, let pageSize, let enlangType):
            params["stockKey"] = stockKey
            params["articleId"] = articleId
            params["pageSize"] = NSNumber(integerLiteral: pageSize)
            if let enlangType = enlangType  {
                params["enlangType"] = enlangType
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .financialIncomes(let stock, let quartertype, _):
            params["stock"] = stock
            if let quartertype = quartertype, quartertype.count > 0 {
                params["quarter"] = quartertype
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .financialBalance(let stock, let quartertype, _):
            params["stock"] = stock
            if let quartertype = quartertype, quartertype.count > 0 {
                params["quarter"] = quartertype
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .financialCashflow(let stock, let quartertype, _):
            params["stock"] = stock
            if let quartertype = quartertype, quartertype.count > 0 {
                params["quarter"] = quartertype
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .spreadTable(let market):
            params["market"] = market
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .hkwarrant(let stock):
            params["stocks"] = stock
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .ygExit(let stockCode, let market):
            params["stockCode"] = stockCode
            params["market"] = market
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .newStockDetail(let stockCode, let exchangeType):
            params["stockCode"] = stockCode
            params["exchangeType"] = NSNumber(integerLiteral: exchangeType)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .announceInfo(let index, let num, let type, let stock):
            params["index"] = index
            params["num"] = num
            params["type"] = type
            params["stock"] = stock
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .HSAnnounceInfo(let index, let num, let type, let stock):
            params["index"] = index
            params["num"] = num
            params["type"] = type
            params["stock"] = stock
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .warrants(let market, let security_code, let from, let count, let sort_type, let sort_direction, let filter, let page_direction):
            
            params["market"] = market
            params["security_code"] = security_code
            params["from"] = from
            params["count"] = count
//            params["to_expire_date"] = to_expire_date
            params["sort_type"] = sort_type
            params["sort_direction"] = sort_direction
            params["filter"] = filter
            params["page_direction"] = page_direction
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .highTimeSharing(let stock, let days, let level):
            params["id"] = stock
            params["days"] = days
            params["level"] = level.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .highKline(let stock, let type, let start, let direction, let count, let level):
            params["id"] = stock
            params["type"] = type
            params["start"] = start
            params["direction"] = direction
            params["count"] = count
            params["level"] = level.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .tickData(let stock, let start, let count, let tradeTime, let level):
            params["id"] = stock
            params["start"] = start
            params["count"] = count
            params["trade_time"] = tradeTime
            params["level"] = level.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getBrokerList(version: let version): //get请求
            params["version"] = version
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .listBalancesheet(let stock, let quarter, let periodtype):
            params["stock"] = stock
            params["quarter"] = quarter
            params["periodtype"] = periodtype
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .listIncomestatement(let stock, let quarter, let periodtype):
            params["stock"] = stock
            params["quarter"] = quarter
            params["periodtype"] = periodtype
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .listCashFlow(let stock, let quarter, let periodtype):
            params["stock"] = stock
            params["quarter"] = quarter
            params["periodtype"] = periodtype
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .AListFinanceindicators(let stock, let quarter):
            params["stock"] = stock
            params["quarter"] = quarter
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .hsListProfit(let stock, quarter: let quarter):
            params["stock"] = stock
            params["quarter"] = quarter
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .hsListAsset(let stock, quarter: let quarter):
            params["stock"] = stock
            params["quarter"] = quarter
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .hsListCashFlow(let stock, quarter: let quarter):
            params["stock"] = stock
            params["quarter"] = quarter
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .getStockBond(stockCode: stockCode, stockMarket: stockMarket):
            params["stockCode"] = stockCode
            params["stockMarket"] = stockMarket
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getFund(let moduleBitmap):
            params["moduleBitmap"] = moduleBitmap
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .marketFinancial(let stock, let quarter):
            params["stock"] = stock
            params["quarter"] = quarter
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .stockValue(let stockId):
            params["stockId"] = stockId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .technical(let stockId):
            params["stockId"] = stockId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .eventReminder(let code):
            params["code"] = code
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .closeEventReminder(code, eventId: eventId):
            params["code"] = code
            params["eventId"] = eventId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .announceEventReminder(let code):
            params["code"] = code
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .importantNews(let stock):
            params["stock"] = stock
            params["recommend_type"] = 1
            params["limit"] = 30
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .optionAggravate(market: let market, code: let code):
            params["market"] = market
            params["code"] = code
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .shortSell(let code, let accountLevel):
            params["code"] = code
            params["accountLevel"] = accountLevel
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .articleInfoBylang(let stockKey, let lastTime, let pageSize, let lang, let market):
            params["stock"] = stockKey
//            params["articleId"] = articleId
            params["lastTime"] = lastTime
            params["pageSize"] = NSNumber(integerLiteral: pageSize)
            params["lang"] = lang
            if let value = market {
                params["market"] = value
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    public var baseURL: URL {
        switch self {
        case .ygExit, .newStockDetail, .getStockBond, .getFund, .shortSell:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        default:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .ygExit, .newStockDetail, .getStockBond, .getFund, .shortSell:
            return .jyRequest
        default:
            return .hzRequest
        }
    }

    public var servicePath: String {
        switch self {
        case .detail, .highTimeSharing, .marketStatus, .batchTimeLine:
            return "/quotes-dataservice-app/api/v2-1/"
        case .quote, .timeLine, .kline, .spreadTable, .highKline, .tickData:
            return "/quotes-dataservice-app/api/v2/"
        case .financialBalance, .financialIncomes, .financialCashflow:
            return "/financial-service/api/v2/"
        case .companyIntro, .hkwarrant , .announceInfo, .HSAnnounceInfo, .AListFinanceindicators:
            return "/news-basicinfo/api/v1/"
        case .hsListAsset, .hsListProfit, .hsListCashFlow, .listBalancesheet, .listIncomestatement, .listCashFlow, .marketFinancial:
            return "/financial-service/api/v1/"
        case .articleInfo, .articleInfoBylang:
            return "/news-relatedwithstock/api/v1/"
        case .ygExit:
            return "/stock-order-server/api/yg-stock-exit/v1"
        case .newStockDetail:
            return "/stock-order-server/api/ipo-info/v2"
        case .warrants:
            return "quotes-dataservice-app/api/v2/warrants"
        case .getBrokerList:
            return "/news-configserver/api/v1/"
        case .getStockBond, .getFund:
            return "/finance-info-server/api/"
        case .stockValue, .technical:
            return "/zt-gold-stock-apiserver/api/v1/"
        case .eventReminder, .closeEventReminder, .announceEventReminder:
            return "/quotes-eventservice/api/"
        case .importantNews:
            return "/news-relatedwithstock/api/v1/"
        case .optionAggravate:
            return "/quotes-dataservice-app/api/v1/"
        case .shortSell:
            return "/asset-center-server/api/"
        }
    }

    public var method: Moya.Method {
        switch self {
            case .detail,.quote, .marketStatus, .batchTimeLine, .ygExit, .newStockDetail, .warrants, .getStockBond, .getFund, .closeEventReminder, .shortSell:
            return .post
        default:
            return .get
        }
    }

    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        switch self {
        default:
            return nil
        }
    }

    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
