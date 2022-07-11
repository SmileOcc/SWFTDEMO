//
//  YXNewStockDeliveredViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXNewStockDeliveredViewModel: HUDServicesViewModel, RefreshViewModel {
    
    typealias IdentifiableModel = YXNewStockDeliveredInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    lazy var userLevel: QuoteLevel = {

        YXUserManager.shared().getLevel(with: YXMarketType.HK.rawValue)
    }()

    //更新状态
    var needReloadData: Bool = false
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var orderDirection: Int = 0
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
   // viewModel.services.request(, response: (self.viewModel.deliverResponse)).disposed(by: rx.disposeBag)
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[YXNewStockDeliveredInfo]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.deliveredList(orderBy: "apply_date", orderDirection: strongSelf.orderDirection, pageNum: strongSelf.page, pageSize: strongSelf.perPage, pageSizeZero: false), response: { (response: YXResponseType<YXNewStockDeliveredListModel>) in
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let dataModel = result.data, let list = dataModel.list {
                        strongSelf.total = dataModel.total
                        single(.success(list))
                    } else {
                        single(.success([]))
                    }
                case .failed(let error):
                    log(.error, tag: kNetwork, content: "\(error)")
                    single(.error(error))
                }
            })
  
        })
    }

}

