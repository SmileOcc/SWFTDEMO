//
//  YXCoursewareViewModel.swift
//  uSmartEducation
//
//  Created by wangfengnan on 2021/11/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class YXCoursewareViewModel {
    
    ///当前播放视频
    let videoId = BehaviorRelay<String?>(value: nil)
    
    ///当前课程
    let lessonId = BehaviorRelay<String?>(value: nil)
    
    
    var examPaperId:Int = 0
    
    var courseWareResult: Driver<[String]?>!
    
    var hasQuiz: Single<[YXResponseModel]?>!
    
    let activity: ActivityIndicator
    
    
    
    init(input: (viewWillAppear: Driver<()>,
                 refreshAction: Driver<()>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        courseWareResult = Driver.merge(input.viewWillAppear,input.refreshAction).flatMapLatest({ [weak self] _ in
            return YXCourseRequestAPI.courseware(videoId: self?.videoId.value ?? "").request().map { res in
                return res?.data?["courseWareList"] as? [String]
            }.asDriver(onErrorJustReturn: nil)
        })
    }
    
    func fetchHasQuiz() -> Single<Int?> {

        return YXCourseRequestAPI.queryQuiz(lessonId: self.lessonId.value ?? "").request().map({ res in
            if res?.code == .success {
               // return YXUserPurchasedResModel.yy_model(withJSON: res?.data ?? [:])
                //res?.data?["examPaperId"]
                if let examPaperId = res?.data?["examPaperId"] {
                    return examPaperId as? Int
                }else {
                    return nil
                }
            }
            return nil
        })
    }
    
}
