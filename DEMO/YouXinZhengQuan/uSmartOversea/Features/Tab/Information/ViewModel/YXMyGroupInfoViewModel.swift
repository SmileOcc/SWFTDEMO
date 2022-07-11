//
//  YXMyGroupInfoViewModel.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXMyGroupInfoViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var disposeBag = DisposeBag.init()
    
    var articleId: String = "0"
    var perPage: Int = 30
    var lang = 1; //0: 全部, 1: 中文, 3: 英文

    var loadDownResponse: YXResultResponse<YXInfomationModelListModel>?
    var loadUpResponse: YXResultResponse<YXInfomationModelListModel>?
    
    // 0 有数据正常  1 是无数据添加自选股  2 网络错误
    var loadDownSubject = PublishSubject<Any?>()
    var loadUpSubject = PublishSubject<Any?>()
    
    var list = [YXInfomationModel]()
    
    var refreshSubject = PublishSubject<Any?>()
    
    var services: Services! {
        
        didSet {
            loadDownResponse = {[weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        self.list.removeAll()
                        if let list = result.data?.newsList {
                            for model in list {
                                self.list.append(model)
                                model.isRecommend = false
                                if let newsId = model.newsid {
                                    model.isRead = YXTabInfomationTool.infoReadDic[newsId] ?? false
                                }
                            }
                            if let newsId = list.last?.newsid {
                                self.articleId = newsId
                            }
                            YXTabInfomationTool.saveMyGroupData(with: result.data)
                            
                            self.loadDownSubject.onNext(0)
                        } else {
                            self.loadDownSubject.onNext(1)
                        }
                    } else {
                        
                        self.list.removeAll()
                        if code == .newsNoOptional || code == .newsNoUser {
                            self.loadDownSubject.onNext(1)
                        } else {
                            self.loadDownSubject.onNext(2)
                        }
                    }
                    
                    break
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    self.loadDownSubject.onNext(2)
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
                            model.isRecommend = false
                            if let newsId = model.newsid {
                                model.isRead = YXTabInfomationTool.infoReadDic[newsId] ?? false
                            }
                        }
                        if let newsId = list.last?.newsid {
                            self.articleId = newsId
                        }
                        self.loadUpSubject.onNext(list)
                    } else {
                        self.loadUpSubject.onNext(nil)
                    }
                    break
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    self.loadUpSubject.onNext(nil)
                    break
                    
                }
            }
        }
    }
    
    init() {
        if let list = YXTabInfomationTool.getMyGroupDataFromCache()?.newsList {
           self.list = list
        }
    }
    
    func loadDown() {
//        self.articleId = "0";
//        var lanType: Int?
//        if YXUserManager.isENMode() {
//            lanType = info_language
//        }
//        let market = ""
//        self.services.infomationService.request(.selfSelect(articleId, perPage, lanType, market), response: self.loadDownResponse).disposed(by: self.disposeBag)
        
        
        //新接口文档 http://showdoc.yxzq.com/web/#/23?page_id=2454
        //http://10.55.4.41:15004/news-relatedwithstock/api/v1/query/selfselectnewsbylang
        self.articleId = "0";
        let market = ""
        let lanType = news_selected_language
        self.lang = lanType
        self.services.infomationService.request(.selfSelectbylang(articleId, perPage, self.lang, nil), response: self.loadDownResponse).disposed(by: self.disposeBag)
    }
    
    func loadUp() {
//        var lanType: Int?
//        if YXUserManager.isENMode() {
//            lanType = info_language
//        }
//        let market = "" //市场(不传-全部市场; a; hk; us; sg)
//        self.services.infomationService.request(.selfSelect(articleId, perPage, lanType, market), response: self.loadUpResponse).disposed(by: self.disposeBag)
        
        let market = ""
        let lanType = news_selected_language
        self.lang = lanType
        self.services.infomationService.request(.selfSelectbylang(articleId, perPage, self.lang, market), response: self.loadUpResponse).disposed(by: self.disposeBag)
    }

    func loadQuota(with arr: [YXInfomationModel]) {
        
        var secArr = [Secu]()
        var secStr = [String]()
        
        for model in arr {
            if let quoteModel = model.stocks?.first {
                if let market = quoteModel.market, let symbol = quoteModel.symbol, let type2 = quoteModel.type2 {
                    if type2 == 202 {
                        continue
                    }
                    if !secStr.contains(market + symbol) {
                        let secu = Secu.init(market: market, symbol: symbol)
                        secStr.append(market + symbol)
                        secArr.append(secu)
                    }
                    
                }
            }
        }
        
        if secArr.count > 0 {
            YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: secArr, level: .user, handler: ({ [weak self] (list, scheme) in
                guard let `self` = self else { return }
                if list.count > 0 {
                    for qutoaModel in list {
                        for model in self.list {
                            if let subStockModel = model.stocks?.first {
                                if let q1 = qutoaModel.symbol, let q2 = subStockModel.symbol, q1 == q2, let m1 = qutoaModel.market, let m2 = subStockModel.market, m1 == m2 {
                                    if let pct = qutoaModel.pctchng {
                                        subStockModel.roc = pct.value
                                    }
                                }
                            }
                        }
                    }
                    self.refreshSubject.onNext(nil)
                }
            }))
        }
    }
}
