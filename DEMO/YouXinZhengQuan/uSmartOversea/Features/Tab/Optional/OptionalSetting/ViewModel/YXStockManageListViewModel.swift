//
//  YXStockManageListViewModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator
import RxCocoa
import RxSwift
import NSObject_Rx

class YXStockManageListViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    var secuGroup = BehaviorRelay<YXSecuGroup?>(value: nil)
    
    let dataSource: BehaviorRelay<[YXOptionalSecu]> = BehaviorRelay<[YXOptionalSecu]>(value:[])
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
            secuGroup.asDriver().drive(onNext: { [weak self] (secuGroup) in
                let secuIdList = secuGroup?.list ?? []
                let optionalSecus = YXOptionalDBManager.shareInstance().getDataWithSecus(secuIdList)
                let secus = secuIdList.map { (secuId) -> YXOptionalSecu in
                    for secu in optionalSecus {
                        if secu.market == secuId.market && secu.symbol == secuId.symbol {
                            return secu
                        }
                    }
                    let secu = YXOptionalSecu()
                    secu.market = secuId.market
                    secu.symbol = secuId.symbol
                    return secu
                }
                self?.dataSource.accept(secus)
            }).disposed(by: disposeBag)
        }
    }
    
    init() {
        
    }
    
    let checkedSecusRelay = BehaviorRelay<[YXSecuID]>(value: [])
    lazy var checkedSecus = [YXSecuID]()
    
    var defaultCheckIndexPath: IndexPath?

    func isChecked(_ secuId: YXSecuID) -> Bool {
        for checked in checkedSecus {
            if checked.isEqual(secuId) {
                return true
            }
        }
        return false
    }
    
    func defaultCheck(_ secuId: YXSecuID) {
        if let list = secuGroup.value?.list, list.contains(secuId) {
            for i in 0..<list.count {
                let obj = list[i]
                if obj.isEqual(secuId) {
                    defaultCheckIndexPath = IndexPath(row: i, section: 0)
                }
            }
            check(secuId)
        }
    }
    
    func check(_ secuId: YXSecuID) {
        if isChecked(secuId) {
            return
        }
        checkedSecus.append(secuId)
        checkedSecusRelay.accept(checkedSecus)
    }
    
    func unCheck(_ secuId: YXSecuID) {
       for i in 0..<checkedSecus.count {
            let obj = checkedSecus[i]
            if obj.isEqual(secuId) {
                checkedSecus.remove(at: i)
                break
            }
        }
        checkedSecusRelay.accept(checkedSecus)
    }
    
    func allCheck() {
        if let list = secuGroup.value?.list {
            checkedSecus = list
        }
        checkedSecusRelay.accept(checkedSecus)
    }

    func removeAllCheck() {
        checkedSecus = [YXSecuID]()
        checkedSecusRelay.accept(checkedSecus)
    }
}
