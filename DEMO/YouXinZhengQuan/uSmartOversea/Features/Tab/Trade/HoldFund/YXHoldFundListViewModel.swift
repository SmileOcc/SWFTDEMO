//
//  YXHoldFundListViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

extension YXHoldFundModel: IdentifiableType {
    public typealias Identity = String
    
    public var identity: String {
        fundCode ?? ""
    }
}

class YXHoldFundListViewModel: HUDServicesViewModel, RefreshViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    
    typealias IdentifiableModel = YXHoldFundModel
    
    var securityType: YXSecurityType = .fund
    
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
    
    var selectedIndexPath: IndexPath?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay(value: [])
    
    var originList: [IdentifiableModel] = [IdentifiableModel]()
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        //为解决 ： 已退出状态，token失效，但是还返回了用户信息，就会出现 已经退出，但是还是登录状态
        if YXUserManager.isLogin() {
            return Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
                guard let strongSelf = self else { return Disposables.create() }
                
//                var quoteLevel: QuoteLevel = .delay
//                switch strongSelf.exchangeType {
//                case .hk:
//                    quoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
//                case .us:
//                    quoteLevel = YXUserManager.shared().getLevel(with: YXMarketType.US.rawValue)
//                }
                //TODO:换model
                /**  客户股票资产查询
                /aggregation-server/api/user-asset-aggregation/v1     */
                let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0
                return strongSelf.services.tradeService.request(.stockAsset(strongSelf.exchangeType, extendStatusBit), response: { (response: YXResponseType<YXAssetModel>) in
                    switch response {
                    case .success(let result, let code):
                        if code == .success {//holdFundProfitList
                            if let dataList = result.data?.holdFundProfitList, dataList.count > 0 {
                                strongSelf.originList = dataList
                            }
                            single(.success(strongSelf.originList))
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
    
    var services: Services! {
        didSet {
        }
    }
    
    init(exchangeType: YXExchangeType) {
        self.exchangeType = exchangeType
    }
}
