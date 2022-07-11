//
//  YXCollectViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXCollectViewModel: HUDServicesViewModel  {

    typealias Services = HasYXUserService & HasYXNewsService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var loadSuccessSubject = PublishSubject<NSInteger>()
    var collectSuccessSubject = PublishSubject<Bool>()
    
    var collectListResponse: YXResultResponse<YXCollectNews>?
    var collectResponse: YXResultResponse<JSONAny>?
    
    var newsArr = [CollectionList]()
    var newsDelSet = [CollectionList]()
    
    var isRefresh: Bool = true
    var isEditor: Bool = false
    var curPage = 0
    
    var services: Services! {
        didSet {
            
            collectListResponse = {[weak self] (response) in
                
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        
                        if strongSelf.isRefresh {
                            strongSelf.newsArr.removeAll()
                            strongSelf.newsDelSet.removeAll()
                        }
                        strongSelf.curPage += 1
                        let dataArr = result.data?.collectionList ?? [CollectionList]()
                        for m in dataArr {
                            strongSelf.newsArr.append(m)
                        }
                        strongSelf.loadSuccessSubject.onNext(dataArr.count)
                        break
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
            
            collectResponse = {[weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        strongSelf.collectSuccessSubject.onNext(true)
                        break
                    default:
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    strongSelf.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
}
