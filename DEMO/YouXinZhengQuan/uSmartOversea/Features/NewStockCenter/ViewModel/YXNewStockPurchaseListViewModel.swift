//
//  YXNewStockPurchaseListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

import YXKit

class YXNewStockPurchaseListViewModel: HUDServicesViewModel, RefreshViewModel {
    typealias Services = YXNewStockService
    typealias IdentifiableModel = YXNewStockPurchaseListDetailModel
    
    var navigator: NavigatorServicesType!
    var exchangeType: YXExchangeType = .hk
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    let xchannelArrSubject = PublishSubject<[YXNewStockPurchaseListDetailModel]>()
    
    
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {

        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }
            
            if strongSelf.exchangeType == .hk {
                /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
                IPO app端相关api --> 获取客户ipo申购列表v2 -->
                /stock-order-server/api/iporecord-list/v2  */
                let hkApi: YXNewStockAPI = .recordList(pageNum: strongSelf.page, pageSize: strongSelf.perPage, pageSizeZero: 0, orderDirection: 0, exchangeType: strongSelf.exchangeType.rawValue)
                
                return strongSelf.services.request(hkApi, response: { (response: YXResponseType<YXNewStockPurchaseListModel>) in
                    
                    strongSelf.hudSubject.onNext(.hide)
                    
                    switch response {
                    case .success(let result, let code):
                        
                        if code == .success, let list = result.data?.list {
                            
                            //有团购
                            var xchannelArr = [YXNewStockPurchaseListDetailModel]()
                            for model in list {
                                                                
                                if model.xchannel == 1 {
                                    xchannelArr.append(model)
                                }
                            }
                            strongSelf.xchannelArrSubject.onNext(xchannelArr)
                            
                            
                            strongSelf.total = result.data?.total
                            single(.success(list))
                        } else {
                            single(.success([]))
                        }
                    case .failed(let error):
                        log(.error, tag: kNetwork, content: "\(error)")
                        single(.error(error))
                    }
                })
            } else {
                /* http://jy-dev.yxzq.com/stock-order-server/doc/doc.html -->
                IPO app端相关api --> 获取客户ipo申购列表v2 -->
                /stock-order-server/api/iporecord-list/v2  */
                
                let api: YXNewStockAPI = .recordList(pageNum: strongSelf.page, pageSize: strongSelf.perPage, pageSizeZero: 0, orderDirection: 0, exchangeType: strongSelf.exchangeType.rawValue)
                
                return strongSelf.services.request(api, response: { (response: YXResponseType<YXNewStockPurchaseListModel>) in
                    
                    strongSelf.hudSubject.onNext(.hide)
                    
                    switch response {
                    case .success(let result, let code):
                        
                        if code == .success, let list = result.data?.list {
                            //有团购
                            var xchannelArr = [YXNewStockPurchaseListDetailModel]()
                            for model in list {
                                if model.xchannel == 1 {
                                    xchannelArr.append(model)
                                }
                            }
                            strongSelf.xchannelArrSubject.onNext(xchannelArr)
                            
                            
                            strongSelf.total = result.data?.total
                            single(.success(list))
                        } else {
                            single(.success([]))
                        }
                    case .failed(let error):
                        log(.error, tag: kNetwork, content: "\(error)")
                        single(.error(error))
                    }
                })
            }
            
        })
    }
    
    
    var groupInfoResponse: YXResultResponse<YXYXBatchGetUserGroupInfoModel>?
    let groupInfoSubject = PublishSubject<Bool>()
    var groupInfoOrderList = [YXUserGroupInfoOrderList]()
    
    init() {
        
        groupInfoResponse = {
            [weak self] (response) in
            guard let strongSelf = self else { return }
            strongSelf.hudSubject.onNext(.hide)
            switch response {
            case .success(let result, let code):
                if code == .success, let data = result.data, let orderList = data.orderList {
                    
                    
                    strongSelf.groupInfoOrderList = orderList
                    strongSelf.groupInfoSubject.onNext(true)
                    
                } else if let msg = result.msg {
                    
                    strongSelf.groupInfoOrderList = []
                    strongSelf.hudSubject.onNext(.error(msg, false))
                    strongSelf.groupInfoSubject.onNext(false)
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
            }
        }
        
    }
}

