//
//  YXCourseViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa

class YXCourseViewModel {
    
  //  let banner: Driver<[YXActivityBannerModel]?>
    let allCourse: Driver<YXAllCourseResModel?>
    let activity: ActivityIndicator
    
    init (input: (viewDidLoad: Driver<()>,
                  reload: Driver<()>,
                  refresh: Driver<()>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        let refresh = Driver.merge(input.reload, input.refresh)
        
        allCourse = Driver.merge(input.viewDidLoad, refresh).flatMapLatest({ _ in
            return YXCourseRequestAPI.allCourse.request().map({ res in
                return YXAllCourseResModel.yy_model(withJSON: res?.data ?? [:])
            }).trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
//        banner = Driver.merge(input.viewDidLoad, refresh).flatMapLatest({ _ in
//            return YXCourseRequestAPI.fetchBanner.request().map({ res in
//                return NSArray.yy_modelArray(with: YXActivityBannerModel.self, json: res?.data?["activityBannerList"] ?? []) as? [YXActivityBannerModel] ?? []
//            }).trackActivity(activity).asDriver(onErrorJustReturn: nil)
//        })
    }
}
