//
//  YXOrderBondListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

extension YXBondOrderModel
: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        var conIdStr = ""
        if let value = orderNo {
            conIdStr = value
        }
        return conIdStr
    }
    
    var conIdString : String {
        
        var conIdStr = ""
        if let value = bondId {
            
            conIdStr = "\(value)"
            
        }
        return  conIdStr
    }
}

class YXOrderBondListViewModel: HUDServicesViewModel, RefreshViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    typealias IdentifiableModel = YXBondOrderModel
    
    var navigator: NavigatorServicesType!
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    var nowDateString: String?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.en_US_POSIX()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let dateFlag: BehaviorRelay<YXDateFlag?> = BehaviorRelay<YXDateFlag?>(value: nil)
    
    let exchangeType: YXExchangeType
    
    var selectedItem: YXBondOrderModel?
    var selectedIndexPath: IndexPath?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay(value: [])
    let sectionDataSouce: BehaviorRelay<[YXTimeSection<IdentifiableModel>]> = BehaviorRelay(value: [])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            guard let flag = strongSelf.dateFlag.value else { return Disposables.create() }
            
            return strongSelf.services.tradeService.request(.bondOrderList(2, flag, strongSelf.page, strongSelf.perPage), response: { (response: YXResponseType<YXBondHistoryOrderListResponseModel>) in
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list {
                        strongSelf.nowDateString = YXDateHelper.dateSting(from: Date())
//                        strongSelf.nowDateString = result.data?.nowDate
                        strongSelf.total = result.data?.total
                        
                        strongSelf.selectedItem = nil
                        strongSelf.selectedIndexPath = nil
                        
                        single(.success(list))
                    } else {
                        if let msg = result.msg {
                            strongSelf.hudSubject.onNext(.error(msg, false))
                        }
                        single(.error(NSError(domain: result.msg ?? "", code: -1, userInfo: nil)))
                    }
                    
                case .failed(let error):
                    single(.error(error))
                }
            })
        })
    }
    
    var services: Services! {
        didSet {
            dataSource.asDriver().drive(onNext: { [weak self] (array) in
                guard let strongSelf = self else { return }
                
                var createDate = ""
                var dateStrings = [String]()
                var orderPool = [String: [IdentifiableModel]]()
                array.forEach({ (item) in
                    let timeInterval = (item.createTime ?? 0)/1000
                    let dateString = YXDateHelper.dateSting(from: TimeInterval(timeInterval), formatterStyle: .yyyyMMdd)
                    if createDate != dateString {
                        createDate = dateString
                        dateStrings.append(createDate)
                        
                        var items = [IdentifiableModel]()
                        items.append(item)
                        orderPool[createDate] = items
                    } else {
                        var items = orderPool[createDate] ?? []
                        items.append(item)
                        orderPool[createDate] = items
                    }
                })
                var sections = [YXTimeSection<IdentifiableModel>]()
                dateStrings.forEach({ (dateString) in
                    guard let nowDateString = strongSelf.nowDateString,
                        let nowDate = strongSelf.dateFormatter.date(from: nowDateString) else { return }
                    
                    let items = orderPool[dateString]
                    var timeString = dateString
                    if timeString == nowDateString {
                        timeString = YXLanguageUtility.kLang(key: "hold_today")
                    } else {
                        if let date = strongSelf.dateFormatter.date(from: timeString) {
                            if date.timeIntervalSince1970 + 86400 == nowDate.timeIntervalSince1970{
                                timeString = YXLanguageUtility.kLang(key: "hold_yesterday")
                            } else {
                                if YXUserManager.isENMode() {
                                    let formatter = DateFormatter.en_US_POSIX()
                                    formatter.locale = Locale(identifier: "en_US_POSIX")
                                    if (date as NSDate).year == (nowDate as NSDate).year {
                                        formatter.dateFormat = "dd MMM"
                                        timeString = formatter.string(from: date)
                                    } else {
                                        formatter.dateFormat = "dd MMM, yyyy"
                                        timeString = formatter.string(from: date)
                                    }
                                } else {
                                    if (date as NSDate).year == (nowDate as NSDate).year {
                                        timeString = String(format: "%2d%@%2d%@", (date as NSDate).month, YXLanguageUtility.kLang(key: "common_month"), (date as NSDate).day, YXLanguageUtility.kLang(key: "common_day"))
                                    } else {
                                        timeString = String(format: "%2d%@%2d%@，%04d%@", (date as NSDate).month, YXLanguageUtility.kLang(key: "common_month"), (date as NSDate).day, YXLanguageUtility.kLang(key: "common_day"), (date as NSDate).year, YXLanguageUtility.kLang(key: "common_year"))
                                    }
                                }
                            }
                        }
                    }
                    let section = YXTimeSection(timeString: timeString, items: items ?? [])
                    sections.append(section)
                })
                strongSelf.sectionDataSouce.accept(sections)
                
            }).disposed(by: disposeBag)
        }
    }
    
    init(exchangeType: YXExchangeType) {
        self.exchangeType = ((exchangeType == .sh || exchangeType == .sz) ? .hs : exchangeType)
    }
    
    func trackProperties() -> [String : Any] {
        var properties: [String : Any]  = [:]
        
        return properties
    }

}
