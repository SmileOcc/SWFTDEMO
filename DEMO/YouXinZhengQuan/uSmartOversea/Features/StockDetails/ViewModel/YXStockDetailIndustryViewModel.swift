//
//  YXStockDetailIndustryViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXStockDetailIndustryViewModel: HUDServicesViewModel, RefreshViewModel {
    
    typealias IdentifiableModel = YXMarketRankCodeListInfo
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!
    
    var title: String?
    var code: String!
    var market: String!
    var rankType: YXRankType = .normal

    var isDetailIndustry: Bool = false
    var isShowBMP: Bool = true
    
    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
        
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()
    
    lazy var userLevel: QuoteLevel = {
        
        let level = YXUserManager.shared().getLevel(with: self.market)
        if level == .bmp {
            return .delay
        }
        return level
    }()

    func updateLevel() {
        var level = YXUserManager.shared().getLevel(with: self.market)
        if level == .bmp {
            level = .delay
        }
        userLevel = level
    }
    
    //响应回调
    var resultResponse: YXResultResponse<YXMarketRankModel>?
    
    var sorttype: YXStockRankSortType  = .roc
    var sortdirection: Int = 1
    //更新状态
    var needReloadData: Bool = false
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>?
    var endFooterRefreshStatus: Driver<EndRefreshStatus>?
    
    var page: Int = 1
    var offset: Int = 0
    var perPage: Int = 30
    var total: Int?
    
    let dataSource: BehaviorRelay<[IdentifiableModel]> = BehaviorRelay<[IdentifiableModel]>(value:[])
    
    var dataSourceSingle: Single<[IdentifiableModel]> {
        Single<[YXMarketRankCodeListInfo]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.services.request(.quotesRank(sortType: strongSelf.sorttype.rawValue, sortDirection: strongSelf.sortdirection, pageDirection: 0, from: strongSelf.offsetForPage(strongSelf.page), count: strongSelf.perPage, code: strongSelf.code, market: strongSelf.market, level: strongSelf.userLevel.rawValue), response: { (response: YXResponseType<YXMarketRankModel>) in
                strongSelf.hudSubject.onNext(.hide)
                switch response {
                case .success(let result, let code):
                    if code == .success, let dataModel = result.data?.list?.first?.data, let list = dataModel.list {
                        strongSelf.total = dataModel.total
                        single(.success(list))
                        if let item = list.first, let time = item.quoteTime, let type = self?.rankType {
                            let timeStr = "\(time)"
                            NotificationCenter.default.post(name: NSNotification.Name.init("MarketRankTimeNoti"), object: nil, userInfo: ["rankType": type, "quoteTime" : timeStr])
                        }
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
    
    init() {
        resultResponse = { [weak self] (response) in
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):
                if code == .success, let dataModel = result.data?.list?.first?.data,
                    let list = dataModel.list, list.count > 0,
                    let fromIndex = dataModel.from, fromIndex < strongSelf.dataSource.value.count {
                    var totalList = strongSelf.dataSource.value
                    let totalCount = totalList.count
                    var replaceIndex = fromIndex
                    for model in list {
                        if replaceIndex < totalCount {
                            totalList[replaceIndex] = model
                        }
                        replaceIndex += 1
                    }
                    strongSelf.dataSource.accept(totalList)
                }
            case .failed(_):
                log(.info, tag: kNetwork, content: " ")
            }
        }
    }
}
