//
//  YXSpecialAPI.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//


enum YXSpecialAPI {
    // http://edu-uat.niubibi.com/teach-server/doc/doc.html
    case recommend(pageNum: Int, pageSize: Int, category: Int? = nil)
    case isSubscribeKOL(subscriptId: String)
    case checkSubscribe
    case subscribeKOLList
    case subscribeArticleList(pageNum: Int, pageSize: Int)
    case unSubscribeList(pageNum: Int, pageSize: Int)
    case collection(postId: String, status: Int) // 收藏状态 0已收藏 1未收藏
    
    case chatsGroupList(pageNum: Int, pageSize: Int)
    
    case KOLUserInfo(id: String) ///获取KOL信息
    case KOLCollection(id: String, pageNum: Int, pageSize: Int)///获取KOL所有文章
    case KOLAnswerList(id: String, pageNum: Int, pageSize: Int)///获取KOL所有问股
    case KOLChatList(id: String) /// KOL聊天室
    case KOLLiveList(id: String, pageNum: Int, pageSize: Int) ///KOL直播列表
    case KOLVideoList(id: String, pageNum: Int, pageSize: Int) ///KOL短视频列表
    /// 获取kol课程
    case KOLCourseList(id: String)
    ///
    case replayDetailList(id: String) ///直播回放详情

    case recommendChatAsk //首页聊天室 问股 推荐
    
    case askQueryHot
    case askQuery(pageNum: Int, pageSize: Int, type: Int, stockCode: [String]? = nil)
    
    case delAsk(id: String)
    case delReply(id: String)
    
    case follow(state: Int, subscriptId: String)
    
    case like(likeStatus: Int, replyId: String) //问股点赞 点赞状态 1=点赞，2=取消点赞

    //根据主键获取短视频
    case KOLVideo(id: String)
    //分享数据上报
    //bizType类型 1-课程 2-kol 3-聊天室 4-问股 5-文章 6-短视频 7-直播
    //channel渠道 1-微信 2-facebook 3-line 4-whatsapp 5-moments
    case shareDataReport(bizType: Int, businessId:String, channel: Int)
    
    //SG新增
    case homeRecommend(pageId: Int,regionNo: Int?) //广告页pageId regionNo 地区编号:-1所有地区 1.中国大陆 2.中国香港 3:新加坡，为空根据apptype取值
    case getSgKolRecommendList(pageNum: Int, pageSize: Int)
    
    case searchRecommend
    
    case postKolView(title: String?, content: String)
    case deleteKolView(postId: String?)
}

extension YXSpecialAPI: YXRequestAPI {
    
    public var yx_path: String {
        switch self {
        case .chatsGroupList:
            return "/teach-server/api/get-chat-group-list/v1"
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
            return "/teach-server/api/get-chatgroup-ask-recommend/v2"
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
        case .KOLChatList:
            return "/teach-server/api/get-kol-chat-group-list/v1"
        case .KOLLiveList:
            return "/teach-server/api/kol-live-list/v1"
        case .replayDetailList:
            return "/teach-server/api/get-live-replay-detail/v1"
        case .KOLVideoList:
            return "/teach-server/api/get-kol-video-list/v1"
        case .KOLCourseList:
            return "/teach-server/api/course/list_course/v3"
        case .KOLVideo:
            return "/teach-server/api/get-kol-video-particulars/v1"
        case .shareDataReport:
            return "/teach-server/api/share-date-report/v1"
        case .homeRecommend:
            return "/teach-server/api/get-home-recommend/v2"
        case .getSgKolRecommendList:
            return "/teach-server/api/get-sg-kol-recommend-list/v1"
        case .searchRecommend:
            return "/teach-server/api/get-search-recommend/v1"
        case .postKolView:
            return "/teach-server/api/add-short-post-info/v1"
        case .deleteKolView:
            return "/teach-server/api/del-short-post-info/v1"
        }
    }
    
    public var yx_params: [String: Any] {
        var params: [String: Any] = [:]
        
        switch self {
        case .chatsGroupList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            let dict: [String:Any] = ["chatGroupListType":0]
            params["param"] = dict
        case .recommend(let pageNum, let pageSize,let category):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            var dict: [String:Any] = [:]
            if let category = category {
                dict["category"] = category
            }
            params["param"] = dict
        case .isSubscribeKOL(let subscriptId):
            params["subscriptId"] = subscriptId
        case .checkSubscribe:
            break
        case .KOLCourseList(let authorId):
            params["authorId"] = authorId
        case .subscribeKOLList:
            break
        case .subscribeArticleList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .unSubscribeList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .collection(let postId, let status):
            params["postId"] = postId
            params["status"] = status
        case .askQuery(let pageNum, let pageSize, let type, let stockCode):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            var dict: [String:Any] = ["type":type]
            if let stockCode = stockCode {
                dict["stockCodeList"] = stockCode
            }
            params["param"] = dict
        case .delReply(let id):
            params["queryId"] = id
        case .delAsk(let id):
            params["queryId"] = id
        case .askQueryHot:
            break
        case .recommendChatAsk:
            break
        case .KOLUserInfo(let id):
            params["queryId"] = id
        case .KOLCollection(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = ["authorId":id]
        case .follow(let state, let subscriptId):
            params["status"] = state
            params["subscriptId"] = subscriptId
        case .like(let likeStatus, let replyId):
            params["likeStatus"] = likeStatus
            params["replyId"] = replyId
        case .KOLAnswerList(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = ["queryId":id]
        case .KOLChatList(let id):
            params["kolId"] = id
        case .KOLLiveList(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = ["kolUUID":id]
        case .KOLVideoList(let id, let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["param"] = ["authorId":id]
        case .replayDetailList(let id):
            params["id"] = id
        case .KOLVideo(let id):
            params["id"] = id
        case .shareDataReport(let bizType, let businessId, let channel):
            params["bizType"] = bizType
            params["businessId"] = businessId
            params["channel"] = channel
        case .homeRecommend(let id,let regionNo):
            params["pageId"] = id
            if let reg = regionNo {
                params["regionNo"] = reg
            }
        case .getSgKolRecommendList(let pageNum, let pageSize):
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .postKolView(let title, let content):
            params["postTitle"] = title
            params["postContentFree"] = content
        case .deleteKolView(let postId):
            params["postId"] = postId
        default:
            break;
        }
        
        return params
    }
    
    public var yx_baseUrlType: YXRequestType {
        switch YXConstant.appTypeValue {
        case .OVERSEA_SG:
            return .jyRequest
        default:
            return .hzRequest
        }
    }
    
    public var yx_method: YTKRequestMethod {
        switch self {
        case .replayDetailList:
            return .GET
        default:
            return .POST
        }
    }
    
    public var yx_responseModelClass: NSObject.Type {
        switch self {
        default:
            return YXResponseModel.self
        }
    }
}
