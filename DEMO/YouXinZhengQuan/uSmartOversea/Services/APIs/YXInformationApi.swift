//
//  YXNewsApi.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Moya

let infoDataProvider = MoyaProvider<YXInformationApi>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

enum YXInformationApi {
    
    case recommend(_ cmd: Int, _ isTop: Bool, _ last_time: Int?, _ enlangType: Int?, _ market: String?)
    case specialColumn(_ newsid: String, _ enlangType: Int?)
    case selfSelect(_ articleId: String, _ pageSize: Int, _ enlangType: Int?, _ market: String?)
    case allDay(_ offset: Int, _ startstamp: Int, _ pageSize: Int, _ newsid: String)
    case courseClassifyList //课程类型列表
    case courseList(_ offset: Int, pageSize:Int,classifyId: Int)//课程列表页
    case queryMyCourse  //我的课程
    case deleteMyCourse(_ courseId:Int) //删除我的课程
    case createMyCourse(_ courseId:Int) //创建我的课程
    case queryNoteHome  //内参首页
    case recommendnewsbylang(_ isTop: Bool, _ last_score: Int?, _ pagesize: Int, _ lang: Int, _ market: String?) /*推荐资讯列表-多市场-多平台(用户自己选择资讯语言) http://showdoc.yxzq.com/web/#/23?page_id=2453 */
    case selfSelectbylang(_ articleId: String, _ pageSize: Int, _ lang: Int,_ market: String?)


}

extension YXInformationApi: YXTargetType {
    var servicePath: String {
        switch self {
        case .specialColumn,
             .selfSelect,
             .queryNoteHome,
            .selfSelectbylang:
            return "/news-relatedwithstock/api/"
        case .allDay:
            return "/news-msgdisplay/api/"
        case .recommend, .recommendnewsbylang:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=481 -->
            news-recommend --> 港版推荐资讯列表  --> news-recommend/api/v1/gethkrecommend */
            return "/news-recommend/api/"
        case .courseClassifyList,
             .courseList,
             .queryMyCourse,
             .deleteMyCourse,
             .createMyCourse:
            return "news-videoserver/api/"
        }
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
        case .specialColumn:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=637 ->news-relatedwithstock
            -> 港版专栏 -> V2 -> 首页接口
            -> news-relatedwithstock/api/v2/query/hkfeaturehome
            港版专栏首页接口 */
            return servicePath + "v2/query/hkfeaturehome"
        case .selfSelect:
            return servicePath + "v1/query/selfselectnews"
        case .allDay:
            return servicePath + "v1/7x24list"
        case .recommend:
            /* http://szshowdoc.youxin.com/web/#/23?page_id=481 -->
             news-recommend --> 港版推荐资讯列表  --> news-recommend/api/v1/gethkrecommend */
            return servicePath + "v1/recommendnews"
        case .courseClassifyList:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1167  -->
             news-videoserver（资讯视频API服务） --> 课程类型列表
             --> news-videoserver/api/v1/query/course_classify_list */
            return servicePath + "v1/query/course_classify_list"
        case .courseList:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1167  -->
            news-videoserver（资讯视频API服务） --> 课程列表页
            --> news-videoserver/api/v1/query/course_list */
            return servicePath + "v1/query/course_list"
        case .queryMyCourse:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1169  -->
            news-videoserver（资讯视频API服务） --> 我的课程
            --> news-videoserver/api/v1/query/query_my_course */
            return servicePath + "v1/query/query_my_course"
        case .deleteMyCourse:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1172  -->
            news-videoserver（资讯视频API服务） --> 删除我的课程
            --> news-videoserver/api/v1/query/delete_my_course */
            return servicePath + "v1/query/delete_my_course"
        case .createMyCourse:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1179  -->
            news-videoserver（资讯视频API服务） --> 创建我的课程
            --> news-videoserver/api/v1/query/create_my_course */
            return servicePath + "v1/query/create_my_course"
        case .queryNoteHome:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1158  -->
            news-relatedwithstock --> 友信内参 --> 内参首页
            --> news-relatedwithstock/api/v1/query/notehome */
            return servicePath + "v1/query/notehome"
        case .recommendnewsbylang:
            return servicePath + "v1/recommendnewsbylang"
        case .selfSelectbylang:
            return servicePath + "v1/query/selfselectnewsbylang"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .specialColumn, .selfSelect, .allDay, .recommend, .recommendnewsbylang, .selfSelectbylang,
             .courseClassifyList,
             .courseList,
             .queryMyCourse,
             .deleteMyCourse,
             .createMyCourse,
             .queryNoteHome:
            return .get
        }
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
        case .recommend(_, let istop, let lastime, let enlangType, let market):
            /* http://szshowdoc.youxin.com/web/#/23?page_id=481 -->
            news-recommend --> 港版推荐资讯列表  --> news-recommend/api/v1/gethkrecommend */
//            params["cmd"] = cmd
            params["istop"] = istop
            params["pagesize"] = 30
            params["market"] = market

            if let time = lastime  {
                params["last_time"] = time
            }
            if let enlangType = enlangType {
                params["lang_type"] = enlangType
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .specialColumn(let newsid, let enlangType):
            params["newsid"] = newsid
            params["page_size"] = 3
            if let enlangType = enlangType {
                params["enlangType"] = enlangType
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .selfSelect(let articleId, let pageSize, let enlangType, let market):
            params["articleId"] = articleId
            params["pageSize"] = pageSize
            params["market"] = market
            if let enlangType = enlangType {
                params["enlangType"] = enlangType
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .allDay(let offset, let startstamp, let pagesize, let newsid):
            params["offset"] = offset
            params["startstamp"] = startstamp
            params["pagesize"] = pagesize
            params["newsid"] = newsid
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .courseClassifyList:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1167  -->
            news-videoserver（资讯视频API服务） --> 课程类型列表
            --> news-videoserver/api/v1/query/course_classify_list JSONEncoding*/
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .courseList(let offset, let pageSize, let classifyId):
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1167  -->
            news-videoserver（资讯视频API服务） --> 课程列表页
            --> news-videoserver/api/v1/query/course_list */
            params["offset"] = offset
            params["pagesize"] = pageSize
            if classifyId != 0 {
                params["course_classify_id"] = classifyId
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .queryMyCourse:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1169  -->
            news-videoserver（资讯视频API服务） --> 我的课程
            --> news-videoserver/api/v1/query/query_my_course */
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .deleteMyCourse(let courseId):
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1172  -->
            news-videoserver（资讯视频API服务） --> 删除我的课程
            --> news-videoserver/api/v1/query/delete_my_course */
            params["course_id"] = courseId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .createMyCourse(let courseId):
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1179  -->
            news-videoserver（资讯视频API服务） --> 创建我的课程
            --> news-videoserver/api/v1/query/create_my_course */
            params["course_id"] = courseId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .queryNoteHome:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=1158  -->
            news-relatedwithstock --> 友信内参 --> 内参首页
            --> news-relatedwithstock/api/v1/query/notehome */
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .recommendnewsbylang(let istop, let last_score, let pagesize, let lang, let market):
            /* http://showdoc.yxzq.com/web/#/23?page_id=2453 -->
             推荐资讯列表-多市场-多平台(用户自己选择资讯语言)
             http://yxzq.com/news-recommend/api/v1/recommendnewsbylang
             */
//            params["cmd"] = cmd
            params["istop"] = istop
            params["pagesize"] = pagesize
            if let score = last_score  {
                params["last_score"] = score
            }
            params["lang"] = lang
            if let mar = market  {
                params["market"] = mar
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .selfSelectbylang(let articleId, let pageSize, let lang, let market):
            params["articleId"] = articleId
            params["pageSize"] = pageSize
            params["lang"] = lang
            if let mar = market {
                params["market"] = mar
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? {
        yx_headers
    }
    
    
}
