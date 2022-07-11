//
//  YXStockManageViewModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator
import RxSwift
import RxCocoa

class YXStockManageViewModel: ServicesViewModel {
    typealias Services = AppServices
    
    var navigator: NavigatorServicesType!
    
    lazy var titles: Driver<[String]> = {
        let observable = Observable<[String]>.create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return YXSecuGroupManager.shareInstance().rx.observeWeakly([YXSecuGroup].self, "allGroupsForShow").subscribe(onNext: { (secuGroupList) in
                var titles = [String]()
                
                secuGroupList?.forEach({ (secuGroup) in
                    guard let groupId = YXDefaultGroupID(rawValue: secuGroup.id) else { return }
                    var title: String? = ""
                    switch groupId {
                    case .idAll:
                        title = YXLanguageUtility.kLang(key: "common_all")
                    case .IDHK:
                        title = YXLanguageUtility.kLang(key: "community_hk_stock")
                    case .IDUS:
                        title = YXLanguageUtility.kLang(key: "community_us_stock")
                    case .IDCHINA:
                        title = YXLanguageUtility.kLang(key: "community_cn_stock")
                    case .IDHOLD, .IDLATEST:
                        title = nil
                    case .IDUSOPTION:
                        title = YXLanguageUtility.kLang(key: "options_options")
                    default:
                        title = secuGroup.name
                    }
                    if let title = title {
                      titles.append(title)
                    }
                })
                
                observer.onNext(titles)
            })
        }
        
        return observable.asDriver(onErrorJustReturn: [])
    }()
    
    lazy var viewControllers: Driver<[UIViewController]> = {
        let observable = Observable<[UIViewController]>.create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return YXSecuGroupManager.shareInstance().rx.observeWeakly([YXSecuGroup].self, "allGroupsForShow").subscribe(onNext: { (secuGroupList) in
                var viewControllers = [YXStockManageListViewController]()
                
                secuGroupList?.forEach({ (secuGroup) in
                    if secuGroup.id != YXDefaultGroupID.IDHOLD.rawValue && secuGroup.id != YXDefaultGroupID.IDLATEST.rawValue {
                        strongSelf.groupIds.append(secuGroup.id)
                        if let viewController = strongSelf.groupPool[secuGroup.id] {
                            let viewModel = viewController.viewModel!
                            viewModel.secuGroup.accept(secuGroup)
                            
                            viewControllers.append(viewController)
                        } else {
                            let viewModel = YXStockManageListViewModel()
                            viewModel.navigator = strongSelf.navigator
                            viewModel.secuGroup.accept(secuGroup)
                            if let secu = self?.defaultSelectedSecu {
                                let secuID = YXSecuID.init(market: secu.market, symbol: secu.symbol)
                                viewModel.defaultCheck(secuID)
                            }
                            let viewController = YXStockManageListViewController.instantiate(withViewModel: viewModel, andServices: strongSelf.services, andNavigator: viewModel.navigator)
                            strongSelf.groupPool[secuGroup.id] = viewController
                            
                            viewControllers.append(viewController)
                        }
                    }
                })
                
                observer.onNext(viewControllers)
            })
        }
        
        return observable.asDriver(onErrorJustReturn: [])
    }()
    
    var groupPool: [UInt: YXStockManageListViewController] = [:]
    
    lazy var groupIds = [UInt]()
    var defaultSelectedId: UInt?
    var defaultSelectedSecu: YXSecuIDProtocol?
    
    var services: Services! {
        didSet {
            // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        }
    }
    
    init() {
        
    }
}
