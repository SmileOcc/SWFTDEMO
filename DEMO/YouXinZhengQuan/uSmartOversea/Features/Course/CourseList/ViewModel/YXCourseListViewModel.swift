//
//  YXCourseListViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa

class YXCourseListViewModel {
    
    var primaryCategory: String?
    var secondaryCategory: String?
    
    func getCourseList() -> Single<YXCourseListResModel?> {
        return YXCourseRequestAPI.courseList(primaryCategory: self.primaryCategory ?? "", secondaryCategory: self.secondaryCategory).request().map { res in
            return YXCourseListResModel.yy_model(withJSON: res?.data ?? [:])
        }
    }
}
