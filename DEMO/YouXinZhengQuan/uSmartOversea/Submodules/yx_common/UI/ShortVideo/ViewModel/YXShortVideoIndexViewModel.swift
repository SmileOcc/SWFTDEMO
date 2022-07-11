//
//  YXShortVideoIndexViewModel.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2022/3/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class YXShortVideoIndexViewModel {
    
    func getFirstRecommendItem() -> Single<YXShortVideoRecommendItem?> {
        
        let single = Single<YXShortVideoRecommendItem?>.create { single in
            
            let request = YXRequestV2.init(api: YXCourseRequestAPI.recommend(offset: 0, orderFlag: true))
            request.startWithBlock { (response) in
                if response.code == YXResponseStatusCode.success {
                    let models = YXShortVideoRecommendResModel.yy_model(withJSON: response.data ?? [:])
                    single(.success(models?.list?.first))
                }else {
                    single(.error(NSError.init(domain: response.msg ?? "", code: Int(response.code.rawValue) ?? -1, userInfo: nil)))
                }
        
            } failure: { request in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            }

            return Disposables.create()
        }
        
        return single
    }
    
}
