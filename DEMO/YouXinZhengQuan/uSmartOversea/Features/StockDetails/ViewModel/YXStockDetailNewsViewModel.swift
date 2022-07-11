//
//  YXStockDetailNewsViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import NSObject_Rx

var stockDetailChangeLang: Int = 1

class YXStockDetailNewsViewModel: HUDServicesViewModel, HasDisposeBag {
    var disposeBag = DisposeBag.init()
    typealias Services = YXQuotesDataService
    
    var navigator: NavigatorServicesType!
    
    var services: Services! = YXQuotesDataService()
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var loadDownResponse: YXResultResponse<YXStockArticleModel>?
    var loadUpResponse: YXResultResponse<YXStockArticleModel>?
    
    var loadDownSubject = PublishSubject<Any?>()
    var loadUpSubject = PublishSubject<Any?>()
    
    var list = [YXStockArticleDetailModel]()
    
    var symbol: String = ""
    var market: String = ""
    
    var articleId: String = "0"
    var perPage: Int = 30
    var lang = 1; //0: 全部, 1: 中文, 3: 英文
    var lastTime: Int = 0

    init() {
        loadDownResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.newsList {
                    self.list.removeAll()
                    for model in list {
                        self.list.append(model)
                    }
                    if let newsId = list.last?.newsId {
                        self.articleId = newsId
                    }
                    if let lastTime = list.last?.releaseTime {
                        self.lastTime = lastTime
                    }
                    self.loadDownSubject.onNext(self.list)
                } else {
                    self.list.removeAll()
                    self.loadDownSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self.loadDownSubject.onNext(nil)
                break
            }
        }
        
        loadUpResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.newsList, list.count > 0 {
                    for model in list {
                        self.list.append(model)
                    }
                    if let newsId = list.last?.newsId {
                        self.articleId = newsId
                    }
                    if let lastTime = list.last?.releaseTime {
                        self.lastTime = lastTime
                    }
                    self.loadUpSubject.onNext(list)
                } else {
                    self.loadUpSubject.onNext(nil)
                }
                break
            case .failed(_):
                self.loadUpSubject.onNext(nil)
                break
                
            }
        }
    }
    
    func loadDown() {
        self.articleId = "0";
        self.lastTime = 0;
        var enlangType: Int?
        if YXUserManager.isENMode() {
            enlangType = stockDetailChangeLang
        }
//        self.services.request(.articleInfo(self.market + self.symbol, self.articleId, self.perPage, enlangType), response: self.loadDownResponse).disposed(by: self.disposeBag)
        var market: String?
        self.services.request(.articleInfoBylang(self.market + self.symbol, self.lastTime, self.perPage, self.lang, market), response: self.loadDownResponse).disposed(by: self.disposeBag)
    }
    
    func loadUp() {
        var enlangType: Int?
        if YXUserManager.isENMode() {
            enlangType = stockDetailChangeLang
        }
//        self.services.request(.articleInfo(self.market + self.symbol, self.articleId, self.perPage, enlangType), response: self.loadUpResponse).disposed(by: self.disposeBag)
        self.services.request(.articleInfoBylang(self.market + self.symbol, self.lastTime, self.perPage, self.lang, market), response: self.loadUpResponse).disposed(by: self.disposeBag)

    }

    
}
