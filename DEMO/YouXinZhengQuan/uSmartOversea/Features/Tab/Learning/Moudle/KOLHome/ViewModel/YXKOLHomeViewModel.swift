//
//  YXKOLHomeViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class YXKOLHomeViewModel {
        
    let kolUserInfo: Driver<YXKOLUserInfoResModel?>
    let followResult: Driver<YXResponseModel?>
    
    
    let activity: ActivityIndicator
    
    init(input: (viewDidLoad: Driver<String?>,
                 followAction: Driver<Bool>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        kolUserInfo = input.viewDidLoad.flatMapLatest({ kolId in
            return YXSpecialAPI.KOLUserInfo(id:kolId ?? "").request().map { res in
                return YXKOLUserInfoResModel.yy_model(withJSON: res?.data ?? [:])
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)})
        
        followResult = Driver.combineLatest(input.viewDidLoad, input.followAction).flatMapLatest({ value in
            let (id,isFollow) = value
            return YXSpecialAPI.follow(state: isFollow ? 0 : 1, subscriptId: id ?? "").request().asDriver(onErrorJustReturn: nil)
        })
        
    }
                                                                            
}
