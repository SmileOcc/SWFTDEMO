//
//  YXInfoCourseModel.swift
//  uSmartOversea
//
//  Created by Mac on 2020/3/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation

/// 课程类型列表
class YXInfoCourseClassifyModel: Codable {
    let courseClassifyList: [YXInfoCourseClassifyListModel]?
    
    enum CodingKeys: String, CodingKey {
        case courseClassifyList = "course_classify_list"
    }
}
class YXInfoCourseClassifyListModel: Codable {
    let courseClassifyName: String?
    let courseClassifyId: Int?
    
    enum CodingKeys: String, CodingKey {
        case courseClassifyName = "course_classify_name"
        case courseClassifyId = "course_classify_id"
    }
    
}

///课程列表页
class YXInfoCourseListModel: Codable {
    let count: Int?
    let courseList: [YXInfoCourseSubModel]?
    
    enum CodingKeys: String, CodingKey {
        case count
        case courseList = "course_list"
    }
}
class YXInfoCourseSubModel: Codable {
    
    let courseId: Int?
    let courseTitle: String?    //课程标题
    let courseBrief: String?    //课程简介
    let courseCover: String?    //课程封面
    
    var isRead = false
    
    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case courseTitle = "course_title"
        case courseBrief = "course_brief"
        case courseCover = "course_cover"
    }
    
}
