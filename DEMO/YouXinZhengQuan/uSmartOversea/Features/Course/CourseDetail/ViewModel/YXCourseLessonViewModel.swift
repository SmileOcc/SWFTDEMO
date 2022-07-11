//
//  YXCourseLessonViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import YYModel

class YXCourseLessonViewModel {
    
//    当前课程Id
    var courseId: String?
    
    //选择课时回调
    var selectedLesson = BehaviorRelay<(YXCourseLessonResModel?,YXCourseRecordResModel?)>(value: (nil,nil))
    
    var lessonsResult: Driver<YXCourseLessonListResModel?>!
    
    let activity: ActivityIndicator
    
    var isUserPayed: Bool = true
    
    init(input: (viewDidLoad: Driver<()>,
                 refreshAction: Driver<()>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        lessonsResult = Driver.merge(input.viewDidLoad,input.refreshAction).flatMapLatest({ [weak self] _ in
            return YXCourseRequestAPI.lessonList(courseId: self?.courseId ?? "").request().map { res in
                return YXCourseLessonListResModel.yy_model(withJSON: res?.data ?? [:])
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
    }
        
    /// 获取课程详情
    /// - Returns: 返回信号模型
    func fetchCourseDetail() -> Single<YXCourseDetailResModel?> {
        return YXCourseRequestAPI.courseDetail(courseId: courseId ?? "").request().map({ res in
            return YXCourseDetailResModel.yy_model(withJSON: res?.data ?? [:])
        }).trackActivity(activity).asSingle()
    }

}
