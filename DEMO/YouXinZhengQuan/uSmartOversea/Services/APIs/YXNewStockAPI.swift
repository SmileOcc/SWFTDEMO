//
//  YXNewStockAPI.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya
import YXKit

let NewStockDataProvider = MoyaProvider<YXNewStockAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])


enum YXNewStockAPI {
    case quotesRank(sortType: Int, sortDirection: Int, pageDirection: Int, from: Int, count: Int, code: String, market: String, level: Int)
    case multiQuotesRank(codelist: [[String: Any]])
    case recordList(pageNum: Int, pageSize: Int, pageSizeZero: Int, orderDirection: Int, exchangeType: Int)
    case ipoList(orderBy: String, orderDirection: Int, pageNum: Int, pageSize: Int, pageSizeZero: Bool, status: Int, exchangeType: Int)
    case ipoInfo(exchangeType: Int, ipoId: Int64?, stockCode: String)
    case recordInfo(applyId: Int64)
    case modifyIpo(actionType: Int, applyId: Int64, applyQuantity: Int, cash: String)
    case accountInfo(moneyType: Int)
    case applyIpo(applyQuantity: Int, applyType: Int, ipoId: Int64, cash: String)
    case topIpoList
    case addFocus(exchangeType: Int, ipoId: Int64?, stockCode: String)
    case ecmApply(applyAmount: String, custSignature: String, ecmId: Int64, applyQuantity: Int64, applyType: Int, inputPwd: Bool, subscripSelect: Int?)
    case ecmCancel(applyId: Int64)
    case ecmDetail(applyId: Int64)
    case ecmModify(applyAmount: String, applyId: Int64, applyQuantity: Int64, custSignature: String, inputPwd: Bool, subscripSelect: Int?)
    case ecmOrderInfo(ipoId: Int64)
    case ecmRecord(pageNum: Int, pageSize: Int, pageSizeZero: Bool, orderDirection: Int)
    /** 是否有国际认购标签
     stock-order-server/api/exist-ecm/v1 */
    case ecmExist(exchangeType: Int)
    case ecmCompensate(applyAmount: Double, moneyType: Int, stockCode: String)
    case deliveredList(orderBy: String, orderDirection: Int, pageNum: Int, pageSize: Int, pageSizeZero: Bool)
    /* http://szshowdoc.youxin.com/web/#/32?page_id=802 -->
      拼团 --> 认购记录（批量）  --> zt-group-apiserver/api/v1/group/batchGet-user-group-info  */
    case batchGetUserGroupInfo(_ paramDict: [String: [[String: Any]] ])
    case signalList(type: Int, subType: Int, count: Int, seqNum: Int, unixTime: Int64)
}

extension YXNewStockAPI: YXTargetType {
    
    public var path: String {
        switch self {
        case .quotesRank, .multiQuotesRank:
            return "/quotes-dataservice-app/api/v2-2/rank"
        case .recordList:
            /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
             IPO app端相关api --> 获取客户ipo申购列表v2 -->
             /stock-order-server/api/iporecord-list/v2  */
            return servicePath + "iporecord-list/v2"
        case .ipoList:
            return servicePath + "ipo-list/v2"
        case .ipoInfo(exchangeType: _, ipoId: _, stockCode: _):
            return servicePath + "ipo-info/v2"
        case .recordInfo(applyId: _):
            return servicePath + "ipo-recordInfo/v1"
        case .modifyIpo:
            return servicePath + "modify-ipo/v1"
        case .accountInfo(moneyType: _):
            return servicePath + "hs-account-info/v1"
        case .applyIpo(applyQuantity: _, applyType: _, ipoId: _, cash: _):
            return servicePath + "apply-ipo/v1"
        case .topIpoList:
            return servicePath + "top-ipo-list/v2"
        case .addFocus(exchangeType: _, ipoId: _, stockCode: _):
            return servicePath + "add-focus/v1"
        case .ecmApply:
            return servicePath + "ecm-apply/v1"
        case .ecmCancel(applyId: _):
            return servicePath + "ecm-cancel/v1"
        case .ecmDetail(applyId: _):
            return servicePath + "ecm-detail/v1"
        case .ecmModify:
            return servicePath + "ecm-modify/v1"
        case .ecmOrderInfo(ipoId: _):
            return servicePath + "ecm-order-info/v1"
        case .ecmRecord:
            /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
             ECM app端相关api --> ecm认购记录分页查询 -->
             /stock-order-server/api/ecm-record/v1  */
            return servicePath + "ecm-record/v1"
            /** 是否有国际认购标签
             stock-order-server/api/exist-ecm/v1 */
        case .ecmExist(exchangeType: _):
            return servicePath + "exist-ecm/v1"
        case .ecmCompensate:
            return servicePath + "ecm-compensation-reward/v1"
        case .deliveredList:
            return servicePath + "ipo-delivered-list/v1"
            
        case .batchGetUserGroupInfo:
            /* http://szshowdoc.youxin.com/web/#/32?page_id=802 -->
            拼团 --> 认购记录（批量）  --> zt-group-apiserver/api/v1/group/batchGet-user-group-info  */
            return servicePath + "group/batchGet-user-group-info"
        case .signalList:
            return servicePath + "signal/list"
        }

    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case let .quotesRank(sortType: sortType, sortDirection: sortDirection, pageDirection: pageDirection, from: from, count: count, code: code, market: market, level: level):
            
            var codeList: [String: Any] = [:]
            codeList["sorttype"] = sortType
            codeList["sortdirection"] = sortDirection
            codeList["pagedirection"] = pageDirection
            codeList["from"] = from
            codeList["count"] = count
            codeList["code"] = code
            codeList["market"] = market
            codeList["level"] = level
            params["codelist"] = [codeList]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        
        case let .multiQuotesRank(codelist: codelist):
            
            params["codelist"] = codelist
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case let .recordList(pageNum: pageNum, pageSize: pageSize, pageSizeZero: pageSizeZero, orderDirection: orderDirection, exchangeType: exchangeType):
            /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
            IPO app端相关api --> 获取客户ipo申购列表v2 -->
            /stock-order-server/api/iporecord-list/v2  */
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["pageSizeZero"] = pageSizeZero
            params["orderDirection"] = orderDirection
            params["exchangeType"] = exchangeType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ipoList(orderBy: orderBy, orderDirection: orderDirection, pageNum: pageNum, pageSize: pageSize, pageSizeZero: pageSizeZero, status: status, exchangeType: exchangeType):
            
            params["orderBy"] = orderBy
            params["orderDirection"] = orderDirection
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["pageSizeZero"] = pageSizeZero
            params["status"] = status
            params["exchangeType"] = exchangeType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ipoInfo(exchangeType: exchangeType, ipoId: ipoId, stockCode: stockCode):
            params["exchangeType"] = exchangeType
            params["ipoId"] = ipoId
            params["stockCode"] = stockCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .recordInfo(applyId: let applyId):
            params["applyId"] = applyId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .modifyIpo(actionType: actionType, applyId: applyId, applyQuantity: applyQuantity, cash: cash):
            params["actionType"] = actionType
            params["applyId"] = applyId
            params["applyQuantity"] = applyQuantity
            params["cash"] = cash
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .accountInfo(moneyType: let moneyType):
            params["moneyType"] = moneyType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .applyIpo(applyQuantity: applyQuantity, applyType: applyType, ipoId: ipoId, cash: cash):
            params["applyQuantity"] = applyQuantity
            params["applyType"] = applyType
            params["ipoId"] = ipoId
            params["cash"] = cash
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .topIpoList:
            return .requestPlain
        case let .addFocus(exchangeType: exchangeType, ipoId: ipoId, stockCode: stockCode):
            params["exchangeType"] = exchangeType
            params["ipoId"] = ipoId
            params["stockCode"] = stockCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmApply(applyAmount: applyAmount, custSignature: custSignature, ecmId: ecmId, applyQuantity: applyQuantity, applyType: applyType, inputPwd: inputPwd, subscripSelect: tempSubscripSelect):
            params["applyAmount"] = applyAmount
            params["custSignature"] = custSignature
            params["ecmId"] = ecmId
            params["applyQuantity"] = applyQuantity
            params["applyType"] = applyType
            params["inputPwd"] = inputPwd
            if let subscripSelect = tempSubscripSelect {
                params["subscripSelect"] = subscripSelect
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmCancel(applyId: applyId):
            params["applyId"] = applyId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmDetail(applyId: applyId):
            params["applyId"] = applyId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmModify(applyAmount: applyAmount, applyId: applyId, applyQuantity: applyQuantity, custSignature: custSignature, inputPwd: inputPwd, subscripSelect: tempSubscripSelect):
            params["applyAmount"] = applyAmount
            params["applyId"] = applyId
            params["applyQuantity"] = applyQuantity
            params["custSignature"] = custSignature
            params["inputPwd"] = inputPwd
            if let subscripSelect = tempSubscripSelect {
                params["subscripSelect"] = subscripSelect
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmOrderInfo(ipoId: ipoId):
            params["ipoId"] = ipoId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmRecord(pageNum: pageNum, pageSize: pageSize, pageSizeZero: pageSizeZero, orderDirection: orderDirection):
            /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
            ECM app端相关api --> ecm认购记录分页查询 -->
            /stock-order-server/api/ecm-record/v1  */
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["pageSizeZero"] = pageSizeZero
            params["orderDirection"] = orderDirection
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmExist(exchangeType: exchangeType):
            /** 是否有国际认购标签
             stock-order-server/api/exist-ecm/v1 */
            params["exchangeType"] = exchangeType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .ecmCompensate(applyAmount: applyAmount, moneyType: moneyType, stockCode: stockCode):
            params["applyAmount"] = applyAmount
            params["moneyType"] = moneyType
            params["stockCode"] = stockCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .deliveredList(orderBy: orderBy, orderDirection: orderDirection, pageNum: pageNum, pageSize: pageSize, pageSizeZero: pageSizeZero):
            params["orderBy"] = orderBy
            params["orderDirection"] = orderDirection
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["pageSizeZero"] = pageSizeZero
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .batchGetUserGroupInfo(let paramDict):
            /* http://szshowdoc.youxin.com/web/#/32?page_id=802 -->
            拼团 --> 认购记录（批量）  --> zt-group-apiserver/api/v1/group/batchGet-user-group-info  */
            params = paramDict
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .signalList(type: type, subType: subType, count: count, seqNum: seqNum, unixTime: unixTime):
            params["type"] = type
            params["subType"] = subType
            params["count"] = count
            params["seqNum"] = seqNum
            params["unixTime"] = unixTime
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }

    }
    
    public var baseURL: URL {
        switch self {
            case .quotesRank, .multiQuotesRank, .batchGetUserGroupInfo, .signalList:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        default:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .quotesRank, .multiQuotesRank, .batchGetUserGroupInfo, .signalList:
            return .hzRequest
        default:
            return .jyRequest
        }
    }
    
    public var servicePath: String {
        switch self {
        case .quotesRank:
            return ""
        case .accountInfo(moneyType: _):
            return "/stock-capital-server/api/"
        case .ecmCompensate:
            return "/customer-relationship-server/api/"
        case .batchGetUserGroupInfo:
            return "/zt-group-apiserver/api/v1/"
        case .signalList:
            return "/quotes-smart/api/v2/"
        default:
            return "/stock-order-server/api/"
        }
    }
    
    public var method: Moya.Method {
        .post
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        "application/json"
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}
