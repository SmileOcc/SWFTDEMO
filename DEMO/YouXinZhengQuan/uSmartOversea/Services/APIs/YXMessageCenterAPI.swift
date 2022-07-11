//
//  YXStrongNoticeAPI.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya
import YXKit

let messageCenterDataProvider = MoyaProvider<YXMessageCenterAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])


enum YXMessageCenterAPI {
    // 用户关闭消息反馈
    case closeMsg (_ msgid: String)
    
    // 通知中心首页拉取消息（港版）
    case getMsg
    
    case noteMsg (_ url: String)
    
    case popMsg(showPage: Int)//show_page：1自选，2个人中心，3基金
    
    case closePopMsg(_ msgId: String)
    /* v2/catalogs/unread/num  获取未读消息数  1：系统公告 2：业务提醒 3：活动通知 4：友信内审 5：智能盯盘 6：股价提醒 7：智投提醒 8：资讯推送
    9：客服消息 10：登出 11：每日复盘 12:保留 13:话题 14: 直播消息 15: 行情登出*/
    case unreadNum(_ msgTypes:String)
}

extension YXMessageCenterAPI: YXTargetType {
    public var path: String {
        switch self {
        case .closeMsg:
            return servicePath + "v1/closemsg"
        case .getMsg:
            return servicePath + "v2/getmsg"
        case .noteMsg:
            return servicePath + "v1/getnotemsg"
        case .popMsg:
            return "/news-configserver/api/v1/query/get-pop-msg"
        case .closePopMsg:
            return "/message-server-dolphin/api/read-pop-msg/v1"
        case .unreadNum:
            return servicePath + "v2/catalogs/unread/num"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .closeMsg(let msgid):
            params["msgid"] = msgid
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .getMsg:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .noteMsg(let url):
            params["url"] = url
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .popMsg(let showPage):
            params["show_page"] = showPage
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .closePopMsg(let msgId):
            params["msgId"] = msgId
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .unreadNum(let msgTypes):
            params["msgTypes"] = msgTypes
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    
    
    public var baseURL: URL {
        switch self {
        case .closePopMsg:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        default:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .closePopMsg:
            return .jyRequest
        default:
            return .hzRequest
        }
    }
    
    public var servicePath: String {
        "/message-center/api/"
    }
    
    public var method: Moya.Method {
        switch self {
        case .closeMsg:
            return .put
        case .getMsg,
             .noteMsg,
             .popMsg,
             .closePopMsg,
             .unreadNum:
            return .get
        }
    }
    
    public var headers: [String : String]? {
        var headers = yx_headers
        switch self {
        case .getMsg://获取消息中心消息 非特定券商
            headers["X-BrokerNo"] = ""
        default:
            break
        }
        
        return headers
    }
    
    public var contentType: String? {
        switch self {
        case .noteMsg,
             .popMsg,
             .closePopMsg:
            return "application/json"
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

