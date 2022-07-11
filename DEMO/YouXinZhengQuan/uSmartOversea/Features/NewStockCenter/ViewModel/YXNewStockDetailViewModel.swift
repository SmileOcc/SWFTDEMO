//
//  YXNewStockDetailViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockDetailViewModel: HUDServicesViewModel {
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    
    var purchaseLabels: [String] = []
    
    //更新状态
    var isRefeshing: Bool = false
    var isPulling: Bool = false 
    var resetNewsList: Bool = false
    //响应回调
    var resultResponse: YXResultResponse<YXNewStockDetailInfoModel>?
    var addFocusResponse: YXResultResponse<YXNewStockAddFocusModel>?
    var newsInfoResponse: YXResultResponse<YXStockArticleModel>?
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, String?)
    let resultSubject = PublishSubject<resultType>()
    let newsInfoSubject = PublishSubject<Bool>()
    
    var services: Services! = YXNewStockService()
    var model: YXNewStockDetailInfoModel?
    
    var ecmType: YXNewStockEcmType = .onlyPublic
    
    var newsList: [YXStockArticleDetailModel] = []
    
    var quoteService: YXQuotesDataService = YXQuotesDataService()

    init() {
        resultResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    strongSelf.model = model
                    strongSelf.resultSubject.onNext((true, nil))
                } else if let msg = result.msg {
                    strongSelf.resultSubject.onNext((false, msg))
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.resultSubject.onNext((false, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
        
        addFocusResponse = {
            (response) in
            switch response {
            case .success(let result, let code):
                if code == .success {
                    
                } else if let _ = result.msg {
                    
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                
            }
        }
        
        newsInfoResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
   
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data, let list = model.newsList, list.count > 0 {
                    
                    if strongSelf.resetNewsList == true {
                        strongSelf.newsList.removeAll()
                        strongSelf.newsList = list
                    } else {
                        strongSelf.newsList += list
                    }
                    strongSelf.resetNewsList = false
                    strongSelf.newsInfoSubject.onNext(true)
                } else if let _ = result.msg {
                    strongSelf.newsInfoSubject.onNext(false)
                }
                
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.newsInfoSubject.onNext(false)
            }
        }
        
    }

}
