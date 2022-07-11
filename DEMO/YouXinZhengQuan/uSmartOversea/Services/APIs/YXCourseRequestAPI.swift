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
    case courseList(primaryCategory: String, secondaryCategory: String? = nil)
    // 评论列表
    case commentList(lessonId: String, pageNum: Int, pageSize: Int = 20)
    // 评论数和收藏数
    case lessonPopularity(lessonId: String)
    // 收藏和取消收藏
    case collectAction(favoriteId: Int = 0, lessonId: String, status: Int) // 0-取消收藏 1-收藏课程
    // 发表评论
    case addcomment(lessonId: String, content: String)
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
}

extension YXCourseRequestAPI: YXRequestAPI {
    
    public var yx_path: String {
        switch self {
        case .recommend:
            return "/teach-server/api/home/recommend_course/v1"
        case .allCourse:
            return "/teach-server/api/course_category/get_all_course_category/v1"
        case .courseList:
            return "/teach-server/api/course/list_course/v2"
        case .commentList:
            return "/teach-server/api/get-comment-list/v1"
        case .lessonPopularity:
            return "/teach-server/api/course/get_lesson_popularity/v1"
        case .collectAction:
            return "/teach-server/api/favorite/favorite_course/v1"
        case .addcomment:
            return "/teach-server/api/add-comment/v1"
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
        }
    }
    
    public var yx_baseUrl: String {
        return YXUrlRouterConstant.jyBaseUrl()
    }
    
    public var yx_params: [String: Any] {
        var params: [String: Any] = [:]
        
        switch self {
        case .recommend(let offset, let orderFlag):
            params["offset"] = offset
            params["orderFlag"] = orderFlag
        case .courseList(let primaryCategory, let secondaryCategory):
            params["primaryCategory"] = primaryCategory
            params["secondaryCategory"] = (secondaryCategory ?? "")
        case .commentList(let lessonId, let pageNum, let pageSize):
            params["lessonId"] = lessonId
            params["pageNum"] = pageNum
            params["pageSize"] = pageSize
        case .lessonPopularity(let lessonId):
            params["lessonId"] = lessonId
        case .collectAction(let favoriteId, let lessonId, let status):
            params["favoriteId"] = favoriteId
            params["lessonId"] = lessonId
            params["status"] = status
        case .addcomment(let lessonId, let content):
            params["lessonId"] = lessonId
            params["content"] = content
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
        default:
            break
        }
        
        return params
    }
    
    public var yx_method: YTKRequestMethod {
        switch self {
        case .fetchBanner:
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


