//
//  YXOrderListViewModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

@objc enum YXAllOrderType: Int {
    case normal
    case dayMargin
    case option
    case shortSell
}

extension YXOrderItem: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        var conIdStr = ""
        if let value = conId?.value {
            if value is Int64 {
                conIdStr = "\(value)"
            }
            
            if value is String {
                conIdStr = value as! String
            }
        }
        return (entrustId ?? "") + conIdStr
    }
    
    var conIdString : String {
        
        var conIdStr = ""
        if let value = conId?.value {
            if value is Int64 {
                conIdStr = "\(value)"
            }
            
            if value is String {
                conIdStr = value as! String
            }
        }
        return  conIdStr
    }
}

struct YXTimeSection<T: IdentifiableType & Equatable> {
    var timeString: String
    var items: [T]
}

extension YXTimeSection: AnimatableSectionModelType {
    typealias Item = T
    
    typealias Identity = String
    
    var identity: String {
        timeString
    }
    
    init(original: YXTimeSection, items: [T]) {
        self = original
        self.items = items
    }
}

class YXOrderListViewModel: HUDServicesViewModel, RefreshViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    typealias IdentifiableModel = YXOrderItem
    
    var navigator: NavigatorServicesType!
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    var market: YXMarketFilterType = .all
    var enEntrustStatus = YXOrderFilterStatus.all.requestValue(.allOrder) // 默认全部订单
    var entrustBeginDate = ""
    var entrustEndDate = ""
    var stockCode = ""
    var filterDateFlag = YXHistoryDateType.Week.orderFilterRequestValue // 默认近一周
    var securityType = ""
    
    var nowDateString: String?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.en_US_POSIX()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let dateFlag: BehaviorRelay<YXDateFlag?> = BehaviorRelay<YXDateFlag?>(value: nil)
    
    let exchangeType: YXExchangeType?
    
    let allOrderType: YXAllOrderType
    
    var selectedItem: YXOrderItem?
    var selectedIndexPath: IndexPath?
    
    var showExpand = true

    var externParams: [String : Any] = [:]
    func setExternParams(_ externParams: [String : Any]) {
        self.externParams = externParams
        if let beginDate = externParams["beginDate"] as? String, let endDate = externParams["endDate"] as? String {
            entrustBeginDate = beginDate
            entrustEndDate = endDate
            filterDateFlag = "6"
        }

        if let symbol = externParams["symbol"] as? String {
            stockCode = symbol
        }
    }
    
    //刷新数据
    var requestRemoteDataSubject = PublishSubject<Bool>()
    var dataSourceSubject = PublishSubject<[IdentifiableModel]>() //用来被交易页监听
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay(value: [])
    let sectionDataSouce: BehaviorRelay<[YXTimeSection<IdentifiableModel>]> = BehaviorRelay(value: [])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        return single()
    }
    
    func single() -> Single<[IdentifiableModel]> {
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.tradeService.request(
                .hisEntrust(strongSelf.market,
                            strongSelf.filterDateFlag,
                            strongSelf.page,
                            strongSelf.perPage,
                            strongSelf.enEntrustStatus,
                            strongSelf.entrustBeginDate,
                            strongSelf.entrustEndDate,
                            strongSelf.stockCode,
                            strongSelf.securityType
                ), response: { (response: YXResponseType<YXEntrustData>) in
                switch response {
                case .success(let result, let code):
                    if code == .success, let list = result.data?.list {
                        strongSelf.nowDateString = result.data?.nowDate
                        strongSelf.total = result.data?.total
                        
                        strongSelf.dataSourceSubject.onNext(list)
                        
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
                    if let dateString = item.createDate, createDate != dateString, dateStrings.contains(dateString) == false{
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
    
    init(exchangeType: YXExchangeType?, allOrderType: YXAllOrderType = .normal) {
        self.exchangeType = exchangeType

        // TODO: 增加 SG
        if exchangeType == .hk {
            self.market = .hk
        } else if exchangeType == .us {
            self.market = .us
        } else {
            self.market = .all
        }

        self.allOrderType = allOrderType
    }
    
    func trackProperties() -> [String : Any] {
        var properties: [String : Any]  = [:]
        
//        properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_ID] = YXSensorAnalyticsPropsConstant.stockID(market: self.selectedItem?.market, symbol: self.selectedItem?.stockCode)
//        properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_NAME] = self.selectedItem?.stockName ?? ""
//        properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_MARKET] = self.selectedItem?.exchangeType == .us ? "美股" : "港股"
//        
//        if let entrustType = self.selectedItem?.entrustType {
//            properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_TRADE_TYPE] = entrustType == .buy ? "买" : "卖"
//        }
//        
//        var moneyUnit = "港币"
//        if let moneyType = self.selectedItem?.moneyType, moneyType == 1 {
//            moneyUnit = "美元"
//        }
//        
//        properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_MONEY_UNIT] = moneyUnit
//        
//        if let entrustPrice = self.selectedItem?.entrustPrice {
//            properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_TRADE_PRICE] = entrustPrice
//        }
//        
//        if let shareNumber = self.selectedItem?.entrustAmount {
//            properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_SHARE_NUMBER] = shareNumber
//        }
//        
//        if let totalMoney = self.selectedItem?.entrustTotalMoney {
//            properties[YXSensorAnalyticsPropsConstant.PROP_STOCK_TOTAL_AMOUNT] = totalMoney
//        }
//        
        return properties
    }
}
