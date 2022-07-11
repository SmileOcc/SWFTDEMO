//
//  YXGroupManageViewModel.swift
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

class YXGroupManageViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    let dataSource: BehaviorRelay<[YXSecuGroup]> = BehaviorRelay<[YXSecuGroup]>(value:[])
    var selectGroup : YXSecuGroup = YXSecuGroupManager.shareInstance().allGroupsForShow.first!
    var secuGroup = BehaviorRelay<YXSecuGroup?>(value: nil)
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
            YXSecuGroupManager.shareInstance().rx.observeWeakly([YXSecuGroup].self, "allGroupsForShow").subscribe(onNext: { [weak self] (secuGroupList) in
                guard let `self` = self else { return }
                
                self.dataSource.accept(secuGroupList ?? [])
            
                if secuGroupList?.contains(self.selectGroup) == false{
                    self.selectGroup = YXSecuGroupManager.shareInstance().allGroupsForShow.first!
                    self.secuGroup.accept(YXSecuGroupManager.shareInstance().allGroupsForShow.first!)
                }else{
                    secuGroupList?.forEach({ secuGroup in
                        if secuGroup == self.selectGroup {
                            self.selectGroup = secuGroup
                            self.secuGroup.accept(secuGroup)
                            return
                        }
                    })
                }
                
            }).disposed(by: disposeBag)
        }
    }
    
    init() {
        
    }
}
