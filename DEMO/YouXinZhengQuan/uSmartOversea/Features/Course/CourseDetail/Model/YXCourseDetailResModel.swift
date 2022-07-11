//
//  YXCourseDetailResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCourseDetailResModel: YXModel {
    @objc var courseCover: String?          //课程封面url
    @objc var courseDesc: String?           //课程简介
    @objc var courseDetail: String?         //课程详情
    @objc var courseId: Int = 0                //课程业务id
    @objc var courseIdStr: String?          //课程业务id
    @objc var courseLabel: String?          // 课程标签
    @objc var courseLecturer: String?       //课程讲师
    @objc var courseName: String?           //课程名称
    @objc var courseOrder: String?          //课程序号
    @objc var courseSubtitle: String?       //课程副标题
    @objc var offShelfTime: String?         //下架时间
    @objc var onShelfTime: String?          //上架时间
    @objc var primaryCategory: Int = 0         //一级分类id
    @objc var primaryCategoryStr: String?    //一级分类id
    @objc var regionNo: Int = 0               //地区编号
    @objc var secondaryCategory: Int  = 0     //二级分类id
    @objc var secondaryCategoryStr: String? //二级分类id
    @objc var shelfStatus : Int = 0          //状态 0-下架，1-上架
}

