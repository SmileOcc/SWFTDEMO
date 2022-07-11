//
//  YXHistoryViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
class YXHistoryViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXTradeService

    var navigator: NavigatorServicesType!
    
    // 网络请求的回调
    var historyListResponse: YXResultResponse<YXHistoryResponseModel>?
    
    var withdrawRevokeResponse: YXResultResponse<JSONAny>?
    
    // hud的信号
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {

        }
    }
    
    private init() {
        
    }
    
    var bizType: YXHistoryBizType = .All
    
    init(bizType: YXHistoryBizType = .All) {
        self.bizType = bizType
    }
}
