//
//  YXHoldBondListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

extension YXBondHoldModel: IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        String(bondId ?? 0)
    }
}

class YXHoldBondListViewModel: HUDServicesViewModel, RefreshViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    typealias IdentifiableModel = YXBondHoldModel
    
    var securityType: YXSecurityType = .bond
    
    var navigator: NavigatorServicesType!
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    //    let trackOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    //    let dragOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    var sorttype: YXStockRankSortType?
    var sortdirection: YXSortState = .normal
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    let exchangeType: YXExchangeType
    
    var selectedItem: YXBondHoldModel?
    var selectedIndexPath: IndexPath?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay(value: [])
    
    var originList: [IdentifiableModel] = [IdentifiableModel]()
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        //为解决 ： 已退出状态，token失效，但是还返回了用户信息，就会出现 已经退出，但是还是登录状态
        if YXUserManager.isLogin() {
            return Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
                guard let strongSelf = self else { return Disposables.create() }
                return strongSelf.services.tradeService.request(.bondHold, response: { (response: YXResponseType<YXBondHoldListResponseModel>) in
                    switch response {
                    case .success(let result, let code):
                        if code == .success, let list = result.data?.bondPositionList {
                            strongSelf.originList = list
                            single(.success(strongSelf.reloadedList()))
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
        } else {
            return Single<[IdentifiableModel]>.create(subscribe: { (single) -> Disposable in
                Disposables.create()
            })
        }
    }
    
    func reloadedList() -> [IdentifiableModel] {
        if let type = sorttype, sortdirection != .normal {
            let array = originList.sorted { [weak self] (obj1, obj2) -> Bool in
                guard let strongSelf = self else { return true }
                
                switch type {
                case .dailyBalance:
                    if sortdirection == .ascending {
                        return Double(obj1.profit ?? "0") ?? 0 < Double(obj2.profit ?? "0") ?? 0
                    } else {
                        return Double(obj1.profit ?? "0") ?? 0 > Double(obj2.profit ?? "0") ?? 0
                    }
                case .holdingBalance:
                    if sortdirection == .ascending {
                        return Double(obj1.totalProfit ?? "0") ?? 0 < Double(obj2.totalProfit ?? "0") ?? 0
                    } else {
                        return Double(obj1.totalProfit ?? "0") ?? 0 > Double(obj2.totalProfit ?? "0") ?? 0
                    }
                case .lastAndCostPrice:
                    if sortdirection == .ascending {
                        return Double(obj1.price ?? "0") ?? 0 < Double(obj2.price ?? "0") ?? 0
                    } else {
                        return Double(obj1.price ?? "0") ?? 0 > Double(obj2.price ?? "0") ?? 0
                    }
                case .marketValueAndNumber:
                    if sortdirection == .ascending {
                        return Double(obj1.marketValue ?? "0") ?? 0 < Double(obj2.marketValue ?? "0") ?? 0
                    } else {
                        return Double(obj1.marketValue ?? "0") ?? 0 > Double(obj2.marketValue ?? "0") ?? 0
                    }
                default:
                    break
                }
                return true
            }
            return array
        } else {
            return originList
        }
    }
    
    var services: Services! {
        didSet {
        }
    }
    
    init(exchangeType: YXExchangeType) {
        self.exchangeType = exchangeType
    }
}
