//
//  YXStockDetailAnnounceViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import NSObject_Rx

class YXStockDetailAnnounceViewModel: HUDServicesViewModel, HasDisposeBag {
    
    var disposeBag = DisposeBag.init()

    typealias Services = YXQuotesDataService
    
    var navigator: NavigatorServicesType!
    
    var services: Services! = YXQuotesDataService()
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var loadDownResponse: YXResultResponse<YXStockDetailAnnounceListModel>?
    var loadUpResponse: YXResultResponse<YXStockDetailAnnounceListModel>?
    
    var loadDownHSResponse: YXResultResponse<YXStockDetailHSAnnounceListModel>?
    var loadUpHSResponse: YXResultResponse<YXStockDetailHSAnnounceListModel>?

//    var eventReminderResponse: YXResultResponse<YXStockEventReminderModel>?
    var eventReminderSubject = PublishSubject<Any?>()
    
    var loadDownSubject = PublishSubject<Any?>()
    var loadUpSubject = PublishSubject<Any?>()
    
    var symbol: String = ""
    var market: String = ""
    var name: String?

    var isShowEventReminder = false
    
    var list = [YXStockDetailAnnounceModel]()
    var HSList = [YXStockDetailHSAnnounceModel]()

    var eventReminderList: [YXStockEventReminderDetailInfo] = []

    lazy var quoteObservable: Observable<[Any?]> = { [unowned self] in

        Observable.zip([self.loadDownSubject])
    }()
    
    var type = 0
    
    var index: Int = 0
    var perPage: Int = 30
    
    init() {
        loadDownResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list {
                    self.list.removeAll()
                    for model in list {
                        self.list.append(model)
                    }
                    self.loadDownSubject.onNext(self.list)
                } else {
                    self.list.removeAll()
                    self.loadDownSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self.list.removeAll()
                self.loadDownSubject.onNext(nil)
                break
            }
        }
        
        loadUpResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list, list.count > 0 {
                    for model in list {
                        self.list.append(model)
                    }
                    self.loadUpSubject.onNext(list)
                } else {
                    self.index = self.index - self.perPage
                    self.loadUpSubject.onNext(nil)
                }
                break
            case .failed(_):
                self.index = self.index - self.perPage
                self.loadUpSubject.onNext(nil)
                break
                
            }
        }
        
        loadDownHSResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list {
                    self.HSList.removeAll()
                    for model in list {
                        self.HSList.append(model)
                    }
                    self.loadDownSubject.onNext(self.HSList)
                } else {
                    self.HSList.removeAll()
                    self.loadDownSubject.onNext(nil)
                }
                
                break
            case .failed(_):
                self.HSList.removeAll()
                self.loadDownSubject.onNext(nil)
                break
            }
        }
        
        loadUpHSResponse = {[weak self] (response) in
            guard let `self` = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let list = result.data?.list, list.count > 0 {
                    for model in list {
                        self.HSList.append(model)
                    }
                    self.loadUpSubject.onNext(list)
                } else {
                    self.index = self.index - self.perPage
                    self.loadUpSubject.onNext(nil)
                }
                break
            case .failed(_):
                self.index = self.index - self.perPage
                self.loadUpSubject.onNext(nil)
                break
                
            }
        }


        // 获取大事提醒信息
//        eventReminderResponse = {[weak self] (response) in
//            guard let `self` = self else { return }
//            switch response {
//                case .success(let result, let code):
//                    if code == .success, let data = result.data, let noteList = data.noteList, noteList.count > 0 {
//
//                        var year = ""
//                        for info in noteList {
//                            if let eventDate = info.eventDate {
//                                var date = eventDate
//                                if eventDate.count >= 4 {
//                                    date = String(eventDate.prefix(4))
//                                }
//
//                                if year == date {
//                                    info.showYear = false
//                                } else {
//                                    year = date
//                                    info.showYear = true
//                                }
//                            }
//                        }
//                        self.eventReminderList = noteList
//                        self.eventReminderSubject.onNext(nil)
//                    } else {
//                        self.eventReminderList.removeAll()
//                        self.eventReminderSubject.onNext(nil)
//                    }
//                case .failed(_):
//                    self.eventReminderList.removeAll()
//                    self.eventReminderSubject.onNext(nil)
//                    break
//            }
//        }
    }
    
    func loadDown() {
        index = 0;
        if self.market == kYXMarketUS || self.market == kYXMarketHK {
            self.services.request(.announceInfo(index, perPage, self.type, self.market + self.symbol), response: self.loadDownResponse).disposed(by: self.disposeBag)
        } else {
            self.services.request(.HSAnnounceInfo(index, perPage, self.type, self.market + self.symbol), response: self.loadDownHSResponse).disposed(by: self.disposeBag)
        }

//        if isShowEventReminder {
//            self.services.request(.announceEventReminder(self.market + self.symbol), response: self.eventReminderResponse).disposed(by: self.disposeBag)
//        } else {
//            self.eventReminderList.removeAll()
//            self.eventReminderSubject.onNext(nil)
//        }
    }
    
    func loadUp() {
        index = index + perPage ;
        if self.market == kYXMarketUS || self.market == kYXMarketHK {
            self.services.request(.announceInfo(index, perPage, self.type, self.market + self.symbol), response: self.loadUpResponse).disposed(by: self.disposeBag)
        } else {
            self.services.request(.HSAnnounceInfo(index, perPage, self.type, self.market + self.symbol), response: self.loadUpHSResponse).disposed(by: self.disposeBag)
        }
    }

}
