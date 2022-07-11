//
//  YXCryptosViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import YXKit

class YXCryptosViewModel: HUDServicesViewModel, RefreshViewModel {
    
    typealias IdentifiableModel = YXV2Quote
    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!

    let contentOffsetRelay = BehaviorRelay<CGPoint>(value: CGPoint.zero)
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()

    var services: Services! = YXNewStockService()
    
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
        Single<[IdentifiableModel]>.create(subscribe: { [weak self] (single) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            YXQuoteManager.sharedInstance.cryptosRank { (quoteList, scheme) in
                
                strongSelf.hudSubject.onNext(.hide)
                strongSelf.total = quoteList.count
                
                single(.success(strongSelf.sortResult(quoteList)))
            } failed: {
                single(.error(NSError.init(domain: "", code: -1, userInfo: nil)))
            }

            return Disposables.create()
        })
    }
    
    init() {
       
    }
    
    func sortResult(_ result: [YXV2Quote]) -> [YXV2Quote] {
        var sortArray = result
        
        sortArray.sort { [weak self] q1, q2 in
            guard let `self` = self else { return true }
            
            var sort1: Double = 0
            var sort2: Double = 0
            if self.sorttype == .roc {
                if let roc1Str = q1.btRealTime?.pctchng, let roc2Str = q2.btRealTime?.pctchng, let roc1 = Double(roc1Str), let roc2 = Double(roc2Str) {
                    
                    sort1 = roc1
                    sort2 = roc2
                }
            
            } else if self.sorttype == .now {
                if let now1Str = q1.btRealTime?.now, let now2Str = q2.btRealTime?.now, let now1 = Double(now1Str), let now2 = Double(now2Str) {
                    
                    sort1 = now1
                    sort2 = now2
                }
            }
            
            if self.sortdirection == 0 {
                return sort1 < sort2
            } else {
                return sort1 > sort2
            }

    
        }
        
        return sortArray
        
    }
}
