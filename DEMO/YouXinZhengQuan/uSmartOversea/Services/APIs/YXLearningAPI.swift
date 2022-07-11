//
//  YXLearningAPI.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
import Moya

let learningProvider = MoyaProvider<YXLearningAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXLearningAPI {
    // http://edu-uat.niubibi.com/teach-server/doc/doc.html
    case recommend(pageNum: Int, pageSize: Int)
    case isSubscribeKOL(subscriptId: String)
    case checkSubscribe
    case subscribeKOLList
    case subscribeArticleList(pageNum: Int, pageSize: Int)
    case unSubscribeList(pageNum: Int, pageSize: Int)
    case collection(postId: String, status: Int) // 收藏状态 0已收藏 1未收藏
    
    case KOLUserInfo(id: String) ///获取KOL信息
    case KOLCollection(id: String, pageNum: Int, pageSize: Int)///获取KOL所有文章
    case KOLAnswerList(id: String, pageNum: Int, pageSize: Int)///获取KOL所有问股
    
    case recommendChatAsk //首页聊天室 问股 推荐
    
    case askQueryHot
    case askQuery(pageNum: Int, pageSize: Int, type: Int, stockCode: String? = nil)
    
    case delAsk(id: String)
    case delReply(id: String)
    
    case follow(state: Int, subscriptId: String)
    
    case like(likeStatus: Int, replyId: String) //问股点赞 点赞状态 1=点赞，2=取消点赞
}

extension YXLearningAPI: YXTargetType {
    var servicePath: String {
        return "/teach-server/api/"
    }
    
    var contentType: String? {
        nil
    }
    
    var baseURL: URL {
        switch self {
        default:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        default:
            return .hzRequest
        }
    }
    
    var path: String {
        switch self {
        case .recommend:
            return "/teach-server/api/get-post-recommendation-list/v1"
        case .isSubscribeKOL:
            return "/teach-server/api/is-subscription/v1"
        case .checkSubscribe:
            return "/teach-server/api/check-user-subscribe-info/v1"
        case .subscribeKOLList:
            return "/teach-server/api/get-post-personal-info/v1"
        case .subscribeArticleList:
            return "/teach-server/api/get-user-subscript-list/v1"
        case .unSubscribeList:
            return "/teach-server/api/get-unsubscribed-list/v1"
        case .collection:
            return "/teach-server/api/is-collection-status/v1"
        case .askQueryHot:
            return "/teach-server/api/ask/query-hot-stocks/v1"
        case .askQuery:
            return "teach-server/api/ask/query-asks/v1"
        case .delAsk:
            return "/teach-server/api/ask/del-ask/v1"
        case .delReply:
            return "/teach-server/api/ask/del-reply/v1"
        case .recommendChatAsk:
            return "/teach-server/api/get-chatgroup-ask-recommend/v1"
        case .KOLUserInfo:
            return "/teach-server/api/ask/query-kol-info/v1"
        case .KOLCollection:
            return "/teach-server/api/get-post-collection-list/v1"
        case .follow:
            return "/teach-server/api/handle-follow-info/v1"
        case .like:
            return "/teach-server/api/ask/update-likes/v1"
        case .KOLAnswerList:
            return "/teach-server/api/ask/query-kol-answers/v1"
        }
        
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        
        switch self {
        case .recommend(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .isSubscribeKOL(let subscriptId):
            params["subscriptId"] = subscriptId
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .checkSubscribe:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .subscribeKOLList:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .subscribeArticleList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .unSubscribeList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .collection(let postId, let status):
            params["postId"] = postId
            params["status"] = status
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .askQuery(let pageNum, let pageSize, let type, let stockCode):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            var dict: [String:Any] = ["type":type]
            if let stockCode = stockCode {
                dict["stockCode"] = stockCode
            }
            params["param"] = dict
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .delReply(let id):
            params["queryId"] = id
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .delAsk(let id):
            params["queryId"] = id
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .askQueryHot:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
            break
        case .recommendChatAsk:
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
            break
        case .KOLUserInfo(let id):
            params["queryId"] = id
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .KOLCollection(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = ["authorId":id]
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .follow(let state, let subscriptId):
            params["state"] = state
            params["subscriptId"] = subscriptId
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .like(let likeStatus, let replyId):
            params["likeStatus"] = likeStatus
            params["replyId"] = replyId
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .KOLAnswerList(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = id
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
