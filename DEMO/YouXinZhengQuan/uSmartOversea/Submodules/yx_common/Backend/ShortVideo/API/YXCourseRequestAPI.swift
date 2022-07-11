//
//  YXCourseRequestAPI.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import YTKNetwork
import Moya
import RxSwift

public enum YXCourseRequestAPI {
    // 首页推荐 // http://edu-uat.niubibi.com/teach-server/doc/doc.html
    case recommend(offset: Int, orderFlag: Bool)
    // 所有课程分类
    case allCourse
    // 课程列表
    case courseList(primaryCategory: String, secondaryCategory: String? = nil, authorId: String? = nil)
    // 评论列表
    case commentList(lessonId: String, pageNum: Int, pageSize: Int = 20, businessCode: Int, orderDesc: Bool)
    // 评论数和收藏数
    case videoPopularity(videoId: String, kolId: String)
    // 收藏和取消收藏
    case collectAction(bizCode: Int = 0, bizId: String, status: Int) // bizCode: 1-课时，2-文章，3-课程  status: 0-已收藏(true) 1-未收藏(false)
    // 发表评论
    case addcomment(lessonId: String, content: String, commentType: Int, parentId: String? = nil)
    // 删除评论
    case deletecomment(commentId: String)
    //课程详情
    case courseDetail(courseId: String, needRecord: Bool = true)
    //获取课件
    case courseware(videoId: String)
    //获取课时
    case lessonList(courseId: String, needRecord: Bool = true)
    /*注册完成后调查问卷*/
    case investigation(question1:[Int],question2:Int,question3:Int)
    //增加学习记录
    case addCourseRecord(courseId: Int,lessonId: Int,videoId: Int,watchProgress: Int,watchTimePosition: Int)
    //检查用户是否购买商品
    case checkUserPurchased(businessCode: Int, businessId: String)
    //查询是否有随堂小测
    case queryQuiz(lessonId: String)
    //获取轮播图
    case fetchBanner
    //继续学习
    case continueLearn
    //点赞 business类型，默认为 1-直播 2-短视频 3-评论
    case like(business: Int, businessId: String, status: Int)
    //直播中数量
    case liveCount
    /// 获取课时人气(收藏、评论数)
    case lessonPopularity(lessonId: String)
    /// 赠送新手福利
    case addReceiveAward
    /// 首页广告弹窗
    case listOfficial
    /// 增加短视频观看记录
    case addVideoRecord(offset: Int, version: Int, videoId: String)

}

extension YXCourseRequestAPI: YXRequestAPI {
    
    public var yx_path: String {
        switch self {
        case .recommend:
            return "/teach-server/api/home/recommend-short-video/v2"
        case .allCourse:
            return "/teach-server/api/course_category/get_all_course_category/v1"
        case .courseList:
            return "/teach-server/api/course/list_course/v2"
        case .commentList:
            return "/teach-server/api/get-comment-list/v3"
        case .videoPopularity:
            return "/teach-server/api/course/get-course-relevant-info/v1"
        case .collectAction:
            return "/teach-server/api/collection/is-collection-status/v1"
        case .addcomment:
            return "/teach-server/api/add-comment/v2"
        case .deletecomment:
            return "/teach-server/api/delete-comment-list/v1"
        case .courseDetail:
            return "/teach-server/api/course/get_course_detail/v1"
        case .courseware:
            return "/teach-server/api/course/get_courseware/v2"
        case .lessonList:
            return "/teach-server/api/course/list_lesson/v1"
        case .investigation:
            return "/teach-server/api/user_course/questionnaire/v1"
        case .addCourseRecord:
            return "/teach-server/api/user_course/add_course_record/v1"
        case .checkUserPurchased:
            return "/teach-server/api/course/check-user-purchase-product/v1"
        case .queryQuiz:
            return "/teach-server/api/query-quiz-exists/v1"
        case .fetchBanner:
            return "/teach-server/api/get-banner-app/v1"
        case .continueLearn:
            return "/teach-server/api/home/continue_learning/v1"
        case .like:
            return "/teach-server/api/like/v1"
        case .liveCount:
            return "/teach-server/api/get-living-num/v1"
        case .lessonPopularity:
            return "/teach-server/api/course/get_lesson_popularity/v1"
        case .addReceiveAward:
            return "/teach-server/api/user_course/add_receive_award/v1"
        case .listOfficial:
            return "/teach-server/api/user_course/list_official/v1"
        case .addVideoRecord:
            return "/teach-server/api/user-course/add-video-record/v1"
        }
    }
    
    public var yx_params: [String: Any] {
        var params: [String: Any] = [:]
        
        switch self {
        case .recommend(let offset, let orderFlag):
            params["offset"] = offset
            params["orderFlag"] = orderFlag
        case .courseList(let primaryCategory, let secondaryCategory, let authorId):
            params["primaryCategory"] = primaryCategory
            params["secondaryCategory"] = (secondaryCategory ?? "")
        case .commentList(let lessonId, let pageNum, let pageSize, let businessCode, let orderDesc):
            params["businessCode"] = businessCode
            params["lessonId"] = lessonId
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
            params["orderDesc"] = orderDesc
        case .videoPopularity(let videoId, let kolId):
            params["videoId"] = videoId
            params["kolId"] = kolId
        case .collectAction(let bizCode, let bizId, let status):
            params["bizCode"] = bizCode
            params["bizId"] = bizId
            params["status"] = status
        case .addcomment(let lessonId, let content, let commentType, let parentId):
            params["commentType"] = commentType
            params["lessonId"] = lessonId
            params["content"] = content
            if let parentId = parentId {
                params["parentId"] = parentId
            }
        case .deletecomment(let commentId):
            params["commentId"] = commentId
        case .investigation(let question1, let question2, let question3):
            params["question1"] = question1
            params["question2"] = question2
            params["question3"] = question3
        case .courseDetail(let courseId, let needRecord):
            params["courseId"] = courseId
            params["needRecord"] = needRecord ? 1 : 0
        case .courseware(let videoId):
            params["videoId"] = videoId
        case .lessonList(let courseId, let needRecord):
            params["courseId"] = courseId
            params["needRecord"] = needRecord ? 1 : 0
        case .addCourseRecord(let courseId, let lessonId, let videoId, let watchProgress, let watchTimePosition):
            params["courseId"] = courseId
            params["lessonId"] = lessonId
            params["videoId"] = videoId
            params["watchProgress"] = watchProgress
            params["watchTimePosition"] = watchTimePosition
        case .checkUserPurchased(let businessCode, let businessId):
            params["businessCode"] = businessCode
            params["businessId"] = businessId
        case .queryQuiz(let lessonId):
            params["lessonId"] = lessonId
        case .fetchBanner:
            params["pageId"] = 1
        case .like(let business, let businessId, let status):
            params["business"] = business
            params["businessId"] = businessId
            params["status"] = status
        case .lessonPopularity(let lessonId):
            params["lessonId"] = lessonId
        case .addVideoRecord(let offset, let version, let videoId):
            params["offset"] = offset
            params["version"] = version
            params["videoId"] = videoId
        default:
            break
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
        case .fetchBanner, .liveCount:
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


