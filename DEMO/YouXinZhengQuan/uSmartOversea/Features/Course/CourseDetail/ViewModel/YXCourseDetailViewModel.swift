//
//  YXCourseDetailViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXCourseDetailViewModel {
    
    //课程号
    var courseId: String?
    
    //当前选择课程视频id
    var lessonId: String?
    
    //当前播放视频
    var videoId = 0
    
    //是否存在随堂测试
    var examPaperId: Int?
  
    //收藏结果
//    var collectResult: Driver<Bool?>!
        
    ///是否存在随堂测试
    var hasQuiz: Driver<(Int?,Bool)>!
    
    var isUserPayed: Bool = true
    
    var currentLesson: YXCourseLessonResModel?
    
    init(reloadQuizAction: Driver<String?>) {
        
//        collectResult = collectAction.flatMapLatest({ [weak self] action in
//            return YXCourseRequestAPI.collectAction(favoriteId: 0, lessonId: self?.lessonId ?? "", status: action ? 1 : 0 ).request().map({ res in
//                if res?.code == .success {
//                    return action
//                }else {
//                    return nil
//                }
//            }).asDriver(onErrorJustReturn: nil)
//        })
//        
        hasQuiz = reloadQuizAction.flatMapLatest({ item in
            return YXCourseRequestAPI.queryQuiz(lessonId: item ?? "").request().map({ res in
                let paperId = res?.data?["examPaperId"] as? Int
                let appearFlag = res?.data?["appearFlag"] as? Bool ?? false
                return (paperId,appearFlag)
            }).asDriver(onErrorJustReturn: (nil,false))
        })
        
    }
    
    func fetchUserPurchased() -> Single<YXUserPurchasedResModel?> {
        return YXCourseRequestAPI.checkUserPurchased(businessCode: 1, businessId: courseId ?? "").request().map({ res in
            if res?.code == .success {
                return YXUserPurchasedResModel.yy_model(withJSON: res?.data ?? [:])
            }
            return nil
        })
    }
    
    /// 保存用户记录
    /// - Parameters:
    ///   - watchProgress: 观看百分百
    ///   - watchTimePosition: 观看时长
    func userCourseRecord(watchProgress: Int, watchTimePosition: Int) {
        if YXUserManager.isLogin() {
            YXCourseRequestAPI.addCourseRecord(courseId: Int(courseId ?? "0")!,
                                               lessonId: Int(lessonId ?? "0")!,
                                               videoId: videoId,
                                               watchProgress: watchProgress,
                                               watchTimePosition: watchTimePosition).request()
                .subscribe(onSuccess: nil, onError: nil)
        }

    }
    
}
