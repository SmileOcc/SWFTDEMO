//
//  YXAllDayInfoViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import NSObject_Rx

class YXAllDayInfoViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var disposeBag = DisposeBag.init()
    
    var loadDownResponse: YXResultResponse<YXAllDayInfoListModel>?
    var loadUpResponse: YXResultResponse<YXAllDayInfoListModel>?
    
    var loadDownSubject = PublishSubject<Any?>()
    var loadUpSubject = PublishSubject<Any?>()
    
    var offset: Int = 0
    var perPage: Int = 30
    
    var list = [YXAllDayInfoModel]()
    
    var refreshSubject = PublishSubject<Any?>()

    var services: Services! {
        
        didSet {
            loadDownResponse = {[weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.newsletterList {
                        self.list.removeAll()
                        for model in list {
//                            if let newsId = model.newsid { // 没newsid
//                                model.isRead = YXTabInfomationTool.infoReadDic[newsId] ?? false
//                            }
                            model.resetStcokArr()
                            self.list.append(model)
                        }
                        if let offset = result.data?.offset {
                            self.offset = offset
                        }
                        YXTabInfomationTool.saveAllDayData(with: result.data)
                        self.loadDownSubject.onNext(self.list)
                        self.loadQuota()
                    } else {
                        self.list.removeAll()
                        self.loadDownSubject.onNext(nil)
                    }
                    
                    break
                case .failed(_):
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                    self.loadDownSubject.onNext(nil)
                    break
                }
            }
            
            loadUpResponse = {[weak self] (response) in
                guard let `self` = self else { return }
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.newsletterList, list.count > 0 {
                        for model in list {
                            model.resetStcokArr()
                            self.list.append(model)
                        }
                        if let offset = result.data?.offset {
                            self.offset = offset
                        }
                        self.loadQuota()
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
        if let list = YXTabInfomationTool.getAllDayDataFromCache()?.newsletterList {
           self.list = list
        }
    }
    
    func loadDown() {
        self.offset = 0;
        let time = Date.init().timeIntervalSince1970
        self.services.infomationService.request(.allDay(offset, Int(time), perPage, "0"), response: self.loadDownResponse).disposed(by: self.disposeBag)
    }
    
    func loadUp() {
        let time = Date.init().timeIntervalSince1970
        self.services.infomationService.request(.allDay(offset, Int(time), perPage, "0"), response: self.loadUpResponse).disposed(by: self.disposeBag)
    }
    
    func loadQuota() {
        
        var secArr = [Secu]()
        var secStr = [String]()
        
        for model in list {
            for quoteModel in model.stockArr  {
                if let market = quoteModel.market, let symbol = quoteModel.symbol {
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
                            for subStockModel in model.stockArr {
                                if let q1 = qutoaModel.symbol, let q2 = subStockModel.symbol, q1 == q2, let m1 = qutoaModel.market, let m2 = subStockModel.market, m1 == m2 {
                                    subStockModel.name = qutoaModel.name
                                    subStockModel.roc = qutoaModel.pctchng?.value
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
