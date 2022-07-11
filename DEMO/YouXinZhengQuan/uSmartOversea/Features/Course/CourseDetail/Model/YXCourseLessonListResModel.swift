//
//  YXCourseLessonResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCourseLessonListResModel: YXModel {
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["lessonList": YXCourseLessonResModel.self]
    }
    @objc var record : YXCourseRecordResModel! //历史记录
    @objc var lessonList : [YXCourseLessonResModel]! //课程列表
}

class YXCourseLessonResModel: YXModel {
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        ["videoList": YXCourseVideoResModel.self]
    }
    
    @objc var videoList : [YXCourseVideoResModel]! //视频列表
    @objc var courseId: Int = 0            //关联的课程id
    @objc var courseIdStr: String?      //关联的课程id
    @objc var courseName: String?       //课程名称
    @objc var favoriteFlag: Bool = false       //是否收藏
    @objc var lessonCover: String?      //课时封面url
    @objc var lessonDesc: String?       //课时简介
    @objc var lessonId: Int = 0         //课时业务id
    @objc var lessonIdStr: String?      //课时业务id
    @objc var lessonName: String?       //课时名称
    @objc var lessonOrder: Int = 0         //课时顺序
    @objc var regionNo: Int = 0            //地区编号
}

class YXCourseVideoResModel: YXModel {
    @objc var languageNo: Int = 0              //语言编号
    @objc var lessonId: Int  = 0               //关联课时业务id
    @objc var lessonIdStr: String?          //关联课时业务id
    @objc var verticalVideoDuration: Int = 0   //竖版视频时长(单位:秒)
    @objc var verticalVideoInfo: String?    //竖版视频url
    @objc var videoDuration: Int  = 0          //视频时长(单位:秒)
    @objc var videoId: Int   = 0               //视频业务id
    @objc var videoIdStr:String?            //视频业务id
    @objc var videoInfo: String?            //视频url
    @objc var watchCount: Int  = 0             //观看数
}

class YXCourseRecordResModel: YXModel {
    @objc var courseId: Int = 0                //关联的课程业务id
    @objc var courseIdStr: String?          //关联的课程业务id
    @objc var createTime: String?           //创建时间
    @objc var creater: String?              //创建用户
    @objc var flag: Bool = false                   //前端flag
    @objc var id: Int   = 0                    //自增id
    @objc var idStr: String?                //自增id
    @objc var lastWatchTime: String?        //最后观看时间
    @objc var lessonCover: String?          //课时封面
    @objc var lessonId: Int = 0                //课时业务id
    @objc var lessonIdStr: String?          //课时业务id
    @objc var lessonName: String?           //课时名称
    @objc var updateTime: String?           //更新时间
    @objc var updater: String?              //更新用户
    @objc var videoId: Int = 0                 //视频业务id
    @objc var videoIdStr: String?           //视频业务id
    @objc var watchProgress: Int = 0            //观看进度(单位:%)
    @objc var watchTimePosition: Int = 0       //观看时间定位(单位:秒)
}
