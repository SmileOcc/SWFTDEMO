//
//  YXMarketNewsViewModel.swift
//  YouXinZhengQuan
//
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXMarketNewsViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService
    
    var disposeBag = DisposeBag.init()

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var bannerSubject = PublishSubject<YXUserBanner?>()
    var bannerResponse: YXResultResponse<YXUserBanner>?
    
    var recommendSubject = PublishSubject<Any?>()
    var recommendResponse: YXResultResponse<YXInfomationModelListModel>?
        
    var bannerList: [BannerList]?
    
    var list = [YXInfomationModel]()
    
    var refreshSubject = PublishSubject<Any?>()
    
    let liveRelay = BehaviorRelay<[YXLiveModel]>(value: [])
    
    // 推荐的参数
    var cmd: Int = 1
    var isTop = true
    var lastTime: Int?
    var last_score: Int?
    var market_str = "" //市场(不传-全部市场; a; hk; us; sg)
    var lang = 1; //0: 全部, 1: 中文, 3: 英文
    
    // 0 是普通 1 是下拉  2 是上拉
    var status = 0
    
    var topicList = [YXHotTopicModel]()

    var services: Services! {
        
        didSet {
        
//            bannerResponse = {[weak self] (response) in
//                switch response {
//                case .success(let result, _):
//                    if let model = result.data, model.bannerList.count > 0 {
//                        self?.bannerList = model.bannerList
//                        self?.bannerSubject.onNext(nil)
//                    } else {
//                        self?.bannerList = nil
//                        self?.bannerSubject.onNext(nil)
//                    }
//                case .failed(_):
//                    self?.bannerList = nil
//                    self?.bannerSubject.onNext(nil)
//                    break
//                }
//            }
            
            recommendResponse = {[weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success(let result, let code):
                    if code == .success {
                        if let list = result.data?.newsList, list.count > 0 {
                            for model in self.list {
                                model.refreshFlag = false
                                model.isRecommend = true
                            }
                            for model in list {
                                if let newsId = model.newsid {
                                    model.isRead = YXTabInfomationTool.infoReadDic[newsId] ?? false
                                }
                            }
                            
                            // 普通
                            if self.status == 0 || self.status == 1 {
                                self.list.removeAll()
                                YXTabInfomationTool.saveRecommendData(with: result.data)
                                for model in list {
                                    self.list.append(model)
                                }
                            } else {
    //                            list.first?.refreshFlag = true
                                // 上拉
                                for model in list {
                                    self.list.append(model)
                                }
                            }
                            
                            if let lastTime = self.list.last?.releaseTime {
                                self.lastTime = lastTime
                            }
                            if let lastsorce = self.list.last?.score {
                                self.last_score = lastsorce
                            }
                            
                            self.recommendSubject.onNext(list)
                        } else {
                            
                            if self.status == 0 || self.status == 1 {
                                self.list.removeAll()
                            } else {
                                
                            }
                            
                            if let lastTime = self.list.last?.releaseTime {
                                self.lastTime = lastTime
                            }
                            if let lastsorce = self.list.last?.score {
                                self.last_score = lastsorce
                            }
                            self.recommendSubject.onNext(nil)
                        }
                    } else {
                        self.recommendSubject.onNext(nil)
                    }
                    break
                case .failed(_):
                    self.recommendSubject.onNext(nil)
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    break
                }
            }
        }
    }
    
    init() {

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
