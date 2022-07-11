//
//  YXShortVideoMainViewModel.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class YXShortVideoMainViewModel {
    
    let liveCount: Driver<String>
    
    init(input: (viewDidLoad: Driver<()>,
                 viewDidAppear: Driver<()>)) {
        
        liveCount = input.viewDidAppear.flatMapLatest({ e in
            return YXCourseRequestAPI.liveCount.request().map({ res in
                if res?.code == .success, let count = res?.data?["num"] as? NSNumber, count.intValue > 0  {
                    if count.intValue > 99 {
                        return "99+"
                    }
                    return count.stringValue
                }else {
                    return ""
                }
            }).asDriver(onErrorJustReturn: "")
        })
        
    }
    
    func getRecommend(offset: Int) -> Single<YXShortVideoRecommendResModel?> {
        
        let single = Single<YXShortVideoRecommendResModel?>.create { single in
            
            let request = YXRequestV2.init(api: YXCourseRequestAPI.recommend(offset: offset, orderFlag: true))
            request.startWithBlock { (response) in
                if response.code == YXResponseStatusCode.success {
                    let model = YXShortVideoRecommendResModel.yy_model(withJSON: response.data ?? [:])
                    single(.success(model))
                }else {

                    single(.error(NSError.init(domain: "", code: Int(response.code.rawValue), userInfo: ["msg":response.msg ?? ""])))
                }
        
            } failure: { request in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            }

            return Disposables.create()
        }
        
        return single
    }
    
    func getVideo(id: String) -> Single<YXShortVideoRecommendResModel?> {
        let single = Single<YXShortVideoRecommendResModel?>.create { single in
            let request = YXRequestV2.init(api: YXSpecialAPI.KOLVideo(id: id))
            request.startWithBlock { (response) in
                if response.code == YXResponseStatusCode.success {
                    let item = YXShortVideoRecommendItem.yy_model(withJSON: response.data ?? [:])
                    let model = YXShortVideoRecommendResModel()
                    if let item = item {
                        model.list = [item]
                    }
                    single(.success(model))
                }else {
//                    single(.error(YXError.businessError(code: Int(response.code.rawValue), message: response.msg)))
                }
        
            } failure: { request in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            }

            return Disposables.create()
        }
        
        return single
    }
    
    /// 继续学习
    /// - Returns:
//    func getContinueLearn() -> Single<YXCourseRecordResModel?> {
//        return YXCourseRequestAPI.continueLearn.request().map { res in
//            if res?.code == .success {
//                return YXCourseRecordResModel.yy_model(withJSON: res?.data ?? [:])
//            }
//            return nil
//        }
//    }
    
}
